import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

// Providers
import '../../../core/local/path_provider_service.dart';
import '../../../global/all_providers.dart';
import 'excel_compute_controller.dart';
import 'farmer_controller.dart';

// States
import '../../../global/states/future_state.codegen.dart';

final dataExportController =
    StateNotifierProvider<DataExportController, FutureState<void>>((ref) {
  return DataExportController(ref);
});

class DataExportController extends StateNotifier<FutureState<void>> {
  final Ref _ref;

  DataExportController(this._ref) : super(const FutureState.idle());

  Future<void> exportCoordinatesToExcel() async {
    state = const FutureState.loading();

    // Load current farmer
    final currentFarmer = _ref.read(currentFarmerProvider)!;

    state = await FutureState.makeGuardedRequest(
      () async {
        // Convert data to excel rows asynchronously
        final excelDataRows = await _ref
            .read(excelComputeController)
            .computeDataToExcelConversion();

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

  Future<void> _sendEmail(String filePath, String farmerName) async {
    // Fetch emails from remote server
    final remoteConfig = _ref.read(remoteConfigServiceProvider);
    await remoteConfig.fetchAndActivate();

    final email = Email(
      subject: 'HEWA Coordinates from $farmerName',
      recipients: [remoteConfig.primaryEmail],
      cc: [remoteConfig.ccEmail],
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
}
