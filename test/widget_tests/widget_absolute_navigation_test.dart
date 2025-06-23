import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widget_test_base.dart';
import 'mocks/widget_mock_viewmodels.dart';

/// Widget Test用Absolute Navigation Tests
/// 実際のNavigationServiceとFlutter Navigatorを使用したテスト
class WidgetAbsoluteNavigationTests extends WidgetTestBase {

  /// 基本的なAbsolute Navigation構築テスト
  Future<void> testBasicAbsoluteNavigation(WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // ナビゲーションサービスが初期化されていることを確認
    expect(navigationService, isNotNull);
    
    // Absolute NavigationBuilder経由で新しいルートを設定
    await navigationService
      .createAbsoluteBuilder()
      .addNavigator((routeBuilder) {
        routeBuilder.addPage<WidgetMockAViewModel>();
      })
      .setRoutes();
    
    await tester.pumpAndSettle();
    
    // Assert - Mock A Screenが表示されている
    expect(find.text('Mock A Screen'), findsOneWidget);
    expect(find.byType(WidgetMockAScreen), findsOneWidget);
    
    // NavigatorObserverのログを確認
    expect(navigationObserver.logs.isNotEmpty, true);
  }

  /// パラメータ付きAbsolute Navigation構築テスト
  Future<void> testAbsoluteNavigationWithParameter(WidgetTester tester) async {
    // Arrange
    final parameter = createTestParameter('Test Parameter Value');
    
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // Act - パラメータ付きでAbsolute NavigationBuilder実行
    await navigationService
      .createAbsoluteBuilder()
      .addNavigator((routeBuilder) {
        routeBuilder
          .addPage<WidgetMockAViewModel>()
          .addPage<WidgetMockBViewModel>(param: parameter);
      })
      .setRoutes();
    
    await tester.pumpAndSettle();
    
    // Assert - Mock B Screenが表示されている
    expect(find.text('Mock B Screen'), findsOneWidget);
    expect(find.text('Parameter: ${parameter.value}'), findsOneWidget);
    
    // ViewModelにパラメータが正しく渡されている
    final viewModel = tester.widget<ProviderScope>(find.byType(ProviderScope)).container
        .read(widgetMockBViewModelProvider(parameter).notifier);
    expect(viewModel.parameters, parameter);
  }

  /// 複数ページのAbsolute Navigation構築テスト
  Future<void> testMultiPageAbsoluteNavigation(WidgetTester tester) async {
    // Arrange
    final paramB = createTestParameter('Parameter for B');
    final paramC = createTestParameter('Parameter for C');
    
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // Act - 複数ページでAbsolute NavigationBuilder実行
    await navigationService
      .createAbsoluteBuilder()
      .addNavigator((routeBuilder) {
        routeBuilder
          .addPage<WidgetMockAViewModel>()
          .addPage<WidgetMockBViewModel>(param: paramB)
          .addPage<WidgetMockCViewModel>(param: paramC);
      })
      .setRoutes();
    
    await tester.pumpAndSettle();
    
    // Assert - 最後のページ（Mock C Screen）が表示されている
    expect(find.text('Mock C Screen'), findsOneWidget);
    expect(find.text('Parameter: ${paramC.value}'), findsOneWidget);
    
    // Back navigationでMock B Screenに戻る
    await tester.tap(find.text('Go Back'));
    await tester.pumpAndSettle();
    
    expect(find.text('Mock B Screen'), findsOneWidget);
    expect(find.text('Parameter: ${paramB.value}'), findsOneWidget);
    
    // もう一度Back navigationでMock A Screenに戻る
    await tester.tap(find.text('Go Back'));
    await tester.pumpAndSettle();
    
    expect(find.text('Mock A Screen'), findsOneWidget);
  }

  /// タブページを含むAbsolute Navigation構築テスト
  Future<void> testAbsoluteNavigationWithTabs(WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // Act - タブページでAbsolute NavigationBuilder実行
    await navigationService
      .createAbsoluteBuilder()
      .addNavigator((routeBuilder) {
        routeBuilder.addTabPage<WidgetMockTabRootViewModel>((tabBuilder) {
          tabBuilder
            .addNavigator((navBuilder) {
              navBuilder.addPage<WidgetMockAViewModel>();
            }, isBuild: true)
            .addNavigator((navBuilder) {
              navBuilder.addPage<WidgetMockBViewModel>(param: createTestParameter('Tab 2 Param'));
            }, isBuild: false)
            .addNavigator((navBuilder) {
              navBuilder.addPage<WidgetMockCViewModel>(param: createTestParameter('Tab 3 Param'));
            }, isBuild: false);
        }, selectedIndex: 0);
      })
      .setRoutes();
    
    await tester.pumpAndSettle();
    
    // Assert - タブページが表示されている
    expect(find.text('Mock Tab Root Screen'), findsOneWidget);
    expect(find.text('Tab 1'), findsOneWidget);
    expect(find.text('Tab 2'), findsOneWidget);
    expect(find.text('Tab 3'), findsOneWidget);
    
    // 最初のタブの内容が表示されている
    expect(find.text('Tab 1 Content'), findsOneWidget);
  }

  /// キャンセル付きAbsolute Navigation構築テスト
  Future<void> testAbsoluteNavigationWithCancel(WidgetTester tester) async {
    // Arrange
    final cancelParameter = createTestParameter('Cancel Test', isCancel: true);
    
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // Act - キャンセル付きパラメータでAbsolute NavigationBuilder実行
    await navigationService
      .createAbsoluteBuilder()
      .addNavigator((routeBuilder) {
        routeBuilder
          .addPage<WidgetMockAViewModel>()
          .addPage<WidgetMockBViewModel>(param: cancelParameter);
      })
      .setRoutes();
    
    await tester.pumpAndSettle();
    
    // Assert - キャンセルされた場合でも画面は表示される
    // ただし、ViewModelの初期化がキャンセルされている
    expect(find.text('Mock B Screen'), findsOneWidget);
    
    final viewModel = tester.widget<ProviderScope>(find.byType(ProviderScope)).container
        .read(widgetMockBViewModelProvider(cancelParameter).notifier);
    
    // ViewModelのアクションログにキャンセルが記録されている
    final actionLog = viewModel.actionLogQueue.toList();
    expect(actionLog.contains('initializeAsyncCancel'), true);
  }
}

void main() {
  group('Widget Absolute Navigation Tests', () {
    final testInstance = WidgetAbsoluteNavigationTests();
    
    setUp(() {
      testInstance.setUpWidgetTest();
    });
    
    tearDown(() {
      testInstance.tearDownWidgetTest();
    });
    
    testWidgets('基本的なAbsolute Navigation構築', (WidgetTester tester) async {
      await testInstance.testBasicAbsoluteNavigation(tester);
    });
    
    testWidgets('パラメータ付きAbsolute Navigation構築', (WidgetTester tester) async {
      await testInstance.testAbsoluteNavigationWithParameter(tester);
    });
    
    testWidgets('複数ページのAbsolute Navigation構築', (WidgetTester tester) async {
      await testInstance.testMultiPageAbsoluteNavigation(tester);
    });
    
    testWidgets('タブページを含むAbsolute Navigation構築', (WidgetTester tester) async {
      await testInstance.testAbsoluteNavigationWithTabs(tester);
    });
    
    testWidgets('キャンセル付きAbsolute Navigation構築', (WidgetTester tester) async {
      await testInstance.testAbsoluteNavigationWithCancel(tester);
    });
  });
}