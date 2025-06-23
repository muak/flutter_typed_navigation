import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'alpha_param_result_viewmodel.g.dart';
part 'alpha_param_result_viewmodel.freezed.dart';

class AlphaParamResult {
  final String message;
  AlphaParamResult(this.message);
}

@freezed
abstract class AlphaParamResultState with _$AlphaParamResultState {
  const factory AlphaParamResultState({
    @Default('') String message,
  }) = _AlphaParamResultState;
}

@riverpod
class AlphaParamResultViewModel extends _$AlphaParamResultViewModel with ViewModelCore {
  @override
  AlphaParamResultState build(AlphaParamResult param) => AlphaParamResultState(message: param.message);

  void closeScreenWithResult(String result) {
    ref.read(navigationServiceProvider).goBackResult(result);
  }
} 