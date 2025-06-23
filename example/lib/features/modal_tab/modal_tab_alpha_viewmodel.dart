import 'package:flutter/foundation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import '..//modal_tab/modal_tab_alpha_next_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'modal_tab_alpha_viewmodel.g.dart';

@riverpod
class ModalTabAlphaViewModel extends _$ModalTabAlphaViewModel with ViewModelCore {
  @override
  void build() {
    debugPrint('ModalTabAlphaViewModel build');
  }

    @override
  void onActiveFirst() {
    debugPrint('ModalTabAlphaViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('ModalTabAlphaViewModel onActive');
  }
  @override
  void onInActive() {
    debugPrint('ModalTabAlphaViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('ModalTabAlphaViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('ModalTabAlphaViewModel onResumed');
  }  

  void goNext() {
    ref.read(navigationServiceProvider).createRelativeBuilder()
    .addPage<ModalTabAlphaNextViewModel>()
    .navigate();
  }

  void closeScreen() {
    ref.read(navigationServiceProvider).closeModalResult('ModalTabAlpha');
  }
} 