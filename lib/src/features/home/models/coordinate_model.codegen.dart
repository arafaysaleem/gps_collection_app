// ignore_for_file: unused_import

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../../helpers/typedefs.dart';

part 'coordinate_model.codegen.freezed.dart';
part 'coordinate_model.codegen.g.dart';

@freezed
class CoordinateModel with _$CoordinateModel {
  const factory CoordinateModel({
    @JsonKey(name: 'Note') required String note,
    @JsonKey(name: 'Latitude') required double latitude,
    @JsonKey(name: 'Longitude') required double longitude,
    @JsonKey(name: 'Tool') required String tool,
    @JsonKey(name: 'Code') required String paddockCode,
    @JsonKey(name: 'Date Time') required DateTime dateTime,
    @JsonKey(name: 'Accuracy') required int accuracy,
    @JsonKey(name: 'HorizontalGPSAccuracy') required int horizontaGpsAccuracy,
  }) = _CoordinateModel;

  factory CoordinateModel.fromJson(JSON json) => _$CoordinateModelFromJson(json);
}
