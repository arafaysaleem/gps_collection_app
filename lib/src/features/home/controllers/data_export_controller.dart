import 'dart:io' as io;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

// Providers
import '../../../core/local/path_provider_service.dart';
import '../../../global/all_providers.dart';
import 'excel_compute_controller.dart';
import 'farmer_controller.dart';

// States
import '../../../global/states/future_state.codegen.dart';

final dataExportController =
    StateNotifierProvider<DataExportController, FutureState<bool>>((ref) {
  return DataExportController(ref);
});

class DataExportController extends StateNotifier<FutureState<bool>> {
  final Ref _ref;

  DataExportController(this._ref) : super(const FutureState.idle());

  Future<File> _exportCoordinatesToExcel(String farmerName) async {
    // Convert data to excel rows asynchronously
    final excelDataRows = await _ref
        .read(
          excelComputeController,
        )
        .computeDataToExcelConversion();

    // Create an excel sheet using the previous rows
    final file = await _saveRowsToWorkbook(excelDataRows, farmerName);

    return file;
  }

  Future<void> sendEmail() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    state = const FutureState.loading();

    // Load current farmer
    final farmerName = _ref.read(currentFarmerProvider)!.fullName;

    state = await FutureState.makeGuardedRequest(
      () async {
        final file = await _exportCoordinatesToExcel(farmerName);

        // Fetch emails from remote server
        final remoteConfig = _ref.read(remoteConfigServiceProvider);
        await remoteConfig.fetchAndActivate();

        final email = Email(
          subject: 'HEWA Coordinates from $farmerName',
          recipients: [remoteConfig.primaryEmail],
          cc: [remoteConfig.ccEmail],
          attachmentPaths: [file.path],
        );
        await FlutterEmailSender.send(email);
        return false;
      },
      errorMessage: 'Failed to export and email data',
    );
  }

  Future<void> downloadFile() async {
    state = const FutureState.loading();

    // Load current farmer
    final farmerName = _ref.read(currentFarmerProvider)!.fullName;

    state = await FutureState.makeGuardedRequest(
      () async {
        // await _requestStoragePermissions();
        await _exportCoordinatesToExcel(farmerName);
        return true;
      },
      errorMessage: 'Failed to export and download data',
    );
  }

  Future<io.File> _saveRowsToWorkbook(
    List<ExcelDataRow> rows,
    String farmerName,
  ) async {
    await _requestStoragePermissions();

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
    const path = PathProviderService.downloads;
    final fileName = defaultTargetPlatform == TargetPlatform.windows
        ? '$path\\$farmerName.xlsx'
        : '$path/$farmerName.xlsx';

    // Create and save file at path
    final file = io.File(fileName);
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  Future<void> _requestStoragePermissions() async {
    var permission = await Permission.storage.status;
    if (permission.isGranted) return;
    final android = await DeviceInfoPlugin().androidInfo;
    if (android.version.sdkInt >= 33) return;

    permission = await Permission.storage.request();
    if (permission.isGranted) {
      return;
    } else if (permission.isDenied) {
      permission = await Permission.storage.request();
      if (permission.isDenied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        throw Exception('Storage permissions are denied');
      }
    } else if (permission.isPermanentlyDenied) {
      // Permission is permanently denied, take user to app settings
      final openPermSettings = await openAppSettings();
      if (!openPermSettings) {
        throw Exception(
          'Storage permissions are permanently denied, we cannot request permissions.',
        );
      }
    }
  }
}
