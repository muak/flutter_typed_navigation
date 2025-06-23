import 'package:flutter/foundation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import '..//modal/modal_alpha_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'modal_home_viewmodel.g.dart';

@riverpod
class ModalHomeViewModel extends _$ModalHomeViewModel with ViewModelCore {
  @override
  void build() {
    debugPrint('ModalHomeViewModel build');
  }

    @override
  void onActiveFirst() {
    debugPrint('ModalHomeViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('ModalHomeViewModel onActive');
  }
  @override
  void onInActive() {
    debugPrint('ModalHomeViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('ModalHomeViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('ModalHomeViewModel onResumed');
  }  

  void closeScreen() {
    ref.read(navigationServiceProvider).closeModal();
  }

  void navigateAlpha() {
    ref.read(navigationServiceProvider).createRelativeBuilder()
    .addPage<ModalAlphaViewModel>()
    .navigate();
  }
} 