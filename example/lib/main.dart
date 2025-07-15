import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'app.dart';
import 'features/viewmodels.dart';
import 'features/screens.dart';
import 'auto_register.g.dart';

void main() {
  final container = ProviderContainer();
  final navigationService = container.read(navigationServiceProvider);
  navigationService.register((regisgtry) {
    // 自動生成されたコードを使用
    regisgtry.registerAuto();
    
    // 残りの手動登録
    regisgtry
    .registerWithParameter<HomeDetailViewModel>((p) => HomeDetailScreen(p), (p)=>homeDetailViewModelProvider(p).notifier)
    .register<SettingsViewModel>(() => const SettingsScreen(), settingsViewModelProvider.notifier)
    .register<AccountSettingsViewModel>(() => const AccountSettingsScreen(), accountSettingsViewModelProvider.notifier)
    .register<SheetViewModel>(() => const SheetScreen(), sheetViewModelProvider.notifier)
    .register<SheetResultViewModel>(() => const SheetResultScreen(), sheetResultViewModelProvider.notifier)
    .registerWithParameter<SheetParamViewModel>((p) => SheetParamScreen(param: p), (p)=>sheetParamViewModelProvider(p).notifier)
    .registerWithParameter<SheetParamResultViewModel>((p) => SheetParamResultScreen(param: p), (p)=>sheetParamResultViewModelProvider(p).notifier)
    .register<AlphaResultViewModel>(() => const AlphaResultScreen(), alphaResultViewModelProvider.notifier)
    .registerWithParameter<AlphaParamResultViewModel>((p) => AlphaParamResultScreen(param: p), (p)=>alphaParamResultViewModelProvider(p).notifier)
    .register<BetaViewModel>(() => const BetaScreen(), betaViewModelProvider.notifier)
    .register<ModalHomeViewModel>(() => const ModalHomeScreen(), modalHomeViewModelProvider.notifier)
    .register<ModalAlphaViewModel>(() => const ModalAlphaScreen(), modalAlphaViewModelProvider.notifier)
    .registerWithParameter<ModalResultViewModel>((p) => ModalResultScreen(p), (p)=>modalResultViewModelProvider(p).notifier)
    .registerTab<ModalTabViewModel>((p) => ModalTabScreen(config: p), modalTabViewModelProvider.notifier)
    .register<ModalTabAlphaViewModel>(() => const ModalTabAlphaScreen(), modalTabAlphaViewModelProvider.notifier)
    .register<ModalTabAlphaNextViewModel>(() => const ModalTabAlphaNextScreen(), modalTabAlphaNextViewModelProvider.notifier)
    .register<ModalTabBetaViewModel>(() => const ModalTabBetaScreen(), modalTabBetaViewModelProvider.notifier)
    ;
  });
  navigationService.createAbsoluteBuilder()
    // 全体遷移テスト用ルート
    .addTabPage<TabRootViewModel>(
      (builder) {
        builder.addNavigator(
          (navBuilder) {
            navBuilder
              .addPage<HomeViewModel>()
              .addPage<HomeDetailViewModel>(param: HomeDetailParam('Hello'));
          }, isLazy: true)
          .addNavigator(
          (navBuilder) {
            navBuilder
                .addPage<SettingsViewModel>()
                .addPage<AccountSettingsViewModel>();
          }, isLazy: true);
      }, selectedIndex: 1, isLazy: true)
    .addNavigator(
      (navBuilder) {
        navBuilder.addPage<BetaViewModel>(isLazy: true);
      }, isLazy: true)
    // 相対遷移テスト用ルート
    // .addNavigator((routeBuilder){
    //   routeBuilder
    //     .addPage<HomeViewModel>();
    // })
    .setRoutes();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}
