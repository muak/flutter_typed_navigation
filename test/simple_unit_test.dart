import 'package:flutter_test/flutter_test.dart';
import 'mocks/mock_viewmodels/mock_a_viewmodel.dart';
import 'mocks/mock_viewmodels/mock_b_viewmodel.dart';
import 'mocks/test_parameter.dart';

/// 基本的なMock ViewModelの単体テスト
/// Widget Testの前に基本動作を確認
void main() {
  group('Simple Unit Tests', () {
    test('Mock A ViewModelの基本動作', () {
      // Arrange & Act
      final viewModel = MockAViewModel();
      
      // Assert
      expect(viewModel.isActive, false);
      expect(viewModel.isDestroyed, false);
      expect(viewModel.actionLogQueue.isNotEmpty, true);
      expect(viewModel.actionLogQueue.first, 'initializeAsync');
    });

    test('Mock B ViewModelの基本動作（パラメータなし）', () {
      // Arrange & Act
      final viewModel = MockBViewModel();
      
      // Assert
      expect(viewModel.isActive, false);
      expect(viewModel.isDestroyed, false);
      expect(viewModel.parameters, null);
      expect(viewModel.actionLogQueue.first, 'initializeAsync');
    });

    test('Mock B ViewModelの基本動作（パラメータあり）', () {
      // Arrange
      final parameter = TestParameter('Test Value');
      
      // Act
      final viewModel = MockBViewModel(parameter);
      
      // Assert
      expect(viewModel.isActive, false);
      expect(viewModel.isDestroyed, false);
      expect(viewModel.parameters, parameter);
      expect(viewModel.actionLogQueue.first, 'initializeAsync');
    });

    test('Mock B ViewModelの基本動作（キャンセル）', () {
      // Arrange
      final parameter = TestParameter('Cancel Test', isCancel: true);
      
      // Act
      final viewModel = MockBViewModel(parameter);
      
      // Assert
      expect(viewModel.isActive, false);
      expect(viewModel.isDestroyed, false);
      expect(viewModel.parameters, parameter);
      
      final actionLog = viewModel.actionLogQueue.toList();
      expect(actionLog.length, 2);
      expect(actionLog[0], 'initializeAsync');
      expect(actionLog[1], 'initializeAsyncCancel');
    });

    test('ViewModelライフサイクルの動作', () {
      // Arrange
      final viewModel = MockAViewModel();
      
      // Act - ライフサイクルシミュレーション
      viewModel.onNavigatedTo();
      viewModel.onActiveFirst();
      viewModel.onViewAppearing();
      viewModel.onActive();
      
      // Assert - アクティブ状態確認
      expect(viewModel.isActive, true);
      expect(viewModel.isDestroyed, false);
      
      // Act - 非アクティブ化
      viewModel.onViewDisappearing();
      viewModel.onInActive();
      viewModel.onNavigatedFrom();
      
      // Assert - 非アクティブ状態確認
      expect(viewModel.isActive, false);
      expect(viewModel.isDestroyed, false);
      
      // Act - 破棄
      viewModel.destroy();
      
      // Assert - 破棄状態確認
      expect(viewModel.isActive, false);
      expect(viewModel.isDestroyed, true);
    });

    test('TestParameterの基本動作', () {
      // Arrange & Act
      final normalParam = TestParameter('Normal');
      final cancelParam = TestParameter('Cancel', isCancel: true);
      
      // Assert
      expect(normalParam.value, 'Normal');
      expect(normalParam.isCancel, false);
      
      expect(cancelParam.value, 'Cancel');
      expect(cancelParam.isCancel, true);
    });
  });
}