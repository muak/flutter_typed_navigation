import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'modal_result_viewmodel.g.dart';
part 'modal_result_viewmodel.freezed.dart';

@freezed
abstract class ModalResultState with _$ModalResultState {
  const factory ModalResultState({
    @Default('') String message,
  }) = _ModalResultState;
}

@riverpod
class ModalResultViewModel extends _$ModalResultViewModel with ViewModelCore {
  @override
  ModalResultState build(String param) {
    debugPrint('ModalResultViewModel build: $param');
    return ModalResultState(message: param);
  }

    @override
  void onActiveFirst() {
    debugPrint('ModalResultViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('ModalResultViewModel onActive');
  }
  @override
  void onInActive() {
    debugPrint('ModalResultViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('ModalResultViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('ModalResultViewModel onResumed');
  }  

  void closeScreen() {
    ref.read(navigationServiceProvider).closeModalResult('ModalResultViewModel Back Result');
  }
} 