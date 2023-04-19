// ignore_for_file: avoid_positional_boolean_parameters

import 'package:hooks_riverpod/hooks_riverpod.dart';

// Services
import '../../../core/local/key_value_storage_service.dart';

// Enums
import '../enums/sampling_mode.dart';

// Controllers
import '../../ad_hoc_sampling/controllers/ad_hoc_controller.dart';
import '../../home/controllers/coordinates_controller.dart';
import '../../home/controllers/data_export_controller.dart';
import '../../home/controllers/farmer_controller.dart';
import '../../home/controllers/paddocks_controller.dart';
import '../../home/controllers/properties_controller.dart';
import '../../../global/all_providers.dart';

// States
import '../states/sampling_state.codegen.dart';

final samplingController =
    StateNotifierProvider<SamplingController, SamplingState>(
  (ref) {
    final keyValueStorageService = ref.watch(keyValueStorageServiceProvider);
    return SamplingController(
      ref,
      keyValueStorageService: keyValueStorageService,
    );
  },
);

class SamplingController extends StateNotifier<SamplingState> {
  final KeyValueStorageService _keyValueStorageService;
  final Ref _ref;

  SamplingController(
    this._ref, {
    required KeyValueStorageService keyValueStorageService,
  })  : _keyValueStorageService = keyValueStorageService,
        super(const SamplingState.idle());

  void init() {
    try {
      final currentSampling = _keyValueStorageService.getCurrentSamplingState();
      if (currentSampling != null) {
        _ref.read(farmersController).loadCurrentFarmerFromCache();
        _ref.read(paddocksController.notifier).loadPaddocksFromCache();
        _ref.read(propertiesController).loadPropertiesFromCache();
        _ref.read(coordinatesController.notifier).loadCoordinatesFromCache();
        state = SamplingState.done(currentSampling);
      } else {
        state = const SamplingState.idle();
      }
    } on Exception catch (ex) {
      state = SamplingState.failed(reason: ex.toString());
    }
  }

  Future<void> saveSamplingInCache(SamplingMode currentSampling) async {
    state = const SamplingState.loading();

    final isSaved =
        await _keyValueStorageService.setCurrentSamplingState(currentSampling);

    if (isSaved) {
      state = SamplingState.done(currentSampling);
    } else {
      state = const SamplingState.failed(
        reason: 'Saving sampling status failed. Try again',
      );
    }
  }

  Future<void> erase() async {
    state = const SamplingState.loading();

    await _keyValueStorageService.resetKeys();
    _ref
      ..invalidate(adHocController)
      ..invalidate(paddocksMapProvider)
      ..invalidate(currentFarmerProvider)
      ..invalidate(farmersController)
      ..invalidate(paddocksController)
      ..invalidate(currentToolProvider)
      ..invalidate(currentPropertyProvider)
      ..invalidate(propertiesController)
      ..invalidate(currentPaddockProvider)
      ..invalidate(propertiesController)
      ..invalidate(currentPaddockNoteProvider)
      ..invalidate(coordinatesListProvider)
      ..invalidate(coordinateCountProvider)
      ..invalidate(coordinatesController)
      ..invalidate(dataExportController)
      ..invalidateSelf();
  }
}
