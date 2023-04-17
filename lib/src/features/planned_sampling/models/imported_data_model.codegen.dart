// ignore_for_file: unused_import

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../../helpers/typedefs.dart';
import '../../home/models/farmer_model.codegen.dart';
import '../../home/models/paddock_model.codegen.dart';

part 'imported_data_model.codegen.freezed.dart';
part 'imported_data_model.codegen.g.dart';

@freezed
class ImportedDataModel with _$ImportedDataModel {

  const factory ImportedDataModel({
    required FarmerModel farmer,
    required List<PaddockModel> paddocks,
  }) = _ImportedDataModel;
  
  factory ImportedDataModel.fromJson(JSON json) => _$ImportedDataModelFromJson(json);
}
