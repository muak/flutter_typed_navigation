import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'settings_viewmodel.freezed.dart';
part 'settings_viewmodel.g.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isDarkMode,
  }) = _SettingsState;
}

// .NET MAUIのViewModel（INotifyPropertyChanged）と同様に状態を管理するが、
// Flutter(Riverpod)ではNotifierを継承し、状態はbuild()で初期化する。
@riverpod
class SettingsViewModel extends _$SettingsViewModel with ViewModelCore {
  @override
  SettingsState build() {
    debugPrint('SettingsViewModel build');
    return const SettingsState();
  }

  @override
  void onActiveFirst() {
    debugPrint('SettingsViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('SettingsViewModel onActive');
  }
  @override
  void onInActive() {
    debugPrint('SettingsViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('SettingsViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('SettingsViewModel onResumed');
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }
} 