import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Models
import '../models/imported_data_model.codegen.dart';

// Helpers
import '../../sampling_modes/enums/sampling_mode.dart';
import '../../../helpers/extensions/string_extension.dart';
import '../../../helpers/typedefs.dart';

// Controllers
import '../../sampling_modes/controllers/sampling_controller.dart';
import '../../home/controllers/farmer_controller.dart';
import '../../home/controllers/paddocks_controller.dart';

// States
import '../../../global/states/future_state.codegen.dart';

final dataImportController =
    StateNotifierProvider<DataImportController, FutureState<bool>>(
  DataImportController.new,
);

class DataImportController extends StateNotifier<FutureState<bool>> {
  final Ref _ref;

  DataImportController(this._ref) : super(const FutureState.idle());

  Future<void> importData() async {
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
        final dataString = await file.readAsString();
        final dynamic dataJson = jsonDecode(dataString);

        if (dataJson is! JSON) {
          throw Exception('Data is not in correct format');
        }
        final dataModel = ImportedDataModel.fromJson(dataJson);

        await _ref
            .read(farmersController)
            .loadFarmerFromImport(dataModel.farmer);

        await _ref
            .read(paddocksController.notifier)
            .loadPaddocksFromImport(dataModel.paddocks);

        await _ref
            .read(samplingController.notifier)
            .saveSamplingInCache(SamplingMode.planned);

        return true;
      },
      errorMessage:
          "Failed to import data from file. Either the file is empty or the contents' format is invalid",
    );
  }
}
