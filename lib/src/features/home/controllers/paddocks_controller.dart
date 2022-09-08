import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:charset/charset.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Models
import '../../../core/local/key_value_storage_service.dart';
import '../../../global/all_providers.dart';
import '../../../global/states/future_state.codegen.dart';
import '../../../helpers/typedefs.dart';
import '../../data_import/controllers/data_import_controller.dart';
import '../models/paddock_model.codegen.dart';
import 'coordinates_controller.dart';
import 'properties_controller.dart';

final paddockByCodeProvider =
    Provider.family<PaddockModel, String>((ref, code) {
  return ref.watch(paddocksController.notifier)._getPaddockByCode(code);
});

final currentPaddockProvider = StateProvider<PaddockModel?>((ref) => null);

final paddocksController =
    StateNotifierProvider<PaddocksController, FutureState<bool>>((ref) {
  final _keyValueService = ref.watch(keyValueStorageServiceProvider);
  return PaddocksController(ref, _keyValueService);
});

class PaddocksController extends StateNotifier<FutureState<bool>> {
  final KeyValueStorageService _keyValueStorageService;
  final Ref _ref;

  late final Map<String, PaddockModel> _paddocksMap;

  PaddocksController(this._ref, this._keyValueStorageService)
      : super(const FutureState.idle());

  Future<void> importPaddocksData() async {
    state = const FutureState.loading();

    state = await FutureState.makeGuardedRequest(
      () async {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
          lockParentWindow: true,
        );

        if (result == null) return false;

        final file = File(result.files.single.path!);
        final paddocksJson = utf16.decode(await file.readAsBytes());
        final dynamic paddocksList = jsonDecode(paddocksJson);

        if (paddocksList is! List) {
          throw Exception('Paddock data is not in correct format');
        }
        final paddocks = paddocksList
            .map((dynamic e) => PaddockModel.fromJson(e as JSON))
            .toList();

        _paddocksMap = {for (var e in paddocks) e.code: e};
        await _ref.read(propertiesController).importPropertiesData(paddocks);
        // await savePaddockInCache(tempFarmer);

        await _ref
            .read(dataImportController.notifier)
            .saveIsImportedFlagToCache(true);
        return true;
      },
      errorMessage:
          "Failed to import farmer's paddocks data from file. Either the file is empty or the contents' format is invalid",
    );
  }

  void loadPaddocksFromCache() {
    final paddocks = _keyValueStorageService.getPaddocks();
    if (paddocks == null) {
      debugPrint('Paddocks not loaded from cache');
      throw Exception('Paddocks not loaded from cache');
    }
    _paddocksMap = {for (var e in paddocks) e.code: e};

    final currentPaddock = _keyValueStorageService.getCurrentPaddockCode();
    _ref.read(currentPaddockProvider.notifier).state =
        currentPaddock == null ? null : _getPaddockByCode(currentPaddock);
  }

  UnmodifiableListView<PaddockModel> getAllPaddocks({String? property}) {
    return UnmodifiableListView(_paddocksMap.values);
  }

  PaddockModel _getPaddockByCode(String code) {
    return _paddocksMap[code]!;
  }

  Future<bool> savePaddocksInCache(List<PaddockModel> paddocks) async {
    return _keyValueStorageService.setPaddocks(paddocks);
  }

  Future<bool> _saveCurrentPaddockInCache(PaddockModel paddock) async {
    return _keyValueStorageService.setCurrentPaddock(paddock.code);
  }

  void setCurrentPaddock(PaddockModel? paddock) {
    _ref.read(currentPaddockProvider.notifier).state = paddock;
    // _saveCurrentPaddockInCache(paddock);
    _ref.read(coordinatesController.notifier).loadCoordinatesFromCache();
  }
}
