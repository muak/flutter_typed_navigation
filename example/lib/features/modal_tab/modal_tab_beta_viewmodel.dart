import 'package:flutter/foundation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'modal_tab_beta_viewmodel.g.dart';

@riverpod
class ModalTabBetaViewModel extends _$ModalTabBetaViewModel with ViewModelCore {
  @override
  void build() {
    debugPrint('ModalTabBetaViewModel build');
  }

    @override
  void onActiveFirst() {
    debugPrint('ModalTabBetaViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('ModalTabBetaViewModel onActive');
  }
  @override
  void onInActive() {
    debugPrint('ModalTabBetaViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('ModalTabBetaViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('ModalTabBetaViewModel onResumed');
  }  

  void closeScreen() {
    ref.read(navigationServiceProvider).closeModalResult('ModalTabBeta');
  }
} 