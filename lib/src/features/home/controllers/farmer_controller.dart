import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Services
import '../../../core/local/key_value_storage_service.dart';

// Models
import '../models/farmer_model.codegen.dart';

// Controllers
import '../../../global/all_providers.dart';

final currentFarmerProvider = StateProvider<FarmerModel?>((ref) => null);

final currentToolProvider = StateProvider<String?>((ref) => null);

final farmersController = Provider<FarmersController>(
  (ref) {
    final keyValueService = ref.watch(keyValueStorageServiceProvider);
    return FarmersController(ref, keyValueService);
  },
);

class FarmersController {
  final Ref _ref;
  final KeyValueStorageService _keyValueStorageService;

  FarmersController(this._ref, this._keyValueStorageService);

  Future<void> loadFarmerFromImport(FarmerModel farmer) async {
    _ref.read(currentFarmerProvider.notifier).state = farmer;
    await saveFarmerInCache(farmer);
  }

  void loadCurrentFarmerFromCache() {
    final farmer = _keyValueStorageService.getFarmer();
    if (farmer == null) {
      debugPrint('Failed to load farmer data from cache');
      throw Exception('Failed to load farmer data from cache');
    }
    _ref.read(currentFarmerProvider.notifier).state = farmer;
  }

  Future<bool> saveFarmerInCache(FarmerModel farmer) async {
    return _keyValueStorageService.setFarmer(farmer);
  }
}
