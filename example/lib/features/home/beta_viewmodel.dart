import 'package:flutter/foundation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'beta_viewmodel.g.dart';

@riverpod
class BetaViewModel extends _$BetaViewModel with ViewModelCore {
  @override
  void build() {
    debugPrint('BetaViewModel build');
  }

    @override
  void onActiveFirst() {
    debugPrint('BetaViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('BetaViewModel onActive');
  }
  @override
  void onInActive() {
    debugPrint('BetaViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('BetaViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('BetaViewModel onResumed');
  }

  void navigateAlpha() {
    // ref.read(navigationServiceProvider).navigate<AlphaViewModel>();
  }
  void goBack() {
    ref.read(navigationServiceProvider).goBack();
  }

  void closeScreen() {
    ref.read(navigationServiceProvider).closeModal();
  }
} 