import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/flutter_typed_navigation.dart';
import '../mocks/test_parameter.dart';
import 'mocks/widget_mock_viewmodels.dart';
import 'mocks/widget_mock_screens.dart';

/// Widget Test用基底クラス
/// 実際のNavigationServiceを使用したテスト環境を提供
abstract class WidgetTestBase {
  late NavigationService navigationService;
  late NavigatorObserver navigationObserver;
  late List<NavigationLog> navigationLogs;
  late ProviderContainer container;
  
  /// テストセットアップ
  void setUpWidgetTest() {
    // NavigatorObserverを初期化
    navigationObserver = TestNavigatorObserver();
    navigationLogs = [];
    
    // ProviderContainerを初期化
    container = ProviderContainer();
    
    // NavigationServiceを取得
    navigationService = container.read(navigationServiceProvider);
    
    // ViewRegistry登録
    _registerTestViews();
  }
  
  /// テスト後のクリーンアップ
  void tearDownWidgetTest() {
    container.dispose();
    navigationLogs.clear();
  }
  
  /// テスト用ViewとViewModelの登録
  void _registerTestViews() {
    // NavigationServiceが利用可能なときに登録実行
    // 実際のWidget Testでは基本的なFlutter Navigatorを使用
  }
  
  /// テスト用のWidgetを構築
  Widget buildTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const WidgetMockAScreen(),
        navigatorObservers: [navigationObserver],
      ),
    );
  }
  
  /// ナビゲーション履歴を検証
  void verifyNavigationHistory(List<String> expectedRoutes) {
    final actualRoutes = navigationLogs.map((log) => log.route).toList();
    expect(actualRoutes, expectedRoutes);
  }
  
  /// 現在のナビゲーションスタックを取得
  List<String> getCurrentNavigationStack() {
    return navigationLogs.where((log) => log.action == 'push').map((log) => log.route).toList();
  }
  
  /// テストパラメータ作成ヘルパー
  TestParameter createTestParameter(String value, {bool isCancel = false}) {
    return TestParameter(value, isCancel: isCancel);
  }
  
  /// ViewModel状態を検証
  void verifyViewModelState(
    WidgetMockViewModelBase viewModel, {
    required bool isActive,
    required bool isDestroyed,
    Object? expectedParameters,
  }) {
    expect(viewModel.isActive, isActive, reason: 'ViewModel.isActive should be $isActive');
    expect(viewModel.isDestroyed, isDestroyed, reason: 'ViewModel.isDestroyed should be $isDestroyed');
    
    if (expectedParameters != null) {
      expect(viewModel.parameters, expectedParameters, reason: 'ViewModel.parameters should match');
    }
  }
  
  /// ViewModel ライフサイクルログを検証
  void verifyActionLog(WidgetMockViewModelBase viewModel, List<String> expectedActions) {
    final actualActions = viewModel.actionLogQueue.toList();
    expect(actualActions, expectedActions, reason: 'ViewModel action log should match expected actions');
  }
}

/// ナビゲーションログ
class NavigationLog {
  final String action;
  final String route;
  final DateTime timestamp;
  
  NavigationLog({
    required this.action,
    required this.route,
    required this.timestamp,
  });
  
  @override
  String toString() => '$action: $route at ${timestamp.toIso8601String()}';
}

/// テスト用NavigatorObserver
class TestNavigatorObserver extends NavigatorObserver {
  final List<NavigationLog> logs = [];
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    logs.add(NavigationLog(
      action: 'push',
      route: route.settings.name ?? 'unknown',
      timestamp: DateTime.now(),
    ));
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    logs.add(NavigationLog(
      action: 'pop',
      route: route.settings.name ?? 'unknown',
      timestamp: DateTime.now(),
    ));
  }
  
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    logs.add(NavigationLog(
      action: 'remove',
      route: route.settings.name ?? 'unknown',
      timestamp: DateTime.now(),
    ));
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    logs.add(NavigationLog(
      action: 'replace',
      route: newRoute?.settings.name ?? 'unknown',
      timestamp: DateTime.now(),
    ));
  }
}