import 'package:flutter/foundation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'account_settings_viewmodel.g.dart';
@riverpod
class AccountSettingsViewModel extends _$AccountSettingsViewModel with ViewModelCore {
  @override
  void build() {
    debugPrint('AccountSettingsViewModel build');
  }

    @override
  void onActiveFirst() {
    debugPrint('AccountSettingsViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('AccountSettingsViewModel onActive');
  }
  @override
  void onInActive() {
    debugPrint('AccountSettingsViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('AccountSettingsViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('AccountSettingsViewModel onResumed');
  }
} 