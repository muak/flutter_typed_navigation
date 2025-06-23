import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/src/navigation_service.dart';
import '../mocks/test_parameter.dart';
import '../mocks/mock_viewmodels/mock_viewmodel_base.dart';

/// テスト用ベースクラス
/// MAUI版のNavigationFixtureBaseと同等の機能を提供
abstract class TestBase {
  late ProviderContainer container;
  late NavigationService navigationService;

  /// テストセットアップ
  void setUpTest() {
    MockViewModelBase.clearCallVmStack();
    
    container = ProviderContainer();
    navigationService = container.read(navigationServiceProvider);
  }

  /// テストクリーンアップ
  void tearDownTest() {
    container.dispose();
  }

  /// テストパラメータを作成
  TestParameter createTestParameter(String value, {bool isCancel = false}) {
    return TestParameter(value, isCancel: isCancel);
  }

  /// MockViewModelを取得
  T getMockViewModel<T extends MockViewModelBase>() {
    return MockViewModelBase.callVmStack
        .whereType<T>()
        .last;
  }

  /// 全てのMockViewModelをクリア
  void clearMockViewModels() {
    MockViewModelBase.clearCallVmStack();
  }

  /// Widget テストの基本設定
  Widget createTestApp({required Widget child}) {
    return ProviderScope(
      overrides: [],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// アクションログを検証
  void verifyActionLog(MockViewModelBase viewModel, List<String> expectedActions) {
    expect(viewModel.actionLogQueue.length, expectedActions.length);
    
    for (int i = 0; i < expectedActions.length; i++) {
      expect(
        viewModel.actionLogQueue.removeFirst(), 
        expectedActions[i],
        reason: 'Action at index $i should be ${expectedActions[i]}'
      );
    }
  }

  /// ViewModelの状態を検証
  void verifyViewModelState(
    MockViewModelBase viewModel, {
    required bool isActive,
    required bool isDestroyed,
    Object? expectedParameters,
  }) {
    expect(viewModel.isActive, isActive, reason: 'isActive should be $isActive');
    expect(viewModel.isDestroyed, isDestroyed, reason: 'isDestroyed should be $isDestroyed');
    
    if (expectedParameters != null) {
      expect(viewModel.parameters, expectedParameters, reason: 'parameters should match');
    }
  }
}