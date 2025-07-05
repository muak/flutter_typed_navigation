import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';

class NavigationApp extends MaterialApp{
  final WidgetRef ref;

  NavigationApp({
    required this.ref,
    super.key,
    super.scaffoldMessengerKey,    
    super.builder,
    super.title,
    super.onGenerateTitle,
    super.color,
    super.theme,
    super.darkTheme,
    super.highContrastTheme,
    super.highContrastDarkTheme,
    super.themeMode = ThemeMode.system,
    super.themeAnimationDuration = kThemeAnimationDuration,
    super.themeAnimationCurve = Curves.linear,
    super.locale,
    super.localizationsDelegates,
    super.localeListResolutionCallback,
    super.localeResolutionCallback,
    super.supportedLocales = const <Locale>[Locale('en', 'US')],
    super.debugShowMaterialGrid = false,
    super.showPerformanceOverlay = false,
    super.checkerboardRasterCacheImages = false,
    super.checkerboardOffscreenLayers = false,
    super.showSemanticsDebugger = false,
    super.debugShowCheckedModeBanner = true,
    super.shortcuts,
    super.actions,
    super.restorationScopeId,
    super.scrollBehavior,
    super.useInheritedMediaQuery = false,
    super.themeAnimationStyle
  }) : super.router(
    routerDelegate: ref.read(navigationRouterDelegateProvider),
    backButtonDispatcher: RootBackButtonDispatcher(),
    onNavigationNotification: _defaultOnNavigationNotification
  );
}

// システムバックでアプリを終了させないためのハック
// https://stackoverflow.com/a/79137159
bool _defaultOnNavigationNotification(NavigationNotification _) {
  switch (WidgetsBinding.instance.lifecycleState) {
    case null:
    case AppLifecycleState.detached:
    case AppLifecycleState.inactive:
    // Avoid updating the engine when the app isn't ready.
      return true;
    case AppLifecycleState.resumed:
    case AppLifecycleState.hidden:
    case AppLifecycleState.paused:
      SystemNavigator.setFrameworkHandlesBack(true); /// This must be `true` instead of `notification.canHandlePop`, otherwise application closes on back gesture.
      return true;
  }
}