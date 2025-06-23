import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'app.dart';
import 'features/viewmodels.dart';
import 'features/screens.dart';

void main() {
  final container = ProviderContainer();
  final navigationService = container.read(navigationServiceProvider);
  navigationService.register((regisgtry) {
    regisgtry
    .register<InitializeViewModel>(initializeViewModelProvider.notifier, () => const InitializeScreen())
    .register<HomeViewModel>(homeViewModelProvider.notifier, () => const HomeScreen())    
    .registerWithParameter<HomeDetailViewModel>((p)=>homeDetailViewModelProvider(p).notifier, (p) => HomeDetailScreen(p))
    .register<SettingsViewModel>(settingsViewModelProvider.notifier, () => const SettingsScreen())
    .register<AccountSettingsViewModel>(accountSettingsViewModelProvider.notifier, () => const AccountSettingsScreen())
    .register<SheetViewModel>(sheetViewModelProvider.notifier, () => const SheetScreen())
    .register<SheetResultViewModel>(sheetResultViewModelProvider.notifier, () => const SheetResultScreen())
    .registerWithParameter<SheetParamViewModel>((p)=>sheetParamViewModelProvider(p).notifier, (p) => SheetParamScreen(param: p))
    .registerWithParameter<SheetParamResultViewModel>((p)=>sheetParamResultViewModelProvider(p).notifier, (p) => SheetParamResultScreen(param: p))
    .register<AlphaViewModel>(alphaViewModelProvider.notifier, () => const AlphaScreen())
    .register<AlphaResultViewModel>(alphaResultViewModelProvider.notifier, () => const AlphaResultScreen())
    .registerWithParameter<AlphaParamViewModel>((p)=>alphaParamViewModelProvider(p).notifier, (p) => AlphaParamScreen(p))
    .registerWithParameter<AlphaParamResultViewModel>((p)=>alphaParamResultViewModelProvider(p).notifier, (p) => AlphaParamResultScreen(param: p))
    .register<BetaViewModel>(betaViewModelProvider.notifier, () => const BetaScreen())
    .registerTab<TabRootViewModel>(tabRootViewModelProvider.notifier, (p) => TabRootScreen(config: p))
    .register<ModalHomeViewModel>(modalHomeViewModelProvider.notifier, () => const ModalHomeScreen())
    .register<ModalAlphaViewModel>(modalAlphaViewModelProvider.notifier, () => const ModalAlphaScreen())
    .registerWithParameter<ModalResultViewModel>((p)=>modalResultViewModelProvider(p).notifier, (p) => ModalResultScreen(p))
    .registerTab<ModalTabViewModel>(modalTabViewModelProvider.notifier, (p) => ModalTabScreen(config: p))
    .register<ModalTabAlphaViewModel>(modalTabAlphaViewModelProvider.notifier, () => const ModalTabAlphaScreen())
    .register<ModalTabAlphaNextViewModel>(modalTabAlphaNextViewModelProvider.notifier, () => const ModalTabAlphaNextScreen())
    .register<ModalTabBetaViewModel>(modalTabBetaViewModelProvider.notifier, () => const ModalTabBetaScreen())
    ;
  });
  navigationService.createAbsoluteBuilder()
    // 全体遷移テスト用ルート
    // .addTabPage<TabRootViewModel>((builder) {
    //   builder
    //   .addNavigator((navBuilder){
    //     navBuilder.addPage<HomeViewModel>()
    //               .addPage<HomeDetailViewModel>(param: HomeDetailParam('Hello'));
    //   }, isBuild: false)
    //   .addNavigator((navBuilder){
    //     navBuilder.addPage<SettingsViewModel>()
    //               .addPage<AccountSettingsViewModel>();
    //   }, isBuild: false);
    // }, selectedIndex: 1, isBuild: false)
    // .addNavigator((navBuilder){
    //   navBuilder.addPage<BetaViewModel>(isBuild: false);
    // }, isBuild: false)
    // 相対遷移テスト用ルート
    .addNavigator((routeBuilder){
      routeBuilder
        .addPage<HomeViewModel>();
    })
    .setRoutes();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(),
    ),
  );
}
