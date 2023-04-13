// ignore_for_file: avoid_positional_boolean_parameters

import 'package:hooks_riverpod/hooks_riverpod.dart';

// Services
import '../../../core/local/key_value_storage_service.dart';

// Models
import '../../home/controllers/coordinates_controller.dart';
import '../../home/controllers/data_export_controller.dart';
import '../../home/controllers/farmer_controller.dart';
import '../../home/controllers/paddocks_controller.dart';
import '../../home/controllers/properties_controller.dart';

// Controllers
import '../../../global/all_providers.dart';

// States
import '../states/data_import_state.codegen.dart';

final dataImportController =
    StateNotifierProvider<DataImportController, DataImportState>(
  (ref) {
    final keyValueStorageService = ref.watch(keyValueStorageServiceProvider);
    return DataImportController(
      ref,
      keyValueStorageService: keyValueStorageService,
    );
  },
);

class DataImportController extends StateNotifier<DataImportState> {
  final KeyValueStorageService _keyValueStorageService;
  final Ref _ref;

  DataImportController(
    this._ref, {
    required KeyValueStorageService keyValueStorageService,
  })  : _keyValueStorageService = keyValueStorageService,
        super(const DataImportState.idle());

  void initImportedData() {
    try {
      final isDataImported = _keyValueStorageService.getIsDataImported();
      if (isDataImported != null && isDataImported) {
        _ref.read(farmersController.notifier).loadCurrentFarmerFromCache();
        _ref.read(paddocksController.notifier).loadPaddocksFromCache();
        _ref.read(propertiesController).loadPropertiesFromCache();
        _ref.read(coordinatesController.notifier).loadCoordinatesFromCache();
        state = const DataImportState.done();
      } else {
        state = const DataImportState.idle();
      }
    } on Exception catch (ex) {
      state = DataImportState.failed(reason: ex.toString());
    }
  }

  Future<void> saveIsImportedFlagToCache(bool isImported) async {
    state = const DataImportState.loading();

    final isSaved = await _keyValueStorageService.setIsDataImported(isImported);

    if (isSaved) {
      state = const DataImportState.done();
    } else {
      state = const DataImportState.failed(
        reason: 'Data import failed. Try again',
      );
    }
  }

  void erase() {
    _keyValueStorageService.resetKeys();
    state = const DataImportState.idle();
    _ref
      ..invalidate(dataImportController)
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
      ..invalidate(dataExportController);
  }
}
