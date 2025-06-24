import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widget_tests/mocks/widget_mock_screens.dart';
import 'mocks/test_parameter.dart';

/// 基本的なWidget Testの動作確認
/// NavigationServiceに依存しない基本的な画面表示テスト
void main() {
  group('Simple Widget Tests', () {
    testWidgets('Mock A Screenの基本表示', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WidgetMockAScreen(),
          ),
        ),
      );
      
      // Assert - 画面要素が表示されている
      expect(find.text('Mock A Screen'), findsNWidgets(2)); // AppBarとbodyの両方
      expect(find.text('Navigate to B'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Mock B Screenの基本表示（パラメータなし）', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WidgetMockBScreen(null),
          ),
        ),
      );
      
      // Assert - 画面要素が表示されている
      expect(find.text('Mock B Screen'), findsNWidgets(2)); // AppBarとbodyの両方
      expect(find.text('Navigate to C'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('Mock B Screenの基本表示（パラメータあり）', (WidgetTester tester) async {
      // Arrange
      final parameter = TestParameter('Test Parameter');
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WidgetMockBScreen(parameter),
          ),
        ),
      );
      
      // Assert - パラメータが表示されている
      expect(find.text('Mock B Screen'), findsNWidgets(2)); // AppBarとbodyの両方
      expect(find.text('Parameter: Test Parameter'), findsOneWidget);
      expect(find.text('Navigate to C'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('Mock C Screenの基本表示', (WidgetTester tester) async {
      // Arrange
      final parameter = TestParameter('C Parameter');
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WidgetMockCScreen(parameter),
          ),
        ),
      );
      
      // Assert - 画面要素が表示されている
      expect(find.text('Mock C Screen'), findsNWidgets(2)); // AppBarとbodyの両方
      expect(find.text('Parameter: C Parameter'), findsOneWidget);
      expect(find.text('Return Result'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('Tab Root Screenの基本表示', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WidgetMockTabRootScreen(config: 'test config'),
          ),
        ),
      );
      
      // Assert - タブが表示されている
      expect(find.text('Mock Tab Root Screen'), findsOneWidget);
      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsOneWidget);
      expect(find.text('Tab 1 Content'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('ナビゲーションボタンのタップ動作', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WidgetMockBScreen(null),
          ),
        ),
      );
      
      // Act - Go Backボタンをタップ
      await tester.tap(find.text('Go Back'));
      await tester.pumpAndSettle();
      
      // Assert - タップ動作が完了（実際のNavigationは別テストで検証）
      // Note: Navigator.pop()によりscreen自体は削除されているためfind.byTypeで確認
      expect(find.byType(Scaffold), findsNothing);
    });
  });
}

