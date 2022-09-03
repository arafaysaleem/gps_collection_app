// ignore_for_file: unused_import

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../../helpers/typedefs.dart';

part 'farmer_model.codegen.freezed.dart';
part 'farmer_model.codegen.g.dart';

@freezed
class FarmerModel with _$FarmerModel {
  const factory FarmerModel({
    @JsonKey(name: 'pkCID') required String pkCID,
    @JsonKey(name: 'First') required String first,
    @JsonKey(name: 'Last') required String last,
  }) = _FarmerModel;

  factory FarmerModel.fromJson(JSON json) => _$FarmerModelFromJson(json);
}
