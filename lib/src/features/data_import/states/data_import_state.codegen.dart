import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_import_state.codegen.freezed.dart';

@freezed
class DataImportState with _$DataImportState {
  const factory DataImportState.idle() = IDLE;

  const factory DataImportState.loading() = LOADING;

  const factory DataImportState.done() = DONE;

  const factory DataImportState.failed({required String reason}) = FAILED;
}
