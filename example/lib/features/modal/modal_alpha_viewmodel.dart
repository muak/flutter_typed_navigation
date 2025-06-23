import 'package:flutter/foundation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'modal_alpha_viewmodel.g.dart';

@riverpod
class ModalAlphaViewModel extends _$ModalAlphaViewModel with ViewModelCore {
  @override
  void build() {
    debugPrint('ModalAlphaViewModel build');
  }

    @override
  void onActiveFirst() {
    debugPrint('ModalAlphaViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('ModalAlphaViewModel onActive');
  }
  @override
  void onInActive() {
    debugPrint('ModalAlphaViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('ModalAlphaViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('ModalAlphaViewModel onResumed');
  }  

  void goBack() {
    ref.read(navigationServiceProvider).goBack();
  }

  void closeScreen() {
    ref.read(navigationServiceProvider).closeModal();
  }
} 