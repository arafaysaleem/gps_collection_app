import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Models
import '../../../core/local/key_value_storage_service.dart';
import '../../../global/all_providers.dart';
import '../../../global/states/future_state.codegen.dart';
import '../../../helpers/constants/app_utils.dart';
import '../models/paddock_model.codegen.dart';
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
        await Future<void>.delayed(Durations.slower);

        const tempPaddocks = [
          PaddockModel(
            farmerId: 'pkCID',
            propertyId: 'CRIS_ID',
            code: 'PAD-1A',
            fkSID: 'fkSID',
            paddock: 'Paddock A',
          ),
          PaddockModel(
            farmerId: 'pkCID',
            propertyId: 'CRIS_ID2',
            code: 'PAD-2A',
            fkSID: 'fkSID',
            paddock: 'Paddock A',
          ),
          PaddockModel(
            farmerId: 'pkCID',
            propertyId: 'CRIS_ID',
            code: 'PAD-1B',
            fkSID: 'fkSID',
            paddock: 'Paddock B',
          ),
          PaddockModel(
            farmerId: 'pkCID',
            propertyId: 'CRIS_ID',
            code: 'PAD-1C',
            fkSID: 'fkSID',
            paddock: 'Paddock C',
          ),
        ];

        _paddocksMap = {for (var e in tempPaddocks) e.code: e};
        await _ref.read(propertiesController).importPropertiesData(tempPaddocks);
        // await savePaddockInCache(tempFarmer);

        return true;
      },
      errorMessage: 'Failed to import paddocks data from file',
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

  Future<bool> saveCurrentPaddockInCache(PaddockModel paddock) async {
    return _keyValueStorageService.setCurrentPaddock(paddock.code);
  }
}
