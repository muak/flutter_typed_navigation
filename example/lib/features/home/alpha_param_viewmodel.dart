import 'package:flutter/foundation.dart';
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
    debugPrint('AlphaParamViewModel build');
    return AlphaParamState(message: param.message);
  }

  @override
  void onActiveFirst() {
    debugPrint('AlphaParamViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('AlphaParamViewModel onActive');
  }

  @override
  void onInActive() {
    debugPrint('AlphaParamViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('AlphaParamViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('AlphaParamViewModel onResumed');
  }

  void closeScreen() {
    ref.read(navigationServiceProvider).goBack();
  }
}