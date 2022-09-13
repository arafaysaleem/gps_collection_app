import 'coordinate_model.codegen.dart';

class DataExportRowModel {
  final List<CoordinateModel> coords;
  final String note;

  DataExportRowModel({
    required this.coords,
    required this.note,
  });
}
