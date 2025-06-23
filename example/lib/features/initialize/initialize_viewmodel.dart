import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import '../home/home_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'initialize_viewmodel.freezed.dart';
part 'initialize_viewmodel.g.dart';

@freezed
abstract class InitializeState with _$InitializeState {
  const factory InitializeState({
    @Default(false) bool isInitialized,
    @Default(true) bool isLoading,
  }) = _InitializeState;
}

// .NET MAUIのViewModel（INotifyPropertyChanged）と同様に状態を管理するが、
// Flutter(Riverpod)ではNotifierを継承し、状態はbuild()で初期化する。
@riverpod
class InitializeViewModel extends _$InitializeViewModel with ViewModelCore {
  late final NavigationService _navigationService;
  @override
  InitializeState build() {
    _navigationService = ref.read(navigationServiceProvider);
    return const InitializeState();
  }

  @override
  void onActiveFirst() {
    _initialize();
  }

  Future<void> _initialize() async {
    // ダミーの初期化処理（2秒待機）
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isInitialized: true, isLoading: false);
    // 初期化が完了したらHome画面に遷移する（スタックをクリア）
    _navigationService.createAbsoluteBuilder()
    .addNavigator((builder) {
      builder.addPage<HomeViewModel>(param: HomeParameter(message: 'Hello'));
    })
    .setRoutes();
  }
} 