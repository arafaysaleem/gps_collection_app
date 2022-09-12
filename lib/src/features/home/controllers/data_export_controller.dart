import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

// Providers
import '../../../core/local/key_value_storage_service.dart';
import '../../../core/local/path_provider_service.dart';
import '../../../global/all_providers.dart';
import 'coordinates_controller.dart';
import 'farmer_controller.dart';
import 'paddocks_controller.dart';

// States
import '../../../global/states/future_state.codegen.dart';

// Helpers
import '../../../helpers/extensions/datetime_extension.dart';

// Models
import '../models/coordinate_model.codegen.dart';
import '../models/farmer_model.codegen.dart';
import '../models/paddock_model.codegen.dart';

final dataExportController =
    StateNotifierProvider<DataExportController, FutureState<void>>(
  (ref) {
    final keyValueStorageService = ref.watch(keyValueStorageServiceProvider);
    return DataExportController(ref, keyValueStorageService);
  },
);

class _ComputeArgs {
  final List<PaddockModel> paddocks;
  final FarmerModel currentFarmer;

  _ComputeArgs(this.paddocks, this.currentFarmer);
}

class DataExportController extends StateNotifier<FutureState<void>> {
  final Ref _ref;
  final KeyValueStorageService _keyValueStorageService;

  DataExportController(this._ref, this._keyValueStorageService)
      : super(const FutureState.idle());

  Future<void> exportCoordinatesToExcel() async {
    state = const FutureState.loading();

    // Load all paddocks and current farmer
    final paddocks = _ref.read(paddocksController.notifier).getAllPaddocks();
    final currentFarmer = _ref.read(currentFarmerProvider)!;

    state = await FutureState.makeGuardedRequest(
      () async {
        // Perform data to excel conversion in a seperate asynchronous isolate
        final args = _ComputeArgs(paddocks, currentFarmer);
        final excelDataRows = await compute(_convertAllDataToExcelRows, args);

        // Create an excel sheet using the previous rows
        final file = await _saveRowsToWorkbook(
          excelDataRows,
          currentFarmer.fullName,
        );

        // Email the sheet
        if (defaultTargetPlatform == TargetPlatform.android) {
          await _sendEmail(file.path, currentFarmer.fullName);
        }

        return;
      },
      errorMessage: 'Failed to export and email data',
    );
  }

  List<ExcelDataRow> _convertAllDataToExcelRows(_ComputeArgs args) {
    final excelDataRows = <ExcelDataRow>[];

    // Loop each paddock
    for (final paddock in args.paddocks) {
      // Fetch all coordinates of the paddock
      final coords =
          _keyValueStorageService.getPaddockCoordinates(paddock.code);

      // Fetch note of the paddock
      final note = _keyValueStorageService.getPaddockNote(paddock.code);

      if (coords == null) continue; // If no coords move to next paddock

      // Convert each coordinate to excel row
      for (final coord in coords) {
        // Add row to list
        excelDataRows.add(
          _createExcelDataRow(
            coordinateModel: coord,
            currentPaddock: paddock,
            currentFarmer: args.currentFarmer,
            timeLimit: gpsTimeLimit.inSeconds,
            paddockNote: note ?? '',
          ),
        );
      }
    }

    return excelDataRows;
  }

  Future<void> _sendEmail(String filePath, String farmerName) async {
    // Fetch emails from remote server
    final remoteConfig = _ref.read(remoteConfigServiceProvider);

    final email = Email(
      subject: 'HEWA Coordinates from $farmerName',
      recipients: ['a.rafaysaleem@gmail.com', remoteConfig.primaryEmail],
      cc: ['rafay.incept@gmail.com', remoteConfig.ccEmail],
      attachmentPaths: [filePath],
    );

    await FlutterEmailSender.send(email);
  }

  Future<io.File> _saveRowsToWorkbook(
    List<ExcelDataRow> rows,
    String farmerName,
  ) async {
    // Create empty sheet
    final workbook = Workbook();

    // Prepare header style to bold
    final headerStyle = CellStyle(workbook)..bold = true;
    workbook.worksheets[0]
      ..getRangeByName('A1:O1').cellStyle =
          headerStyle // Apply header style to all columns
      ..importData(rows, 1, 1); // Fill sheet with excel data rows

    // Convert to bytes and dispose sheet
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    // Create file path
    final path = PathProviderService.path;
    final fileName = defaultTargetPlatform == TargetPlatform.windows
        ? '$path\\$farmerName.xlsx'
        : '$path/$farmerName.xlsx';

    // Create and save file at path
    final file = io.File(fileName);
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  ExcelDataRow _createExcelDataRow({
    required CoordinateModel coordinateModel,
    required PaddockModel currentPaddock,
    required FarmerModel currentFarmer,
    required int timeLimit,
    required String paddockNote,
  }) {
    return ExcelDataRow(
      cells: [
        ExcelDataCell(
          columnHeader: 'Date Time',
          value: coordinateModel.dateTime.toDateString('dd/MM/y hh:mm:ss'),
        ),
        ExcelDataCell(
          columnHeader: 'Latitude',
          value: coordinateModel.latitude,
        ),
        ExcelDataCell(
          columnHeader: 'Longitude',
          value: coordinateModel.longitude,
        ),
        ExcelDataCell(columnHeader: 'Code', value: currentPaddock.code),
        ExcelDataCell(columnHeader: 'Tool', value: coordinateModel.tool),
        ExcelDataCell(columnHeader: 'pkCID', value: currentFarmer.pkCID),
        ExcelDataCell(columnHeader: 'pkSID', value: currentPaddock.fkSID),
        ExcelDataCell(columnHeader: 'Time', value: timeLimit),
        ExcelDataCell(
          columnHeader: 'Accuracy',
          value: coordinateModel.accuracy,
        ),
        ExcelDataCell(
          columnHeader: 'GPS Timestamp',
          value: coordinateModel.dateTime.toDateString('dd/MM/y hh:mm:ss a'),
        ),
        ExcelDataCell(
          columnHeader: 'HorizontalGPSAccuracy',
          value: coordinateModel.horizontaGpsAccuracy,
        ),
        ExcelDataCell(columnHeader: 'Core Note', value: coordinateModel.note),
        ExcelDataCell(
          columnHeader: 'Farmer Name',
          value: '${currentFarmer.first} ${currentFarmer.last}',
        ),
        ExcelDataCell(
          columnHeader: 'Paddocks::Paddock',
          value: currentPaddock.paddock,
        ),
        ExcelDataCell(
          columnHeader: 'Paddocks::Paddock Note',
          value: paddockNote,
        ),
      ],
    );
  }
}
