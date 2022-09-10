import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

// Providers
import '../../../core/local/path_provider_service.dart';
import '../../../global/all_providers.dart';
import 'coordinates_controller.dart';
import 'farmer_controller.dart';
import 'paddocks_controller.dart';

// Helpers
import '../../../helpers/extensions/datetime_extension.dart';

// Models
import '../models/coordinate_model.codegen.dart';
import '../models/farmer_model.codegen.dart';
import '../models/paddock_model.codegen.dart';

final dataExportController = Provider<DataExportController>((ref) {
  return DataExportController(ref);
});

class DataExportController {
  final Ref _ref;

  DataExportController(this._ref);

  Future<void> exportCoordinatesToExcel() async {
    final excelDataRows = <ExcelDataRow>[];

    final paddocks = _ref.read(paddocksController.notifier).getAllPaddocks();
    final currentFarmer = _ref.read(currentFarmerProvider)!;

    for (final paddock in paddocks) {
      final coords = _ref
          .read(keyValueStorageServiceProvider)
          .getPaddockCoordinates(paddock.code);
      if (coords == null) continue;
      for (final coord in coords) {
        // Add row
        excelDataRows.add(
          _createExcelDataRow(
            coordinateModel: coord,
            currentPaddock: paddock,
            currentFarmer: currentFarmer,
            timeLimit: gpsTimeLimit.inSeconds,
            paddockNote: _ref.read(coreNoteProvider),
          ),
        );
      }
    }

    final file = await _saveRowsToWorkbook(
      excelDataRows,
      currentFarmer.fullName,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _sendEmail(file.path);
    }
  }

  Future<void> _sendEmail(String filePath) async {
    final farmerName = _ref.read(currentFarmerProvider)!.fullName;
    final email = Email(
      subject: 'HEWA Coordinates from $farmerName',
      recipients: ['a.rafaysaleem@gmail.com'],
      cc: ['rafay.incept@gmail.com'],
      attachmentPaths: [filePath],
    );

    await FlutterEmailSender.send(email);
  }

  Future<io.File> _saveRowsToWorkbook(
    List<ExcelDataRow> rows,
    String farmerName,
  ) async {
    final workbook = Workbook();
    final headerStyle = CellStyle(workbook)..bold = true;

    workbook.worksheets[0]
      ..getRangeByName('A1:O1').cellStyle = headerStyle
      ..importData(rows, 1, 1);
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final path = PathProviderService.path;
    final fileName = defaultTargetPlatform == TargetPlatform.windows
        ? '$path\\$farmerName.xlsx'
        : '$path/$farmerName.xlsx';
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
