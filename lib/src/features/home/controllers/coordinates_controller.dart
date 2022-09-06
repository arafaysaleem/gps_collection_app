import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Models
import '../models/coordinate_model.codegen.dart';

// Service
import '../../../core/local/key_value_storage_service.dart';

// Controllers
import 'farmer_controller.dart';
import 'paddocks_controller.dart';
import '../../../global/all_providers.dart';

// States
import '../../../global/states/future_state.codegen.dart';

// Helpers
import '../../../helpers/extensions/int_extension.dart';

final coordinateCountProvider = StateProvider<int>((ref) => 0);

final coordinatesController =
    StateNotifierProvider<CoordinatesController, FutureState<bool>>((ref) {
  final _keyValueService = ref.watch(keyValueStorageServiceProvider);
  return CoordinatesController(ref, _keyValueService);
});

class CoordinatesController extends StateNotifier<FutureState<bool>> {
  final KeyValueStorageService _keyValueStorageService;
  final Ref _ref;
  final _gpsTimeLimit = 5.seconds;

  late final List<CoordinateModel> _coordinatesList;

  CoordinatesController(this._ref, this._keyValueStorageService)
      : super(const FutureState.idle());

  Future<void> fetchAndSaveCoordinate() async {
    state = const FutureState.loading();

    state = await FutureState.makeGuardedRequest(
      () async {
        await _checkGpsEnabled();

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: _gpsTimeLimit,
        );

        final currentPaddockCode = _ref.read(currentPaddockProvider)!.code;
        final tool = _ref.read(currentToolProvider);
        final coordinate = CoordinateModel(
          latitude: position.latitude,
          longitude: position.longitude,
          note: '',
          tool: tool!,
          paddockCode: currentPaddockCode,
          dateTime: position.timestamp ?? DateTime.now(),
          accuracy: position.speedAccuracy.toInt(),
          horizontaGpsAccuracy: position.accuracy.toInt(),
        );

        _coordinatesList.add(coordinate);
        _ref.read(coordinateCountProvider.notifier).state++;
        final cached = await _keyValueStorageService.setPaddockCoordinates(
          _coordinatesList,
          currentPaddockCode,
        );

        if (!cached) {
          throw Exception('Failed to save coordinates to cache');
        }

        return true;
      },
    );
  }

  Future<void> _checkGpsEnabled() async {
    bool serviceEnabled;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
  }

  void loadCoordinatesFromCache() {
    final currentPaddock = _ref.read(currentPaddockProvider);

    final coordinates = _keyValueStorageService
            .getPaddockCoordinates(currentPaddock?.code ?? '') ??
        [];
    _coordinatesList = coordinates;

    _ref.read(coordinateCountProvider.notifier).state = coordinates.length;
  }

  UnmodifiableListView<CoordinateModel> getAllCoordinates() {
    return UnmodifiableListView(_coordinatesList);
  }

  Future<bool> saveCoordinatesInCache(List<CoordinateModel> coordinates) async {
    final paddockCode = _ref.read(currentPaddockProvider)!.code;
    return _keyValueStorageService.setPaddockCoordinates(
      coordinates,
      paddockCode,
    );
  }
}
