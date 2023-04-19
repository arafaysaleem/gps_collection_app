import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

// Services
import '../../../core/local/key_value_storage_service.dart';

// Models
import '../models/paddock_model.codegen.dart';

// States
import '../../../global/states/future_state.codegen.dart';

// Controllers
import '../../../global/all_providers.dart';
import 'coordinates_controller.dart';
import 'farmer_controller.dart';
import 'properties_controller.dart';

final currentPaddockNoteProvider = StateProvider((ref) => '');

final currentPaddockProvider = StateProvider<PaddockModel?>((ref) => null);

final _paddocksMapProvider = StateProvider<Map<String, PaddockModel>>((ref) {
  return {};
});

final paddocksController =
    StateNotifierProvider<PaddocksController, FutureState<bool>>((ref) {
  final keyValueService = ref.watch(keyValueStorageServiceProvider);
  return PaddocksController(ref, keyValueService);
});

class PaddocksController extends StateNotifier<FutureState<bool>> {
  final KeyValueStorageService _keyValueStorageService;
  final Ref _ref;

  PaddocksController(this._ref, this._keyValueStorageService)
      : super(const FutureState.idle());

  Future<void> loadPaddocksFromImport(List<PaddockModel> paddocks) async {
    final farmer = _ref.read(currentFarmerProvider)!;
    if (paddocks.any((e) => e.farmerId != farmer.pkCID)) {
      throw Exception(
        "Paddocks data does not belong to farmer '${farmer.fullName}'",
      );
    }
    _ref.read(_paddocksMapProvider.notifier).state = {
      for (var e in paddocks) e.code: e
    };
    await _ref.read(propertiesController).importPropertiesData(paddocks);
    await _savePaddocksInCache(paddocks);
  }

  void loadPaddocksFromCache() {
    final paddocks = _keyValueStorageService.getPaddocks();
    if (paddocks == null) {
      debugPrint('Paddocks not loaded from cache');
      throw Exception('Paddocks not loaded from cache');
    }

    _ref.read(_paddocksMapProvider.notifier).state = {
      for (var e in paddocks) e.code: e
    };

    final currentPaddock = _keyValueStorageService.getCurrentPaddockCode();
    _ref.read(currentPaddockProvider.notifier).state =
        currentPaddock == null ? null : _getPaddockByCode(currentPaddock);
  }

  UnmodifiableListView<PaddockModel> getAllPaddocks({String? property}) {
    return UnmodifiableListView(_ref.read(_paddocksMapProvider).values);
  }

  PaddockModel _getPaddockByCode(String code) {
    return _ref.read(_paddocksMapProvider)[code]!;
  }

  Future<bool> _savePaddocksInCache(List<PaddockModel> paddocks) async {
    return _keyValueStorageService.setPaddocks(paddocks);
  }

  void setCurrentPaddock(PaddockModel? paddock) {
    _ref.read(currentPaddockProvider.notifier).state = paddock;
    _ref.read(coordinatesController.notifier).loadCoordinatesFromCache();
    _ref.read(currentPaddockNoteProvider.notifier).state =
        _keyValueStorageService.getPaddockNote(paddock?.code ?? '') ?? '';
  }

  void setCurrentPaddockNote(String note) {
    _ref.read(currentPaddockNoteProvider.notifier).state = note;

    final currentPaddock = _ref.read(currentPaddockProvider);
    _keyValueStorageService.setPaddockNote(note, currentPaddock!.code);
  }

  Future<void> createNewPaddock(String paddockName) async {
    state = const FutureState.loading();

    final currentFarmer = _ref.read(currentFarmerProvider)!;
    final paddock = PaddockModel(
      code: const Uuid().v4(),
      farmerId: currentFarmer.pkCID,
      paddock: paddockName,
      propertyId: '',
    );

    state = await FutureState.makeGuardedRequest(
      () async {
        final paddocksMap = _ref.read(_paddocksMapProvider);
        if (paddocksMap.containsKey(paddock.code)) {
          throw Exception('Paddock already exists');
        }
        final saved = await _savePaddocksInCache(
          [paddock, ...paddocksMap.values],
        );
        if (saved) {
          _ref.read(_paddocksMapProvider.notifier).state = {
            ...paddocksMap,
            paddock.code: paddock
          };
          setCurrentPaddock(paddock);
        }
        return saved;
      },
      errorMessage: 'Failed to create new paddock',
    );
  }
}
