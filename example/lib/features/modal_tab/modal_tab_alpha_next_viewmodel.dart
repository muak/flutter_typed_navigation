import 'package:flutter/foundation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'modal_tab_alpha_next_viewmodel.g.dart';

@riverpod
class ModalTabAlphaNextViewModel extends _$ModalTabAlphaNextViewModel with ViewModelCore {
  @override
  void build() {
    debugPrint('ModalTabAlphaNextViewModel build');
  }

    @override
  void onActiveFirst() {
    debugPrint('ModalTabAlphaNextViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('ModalTabAlphaNextViewModel onActive');
  }
  @override
  void onInActive() {
    debugPrint('ModalTabAlphaNextViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('ModalTabAlphaNextViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('ModalTabAlphaNextViewModel onResumed');
  }  

  void goBack() {
    ref.read(navigationServiceProvider).goBack();
  }

  void closeScreen() {
    ref.read(navigationServiceProvider).closeModalResult('ModalTabAlphaNext');
  }
} 