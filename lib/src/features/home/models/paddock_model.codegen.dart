// ignore_for_file: unused_import

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../../helpers/typedefs.dart';

part 'paddock_model.codegen.freezed.dart';
part 'paddock_model.codegen.g.dart';

@freezed
class PaddockModel with _$PaddockModel {
  const factory PaddockModel({
    @JsonKey(name: 'fkCID') required String farmerId,
    @JsonKey(name: 'Code') required String code,
    @JsonKey(name: 'Paddock') required String paddock,
    @JsonKey(name: 'CRIS_ID') String? propertyId,
    @JsonKey(name: 'fkSID') String? fkSID,
  }) = _PaddockModel;

  factory PaddockModel.fromJson(JSON json) => _$PaddockModelFromJson(json);
}
