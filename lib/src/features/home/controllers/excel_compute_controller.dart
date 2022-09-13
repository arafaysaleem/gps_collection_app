import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

// Helpers
import '../../../helpers/extensions/datetime_extension.dart';

// Models
import '../models/coordinate_model.codegen.dart';
import '../models/data_export_row_model.dart';
import '../models/farmer_model.codegen.dart';
import '../models/paddock_model.codegen.dart';

// Providers
import '../../../global/all_providers.dart';
import 'coordinates_controller.dart';
import 'farmer_controller.dart';
import 'paddocks_controller.dart';

final excelComputeController = Provider(ExcelComputeController.new);

class _ComputeArgs {
  final FarmerModel farmer;
  final List<PaddockModel> paddocks;
  final Map<String, DataExportRowModel> dataMap;

  _ComputeArgs({
    required this.farmer,
    required this.paddocks,
    required this.dataMap,
  });
}

class ExcelComputeController {
  final Ref _ref;

  ExcelComputeController(this._ref);

  _ComputeArgs _createComputeArgsFromData() {
    final kvStorage = _ref.read(keyValueStorageServiceProvider);
    final args = _ComputeArgs(
      farmer: _ref.read(currentFarmerProvider)!,
      paddocks: [],
      dataMap: <String, DataExportRowModel>{},
    );

    // Loop each paddock
    final paddocks = _ref.read(paddocksController.notifier).getAllPaddocks();
    for (final paddock in paddocks) {
      // Fetch all coordinates of the paddock
      final coords = kvStorage.getPaddockCoordinates(paddock.code);
      if (coords == null) continue;

      // Fetch note of the paddock
      final note = kvStorage.getPaddockNote(paddock.code);

      // add paddock to export data
      args.paddocks.add(paddock);

      // add coords and model to export data
      args.dataMap[paddock.code] = DataExportRowModel(
        coords: coords,
        note: note ?? '',
      );
    }

    return args;
  }

  Future<List<ExcelDataRow>> computeDataToExcelConversion() async {
    // Convert data to be sent to a different isolate
    final args = _createComputeArgsFromData();

    // Perform data to excel conversion in a seperate asynchronous isolate
    return compute(_computeAllDataToExcelRows, args);
  }

  static List<ExcelDataRow> _computeAllDataToExcelRows(_ComputeArgs args) {
    final excelDataRows = <ExcelDataRow>[];

    // Loop each paddock
    for (final paddock in args.paddocks) {
      final exportDataRow = args.dataMap[paddock.code]!;

      // Convert each coordinate to excel row
      for (final coord in exportDataRow.coords) {
        // Add row to list
        excelDataRows.add(
          _createExcelDataRow(
            coordinateModel: coord,
            currentPaddock: paddock,
            currentFarmer: args.farmer,
            timeLimit: gpsTimeLimit.inSeconds,
            paddockNote: exportDataRow.note,
          ),
        );
      }
    }

    return excelDataRows;
  }

  static ExcelDataRow _createExcelDataRow({
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
