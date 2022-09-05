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
import '../models/farmer_model.codegen.dart';

final currentFarmerProvider = StateProvider<FarmerModel?>((ref) => null);

final coreNoteProvider = StateProvider((ref) => '');

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
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
          lockParentWindow: true,
        );

        if (result == null) return false;

        final file = File(result.files.single.path!);
        final farmerString = utf16.decode(await file.readAsBytes());
        final dynamic farmerJson = jsonDecode(farmerString);

        if (farmerJson is! JSON) {
          throw Exception('Farmer data is not in correct format');
        }
        final farmer = FarmerModel.fromJson(farmerJson);

        _ref.read(currentFarmerProvider.notifier).state = farmer;
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
