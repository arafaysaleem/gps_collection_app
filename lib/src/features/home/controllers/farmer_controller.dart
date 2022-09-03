import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Models
import '../../../core/local/key_value_storage_service.dart';
import '../../../global/all_providers.dart';
import '../../../global/states/future_state.codegen.dart';
import '../../../helpers/constants/app_utils.dart';
import '../models/farmer_model.codegen.dart';

final currentFarmerProvider = StateProvider<FarmerModel?>((ref) => null);

final farmersController =
    StateNotifierProvider<FarmersController, FutureState<bool>>(
  (ref) {
    final _keyValueService = ref.watch(keyValueStorageServiceProvider);
    return FarmersController(ref, _keyValueService);
  },
);

class FarmersController extends StateNotifier<FutureState<bool>> {
  final Ref _ref;
  final KeyValueStorageService _keyValueStorageService;

  FarmersController(this._ref, this._keyValueStorageService)
      : super(const FutureState.idle());

  Future<void> importFarmerData() async {
    state = const FutureState.loading();

    state = await FutureState.makeGuardedRequest(
      () async {
        await Future<void>.delayed(Durations.slower);

        const tempFarmer = FarmerModel(
          pkCID: 'pkCID',
          first: 'Abdur',
          last: 'Rafay',
        );

        _ref.read(currentFarmerProvider.notifier).state = tempFarmer;
        // await saveFarmersInCache(tempFarmer);

        return true;
      },
      errorMessage: 'Failed to import farmer data from file',
    );
  }

  void loadCurrentFarmerFromCache() {
    final farmer = _keyValueStorageService.getFarmer();
    if (farmer == null) {
      debugPrint('Failed to load farmer data from cache');
      throw Exception('Failed to load farmer data from cache');
    }
    _ref.read(currentFarmerProvider.notifier).state = farmer;
  }

  Future<bool> saveFarmersInCache(FarmerModel farmer) async {
    return _keyValueStorageService.setFarmer(farmer);
  }
}
