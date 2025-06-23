import 'package:flutter/foundation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alpha_viewmodel.g.dart';

@riverpod
class AlphaViewModel extends _$AlphaViewModel with ViewModelCore {
 
  @override
  void build() {
    debugPrint('AlphaViewModel build');
  }

  @override
  void onActiveFirst() {
    debugPrint('AlphaViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('AlphaViewModel onActive');
  }

  @override
  void onInActive() {
    debugPrint('AlphaViewModel onInActive');
  }
  @override
  void onPaused() {
    debugPrint('AlphaViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('AlphaViewModel onResumed');
  }

  void closeScreen() {
    ref.read(navigationServiceProvider).goBack();
  }
} 