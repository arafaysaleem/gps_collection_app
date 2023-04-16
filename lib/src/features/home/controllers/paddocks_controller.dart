import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:charset/charset.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

// Services
import '../../../core/local/key_value_storage_service.dart';

// Models
import '../models/paddock_model.codegen.dart';

// Helpers
import '../../../helpers/extensions/string_extension.dart';
import '../../../helpers/typedefs.dart';
import '../../sampling_modes/enums/sampling_mode.dart';

// States
import '../../../global/states/future_state.codegen.dart';

// Controllers
import '../../../global/all_providers.dart';
import '../../sampling_modes/controllers/sampling_controller.dart';
import 'coordinates_controller.dart';
import 'farmer_controller.dart';
import 'properties_controller.dart';

final currentPaddockNoteProvider = StateProvider((ref) => '');

final currentPaddockProvider = StateProvider<PaddockModel?>((ref) => null);

final paddocksController =
    StateNotifierProvider<PaddocksController, FutureState<bool>>((ref) {
  final keyValueService = ref.watch(keyValueStorageServiceProvider);
  return PaddocksController(ref, keyValueService);
});

class PaddocksController extends StateNotifier<FutureState<bool>> {
  final KeyValueStorageService _keyValueStorageService;
  final Ref _ref;

  late Map<String, PaddockModel> _paddocksMap;

  PaddocksController(this._ref, this._keyValueStorageService)
      : super(const FutureState.idle());

  Future<void> importPaddocksData() async {
    state = const FutureState.loading();

    state = await FutureState.makeGuardedRequest(
      () async {
        final result = await FilePicker.platform.pickFiles(
          type: defaultTargetPlatform == TargetPlatform.windows
              ? FileType.custom
              : FileType.any,
          allowedExtensions:
              defaultTargetPlatform == TargetPlatform.windows ? ['json'] : null,
          lockParentWindow: true,
        );

        if (result == null) return false;
        if (result.files.single.path!.ext != '.json') {
          throw Exception(
            'Unsupported file format. Please ensure to only select .json files',
          );
        }

        final file = File(result.files.single.path!);
        final paddocksJson = utf16.decode(await file.readAsBytes());
        final dynamic paddocksList = jsonDecode(paddocksJson);

        if (paddocksList is! List) {
          throw Exception('Paddock data is not in correct format');
        }
        final paddocks = paddocksList
            .map((dynamic e) => PaddockModel.fromJson(e as JSON))
            .toList();

        final currentFarmer = _ref.read(currentFarmerProvider)!;
        if (paddocks.any((e) => e.farmerId != currentFarmer.pkCID)) {
          throw Exception(
            "Paddocks data does not belong to farmer '${currentFarmer.fullName}'",
          );
        }

        _paddocksMap = {for (var e in paddocks) e.code: e};
        await _ref.read(propertiesController).importPropertiesData(paddocks);
        await _savePaddocksInCache(paddocks);

        await _ref
            .read(samplingController.notifier)
            .saveSamplingInCache(SamplingMode.planned);
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
    );

    state = await FutureState.makeGuardedRequest(
      () async {
        final saved = await _savePaddocksInCache(
          [paddock, ..._paddocksMap.values],
        );
        if (saved) {
          _paddocksMap[paddock.code] = paddock;
          return true;
        }
        return false;
      },
      errorMessage: 'Failed to create new paddock',
    );
  }
}
