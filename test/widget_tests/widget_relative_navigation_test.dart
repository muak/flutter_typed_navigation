import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widget_test_base.dart';
import 'mocks/widget_mock_viewmodels.dart';
import 'mocks/widget_mock_screens.dart';

/// Widget Test用Relative Navigation Tests
/// 実際のNavigationServiceとFlutter Navigatorを使用したテスト
class WidgetRelativeNavigationTests extends WidgetTestBase {

  /// 基本的なRelative Navigation遷移テスト
  Future<void> testBasicRelativeNavigation(WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // Act - RelativeNavigationBuilderでページ遷移
    await navigationService
      .createRelativeBuilder()
      .addPage<WidgetMockBViewModel>(param: createTestParameter('Test Param'))
      .navigate();
    
    await tester.pumpAndSettle();
    
    // Assert - Mock B Screenが表示されている
    expect(find.text('Mock B Screen'), findsOneWidget);
    expect(find.text('Parameter: Test Param'), findsOneWidget);
  }

  /// Forward/Back Navigationのテスト
  Future<void> testForwardBackNavigation(WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // Act 1 - Mock Bに遷移
    await navigationService
      .createRelativeBuilder()
      .addPage<WidgetMockBViewModel>(param: createTestParameter('Test Param B'))
      .navigate();
    
    await tester.pumpAndSettle();
    expect(find.text('Mock B Screen'), findsOneWidget);
    
    // Act 2 - Mock Cに遷移
    await navigationService
      .createRelativeBuilder()
      .addPage<WidgetMockCViewModel>(param: createTestParameter('Test Param C'))
      .navigate();
    
    await tester.pumpAndSettle();
    expect(find.text('Mock C Screen'), findsOneWidget);
    
    // Act 3 - Backで戻る
    await tester.tap(find.text('Go Back'));
    await tester.pumpAndSettle();
    
    // Assert - Mock B Screenに戻っている
    expect(find.text('Mock B Screen'), findsOneWidget);
    expect(find.text('Parameter: Test Param B'), findsOneWidget);
    
    // Act 4 - もう一度Backで戻る
    await tester.tap(find.text('Go Back'));
    await tester.pumpAndSettle();
    
    // Assert - Mock A Screenに戻っている
    expect(find.text('Mock A Screen'), findsOneWidget);
  }

  /// 結果取得ナビゲーションのテスト
  Future<void> testResultNavigation(WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // Act - 結果取得ナビゲーション
    final resultFuture = navigationService
      .createRelativeBuilder()
      .addPage<WidgetMockCViewModel>(param: createTestParameter('Result Test'))
      .navigateResult<String>();
    
    await tester.pumpAndSettle();
    expect(find.text('Mock C Screen'), findsOneWidget);
    
    // 結果を返すボタンをタップ
    await tester.tap(find.text('Return Result'));
    await tester.pumpAndSettle();
    
    // Assert - 結果が取得できている
    final result = await resultFuture;
    expect(result, 'Result from C');
    
    // Mock A Screenに戻っている
    expect(find.text('Mock A Screen'), findsOneWidget);
  }

  /// バックボタンでの遷移テスト
  Future<void> testBackNavigation(WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // Mock Bに遷移
    await navigationService
      .createRelativeBuilder()
      .addPage<WidgetMockBViewModel>(param: createTestParameter('Back Test'))
      .navigate();
    
    await tester.pumpAndSettle();
    expect(find.text('Mock B Screen'), findsOneWidget);
    
    // Act - RelativeNavigationBuilderでBackナビゲーション
    await navigationService
      .createRelativeBuilder()
      .addBack()
      .navigate();
    
    await tester.pumpAndSettle();
    
    // Assert - Mock A Screenに戻っている
    expect(find.text('Mock A Screen'), findsOneWidget);
  }

  /// 複数ページ追加のナビゲーションテスト
  Future<void> testMultiplePageNavigation(WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // Act - 複数ページを一度に追加
    await navigationService
      .createRelativeBuilder()
      .addPage<WidgetMockBViewModel>(param: createTestParameter('Multi B'))
      .addPage<WidgetMockCViewModel>(param: createTestParameter('Multi C'))
      .navigate();
    
    await tester.pumpAndSettle();
    
    // Assert - 最後のページ（Mock C Screen）が表示されている
    expect(find.text('Mock C Screen'), findsOneWidget);
    expect(find.text('Parameter: Multi C'), findsOneWidget);
    
    // Backで戻ると Mock B Screen が表示される
    await tester.tap(find.text('Go Back'));
    await tester.pumpAndSettle();
    
    expect(find.text('Mock B Screen'), findsOneWidget);
    expect(find.text('Parameter: Multi B'), findsOneWidget);
  }

  /// ディレイナビゲーションのテスト
  Future<void> testDelayNavigation(WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    final stopwatch = Stopwatch()..start();
    
    // Act - ディレイ付きナビゲーション
    await navigationService
      .createRelativeBuilder()
      .addDelay(500) // 500ms遅延
      .addPage<WidgetMockBViewModel>(param: createTestParameter('Delay Test'))
      .navigate();
    
    stopwatch.stop();
    await tester.pumpAndSettle();
    
    // Assert - 遅延時間が経過している
    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
    expect(find.text('Mock B Screen'), findsOneWidget);
    expect(find.text('Parameter: Delay Test'), findsOneWidget);
  }

  /// キャンセル付きナビゲーションのテスト
  Future<void> testCancelNavigation(WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    
    // Act - キャンセル付きパラメータでナビゲーション
    await navigationService
      .createRelativeBuilder()
      .addPage<WidgetMockBViewModel>(param: createTestParameter('Cancel Test', isCancel: true))
      .navigate();
    
    await tester.pumpAndSettle();
    
    // Assert - キャンセルされた場合でも画面は表示される
    expect(find.text('Mock B Screen'), findsOneWidget);
    
    // ViewModelの初期化がキャンセルされていることを確認
    final viewModel = container.read(widgetMockBViewModelProvider(createTestParameter('Cancel Test', isCancel: true)).notifier);
    final actionLog = viewModel.actionLogQueue.toList();
    expect(actionLog.contains('initializeAsyncCancel'), true);
  }
}

void main() {
  group('Widget Relative Navigation Tests', () {
    final testInstance = WidgetRelativeNavigationTests();
    
    setUp(() {
      testInstance.setUpWidgetTest();
    });
    
    tearDown(() {
      testInstance.tearDownWidgetTest();
    });
    
    testWidgets('基本的なRelative Navigation遷移', (WidgetTester tester) async {
      await testInstance.testBasicRelativeNavigation(tester);
    });
    
    testWidgets('Forward/Back Navigation', (WidgetTester tester) async {
      await testInstance.testForwardBackNavigation(tester);
    });
    
    testWidgets('結果取得ナビゲーション', (WidgetTester tester) async {
      await testInstance.testResultNavigation(tester);
    });
    
    testWidgets('バックボタンでの遷移', (WidgetTester tester) async {
      await testInstance.testBackNavigation(tester);
    });
    
    testWidgets('複数ページ追加のナビゲーション', (WidgetTester tester) async {
      await testInstance.testMultiplePageNavigation(tester);
    });
    
    testWidgets('ディレイナビゲーション', (WidgetTester tester) async {
      await testInstance.testDelayNavigation(tester);
    });
    
    testWidgets('キャンセル付きナビゲーション', (WidgetTester tester) async {
      await testInstance.testCancelNavigation(tester);
    });
  });
}