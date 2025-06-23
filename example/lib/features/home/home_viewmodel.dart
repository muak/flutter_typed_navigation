import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import '../viewmodels.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.freezed.dart';
part 'home_viewmodel.g.dart';

class HomeParameter {
  final String? message;
  HomeParameter({this.message});
}

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default('Unknown') String platformVersion,
    @Default(true) bool isLoading,
    @Default('') String error,
  }) = _HomeState;
}

// .NET MAUIのViewModel（INotifyPropertyChanged）と同様に状態を管理するが、
// Flutter(Riverpod)ではNotifierを継承し、状態はbuild()で初期化する。
@riverpod
class HomeViewModel extends _$HomeViewModel with ViewModelCore {
  // final _ksAppCorePlugin = KsAppCore(); // Removed ks_app_core dependency
  late final NavigationService _navigationService;
  @override
  HomeState build() {
    debugPrint('HomeViewModel build');
    _navigationService = ref.read(navigationServiceProvider);
    return const HomeState();
  }

  @override
  void onActiveFirst() {
    debugPrint('HomeViewModel onActiveFirst');
    loadPlatformVersion();
  }

  @override
  void onActive() {
    debugPrint('HomeViewModel onActive');
  }

  @override
  void onInActive() {
    debugPrint('HomeViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('HomeViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('HomeViewModel onResumed');
  }

  Future<void> loadPlatformVersion() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final version = 'Flutter Example App'; // Removed ks_app_core dependency
      state = state.copyWith(platformVersion: version, isLoading: false);
    } on PlatformException {
      state = state.copyWith(
          platformVersion: 'Failed to get platform version.', isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void absoluteNavigate() {
    _navigationService.createAbsoluteBuilder().addTabPage<TabRootViewModel>(
        (builder) {
      builder.addNavigator((navBuilder) {
        navBuilder
            .addPage<HomeViewModel>()
            .addPage<HomeDetailViewModel>(param: HomeDetailParam('Hello'));
      }, isBuild: false).addNavigator((navBuilder) {
        navBuilder
            .addPage<SettingsViewModel>()
            .addPage<AccountSettingsViewModel>();
      }, isBuild: false);
    }, selectedIndex: 1, isBuild: false).setRoutes();
  }

  Future<void> navigateAlphaResult() async {
    final result = await _navigationService
        .createRelativeBuilder()
        .addPage<AlphaResultViewModel>()
        .navigateResult<String>();
    debugPrint('AlphaResult: result=$result');
  }

  Future<void> showSheet() async {
    await _navigationService.showBottomSheet<SheetViewModel>();
  }

  Future<void> showSheetResult() async {
    final result = await _navigationService
        .showBottomSheetResult<SheetResultViewModel, String>();
    debugPrint('SheetResult: result=$result');
  }

  Future<void> showSheetParam() async {
    await _navigationService.showBottomSheetWithParameter<SheetParamViewModel,
        SheetParam>(SheetParam('パラメータ渡しテスト'));
  }

  Future<void> showSheetParamResult() async {
    final result = await _navigationService.showBottomSheetWithParameterResult<
        SheetParamResultViewModel,
        SheetParamResult,
        String>(SheetParamResult('パラメータ+戻り値テスト'));
    debugPrint('SheetParamResult: result=$result');
  }

  Future<void> navigateAlpha() async {
    await _navigationService
        .createRelativeBuilder()
        .addPage<AlphaViewModel>()
        // .addPage<BetaViewModel>()
        .navigate();
  }

  Future<void> navigateAlphaParam() async {
    await _navigationService
        .createRelativeBuilder()
        .addPage<AlphaParamViewModel>(param: AlphaParam('AlphaParamテスト'))
        .navigate();
  }

  Future<void> navigateAlphaParamResult() async {
    final result = await _navigationService
        .createRelativeBuilder()
        .addPage<AlphaParamResultViewModel>(
            param: AlphaParamResult('AlphaParamResultテスト'))
        .navigateResult<String>();
    debugPrint('AlphaParamResult: result=$result');
  }

  Future<void> navigateModal() async {
    await _navigationService.createRelativeBuilder().addNavigator((navBuilder) {
      navBuilder.addPage<ModalHomeViewModel>().addPage<ModalAlphaViewModel>();
    }).navigate();
  }

  Future<void> navigateModalResult() async {
    final result = await _navigationService
        .createRelativeBuilder()
        .addNavigator((navBuilder) {
      navBuilder.addPage<ModalResultViewModel>(param: 'ModalResultテスト');
    }).navigateResult<String>();
    debugPrint('ModalResult: result=$result');
  }

  Future<void> navigateModalTab() async {
    final result = await _navigationService
      .createRelativeBuilder()
      .addTabPage<ModalTabViewModel>((tabBuilder) {
        tabBuilder
          .addNavigator((navBuilder) {
            navBuilder
              .addPage<ModalTabAlphaViewModel>()
              .addPage<ModalTabAlphaNextViewModel>();
          }, isBuild: false)
          .addNavigator((navBuilder) {
            navBuilder
              .addPage<ModalTabBetaViewModel>();
          }, isBuild: false);
    }, selectedIndex: 0)
    .navigateResult<String>();
    debugPrint('ModalTab: result=$result');
  }
}
