import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/sampling_mode.dart';

part 'sampling_state.codegen.freezed.dart';

@freezed
class SamplingState with _$SamplingState {
  const factory SamplingState.idle() = IDLE;

  const factory SamplingState.loading() = LOADING;

  const factory SamplingState.done(SamplingMode currentSampling) = DONE;

  const factory SamplingState.failed({required String reason}) = FAILED;
}
