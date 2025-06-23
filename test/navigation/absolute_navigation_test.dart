import 'package:flutter_test/flutter_test.dart';
import 'test_base.dart';
import '../mocks/mock_viewmodels/mock_a_viewmodel.dart';
import '../mocks/mock_viewmodels/mock_b_viewmodel.dart';

/// Absolute Navigation Tests
/// MAUI版のAbsoluteNavigationFixtureと同等のテストを実装
class AbsoluteNavigationTests extends TestBase {
  
  /// 基本的なContentPage遷移テスト（パラメータなし）
  void testContentPage() {
    // Act - MockAViewModelを作成
    final viewModel = MockAViewModel();
    
    // Assert
    verifyViewModelState(
      viewModel,
      isActive: false,  // 初期状態では非アクティブ
      isDestroyed: false,
      expectedParameters: null,
    );
    
    verifyActionLog(viewModel, ['initializeAsync']);
  }

  /// 基本的なContentPage遷移テスト（パラメータあり）
  void testContentPageWithParameter() {
    // Arrange
    final parameter = createTestParameter('Hoge');
    
    // Act - MockAViewModelにパラメータ付きで作成
    final viewModel = MockAViewModel(parameter);
    
    // Assert
    verifyViewModelState(
      viewModel,
      isActive: false,
      isDestroyed: false,
      expectedParameters: parameter,
    );
    
    verifyActionLog(viewModel, ['initializeAsync']);
  }

  /// キャンセル処理のテスト
  void testCancelNavigation() {
    // Arrange
    final parameter = createTestParameter('SomeValue', isCancel: true);
    
    // Act - キャンセル付きパラメータでViewModel作成
    final viewModel = MockBViewModel(parameter);
    
    // Assert - キャンセルされたViewModelの確認
    verifyViewModelState(
      viewModel,
      isActive: false,
      isDestroyed: false,  // TODO: キャンセル時の破棄処理実装後にtrueに変更
      expectedParameters: parameter,
    );
    
    verifyActionLog(viewModel, ['initializeAsync', 'initializeAsyncCancel']);
  }
}

void main() {
  group('Absolute Navigation Tests', () {
    final testInstance = AbsoluteNavigationTests();
    
    setUp(() {
      testInstance.setUpTest();
    });
    
    tearDown(() {
      testInstance.tearDownTest();
    });
    
    test('基本的なContentPage遷移（パラメータなし）', () {
      testInstance.testContentPage();
    });
    
    test('基本的なContentPage遷移（パラメータあり）', () {
      testInstance.testContentPageWithParameter();
    });
    
    test('キャンセル処理', () {
      testInstance.testCancelNavigation();
    });
  });
}