import 'dart:async';

import 'package:flutter/foundation.dart';
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

final coordinateCountProvider = StateProvider<int>((ref) {
  return ref.watch(coordinatesListProvider).length;
});

final coordinatesListProvider =
    StateProvider<List<CoordinateModel>>((ref) => []);

final coordinatesController =
    StateNotifierProvider<CoordinatesController, FutureState<bool>>(
  (ref) {
    final keyValueService = ref.watch(keyValueStorageServiceProvider);
    return CoordinatesController(ref, keyValueService);
  },
);

const gpsTimeLimit = Duration(seconds: 5);

class CoordinatesController extends StateNotifier<FutureState<bool>> {
  final KeyValueStorageService _keyValueStorageService;
  final Ref _ref;

  CoordinatesController(this._ref, this._keyValueStorageService)
      : super(const FutureState.idle());

  Future<void> fetchAndSaveCoordinate() async {
    state = const FutureState.loading();

    state = await FutureState.makeGuardedRequest(
      () async {
        if (_ref.read(currentPaddockProvider) == null) {
          throw Exception('Please select a paddock first.');
        }

        if (_ref.read(currentToolProvider) == null) {
          throw Exception('Please select a tool first.');
        }

        await _checkGpsEnabled();

        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: gpsTimeLimit,
          );
        } on TimeoutException catch (ex) {
          debugPrint(ex.toString());
          position = await Geolocator.getLastKnownPosition();
        }

        if (position == null) {
          throw Exception(
            'Location capture failed. You might need to enable internet only for the first coordinate.',
          );
        }

        if (_checkCoordinateInvalid(position)) {
          throw Exception('Coordinate already exists in this paddock');
        }

        await _createCoordinateFromPosition(position);

        return true;
      },
    );
  }

  bool _checkCoordinateInvalid(Position position) {
    final latitude = position.latitude;
    final longitude = position.longitude;

    if (latitude == 0 && longitude == 0) {
      return true;
    }

    final currentPaddockCode = _ref.read(currentPaddockProvider)?.code;

    final coordinates = _keyValueStorageService.getPaddockCoordinates(
      currentPaddockCode ?? '',
    );

    return coordinates?.any(
          (e) => e.latitude == latitude && e.longitude == longitude,
        ) ??
        false;
  }

  Future<void> _createCoordinateFromPosition(Position position) async {
    final currentPaddockCode = _ref.read(currentPaddockProvider)!.code;

    final tool = _ref.read(currentToolProvider)!;

    final coordinate = CoordinateModel(
      latitude: position.latitude,
      longitude: position.longitude,
      note: '',
      tool: tool,
      paddockCode: currentPaddockCode,
      dateTime: position.timestamp ?? DateTime.now(),
      accuracy: position.speedAccuracy.toInt(),
      horizontaGpsAccuracy: position.accuracy.toInt(),
    );

    _ref
        .read(coordinatesListProvider.notifier)
        .update((state) => [...state, coordinate]);
    final cached = await _saveCoordinatesInCache();

    if (!cached) {
      throw Exception('Failed to save coordinates to cache');
    }
  }

  void saveCoordinateNote({required int index, required String note}) {
    _ref.read(coordinatesListProvider.notifier).update((state) {
      state[index] = state[index].copyWith(note: note);
      return [...state];
    });
    _saveCoordinatesInCache();
  }

  void deleteCoordinate(int i) {
    _ref.read(coordinatesListProvider.notifier).update((state) {
      state.removeAt(i);
      return [...state];
    });
    _saveCoordinatesInCache();
  }

  Future<void> _checkGpsEnabled() async {
    bool serviceEnabled;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      final locationOpened = await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationOpened || !serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    final prevIsLow = (await Geolocator.getLocationAccuracy()) ==
        LocationAccuracyStatus.reduced;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final accuracy = await Geolocator.getLocationAccuracy();
      final isLowAccuracy = accuracy == LocationAccuracyStatus.reduced;
      final isApproximateFirstTry = isLowAccuracy && !prevIsLow;
      if (isApproximateFirstTry) {
        throw Exception(
          'We need precise location to capture coordinates. Please enable precise (high-accuracy) mode in your location settings.',
        );
      } else if (isLowAccuracy && prevIsLow) {
        permission = await Geolocator.requestPermission();
      }
    }

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
      final openPermSettings = await Geolocator.openAppSettings();
      if (!openPermSettings) {
        throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }
    }
  }

  void loadCoordinatesFromCache() {
    final currentPaddock = _ref.read(currentPaddockProvider);

    final coordinates = _keyValueStorageService
        .getPaddockCoordinates(currentPaddock?.code ?? '');
    _ref.read(coordinatesListProvider.notifier).state = [...?coordinates];
  }

  Future<bool> _saveCoordinatesInCache() async {
    final paddockCode = _ref.read(currentPaddockProvider)!.code;
    return _keyValueStorageService.setPaddockCoordinates(
      _ref.read(coordinatesListProvider),
      paddockCode,
    );
  }
}
