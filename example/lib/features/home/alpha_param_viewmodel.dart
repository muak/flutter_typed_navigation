import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';

part 'alpha_param_viewmodel.g.dart';
part 'alpha_param_viewmodel.freezed.dart';

class AlphaParam {
  final String message;
  AlphaParam(this.message);
}

@freezed
abstract class AlphaParamState with _$AlphaParamState {
  const factory AlphaParamState({
    @Default('') String message,
  }) = _AlphaParamState;
}

@riverpod
class AlphaParamViewModel extends _$AlphaParamViewModel with ViewModelCore {
  @override
  AlphaParamState build(AlphaParam param) {
    return AlphaParamState(message: param.message);
  }

  void closeScreen() {
    ref.read(navigationServiceProvider).goBack();
  }
}