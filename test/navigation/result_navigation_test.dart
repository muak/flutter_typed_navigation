import 'package:flutter_test/flutter_test.dart';
import 'test_base.dart';
import '../mocks/mock_viewmodels/mock_a_viewmodel.dart';
import '../mocks/mock_viewmodels/mock_b_viewmodel.dart';

/// Result Navigation Tests
/// 結果取得ナビゲーションのテスト
class ResultNavigationTests extends TestBase {

  /// 基本的な結果取得遷移のテスト
  void testBasicResultNavigation() {
    // Arrange
    final mockAViewModel = MockAViewModel();
    final resultData = 'Test Result Data';
    
    // ホームページアクティブ化
    mockAViewModel.onNavigatedTo();
    mockAViewModel.onActiveFirst();
    mockAViewModel.onViewAppearing();
    mockAViewModel.onActive();
    mockAViewModel.actionLogQueue.clear();
    
    // Act - 結果取得遷移をシミュレート
    final mockBViewModel = MockBViewModel();
    
    // MockBに遷移
    mockAViewModel.onViewDisappearing();
    mockAViewModel.onInActive();
    mockAViewModel.onNavigatedFrom();
    
    mockBViewModel.onNavigatedTo();
    mockBViewModel.onActiveFirst();
    mockBViewModel.onViewAppearing();
    mockBViewModel.onActive();
    
    // 結果を返してMockAに戻る
    mockBViewModel.onViewDisappearing();
    mockBViewModel.onInActive();
    mockBViewModel.onNavigatedFrom();
    mockBViewModel.destroy();
    
    // MockAに結果と共に戻る
    mockAViewModel.onViewAppearing();
    mockAViewModel.onActive();
    mockAViewModel.onComeBack();
    
    // Assert
    verifyViewModelState(
      mockBViewModel,
      isActive: false,
      isDestroyed: true,
    );
    
    verifyActionLog(mockBViewModel, [
      'initializeAsync',
      'onNavigatedTo',
      'onActiveFirst',
      'onViewAppearing',
      'onActive',
      'onViewDisappearing',
      'onInActive',
      'onNavigatedFrom',
      'destroy'
    ]);
    
    verifyViewModelState(
      mockAViewModel,
      isActive: true,
      isDestroyed: false,
    );
    
    // MockAが復帰した確認
    expect(mockAViewModel.actionLogQueue.length, 6);
    final logs = mockAViewModel.actionLogQueue.toList();
    expect(logs.sublist(logs.length - 3), ['onViewAppearing', 'onActive', 'onComeBack']);
  }

  /// パラメータ付き結果取得遷移のテスト
  void testParameterResultNavigation() {
    // Arrange
    final mockAViewModel = MockAViewModel();
    final parameter = createTestParameter('Input Parameter');
    final resultData = 'Processed Result';
    
    // ホームページアクティブ化
    mockAViewModel.onNavigatedTo();
    mockAViewModel.onActiveFirst();
    mockAViewModel.onViewAppearing();
    mockAViewModel.onActive();
    mockAViewModel.actionLogQueue.clear();
    
    // Act - パラメータ付き結果取得遷移をシミュレート
    final mockBViewModel = MockBViewModel(parameter);
    
    // MockBに遷移
    mockAViewModel.onViewDisappearing();
    mockAViewModel.onInActive();
    mockAViewModel.onNavigatedFrom();
    
    mockBViewModel.onNavigatedTo();
    mockBViewModel.onActiveFirst();
    mockBViewModel.onViewAppearing();
    mockBViewModel.onActive();
    
    // Assert - MockBにパラメータが渡されている
    verifyViewModelState(
      mockBViewModel,
      isActive: true,
      isDestroyed: false,
      expectedParameters: parameter,
    );
    
    verifyActionLog(mockBViewModel, [
      'initializeAsync',
      'onNavigatedTo',
      'onActiveFirst',
      'onViewAppearing',
      'onActive'
    ]);
    
    // 結果を返してMockAに戻る
    mockBViewModel.onViewDisappearing();
    mockBViewModel.onInActive();
    mockBViewModel.onNavigatedFrom();
    mockBViewModel.destroy();
    
    mockAViewModel.onViewAppearing();
    mockAViewModel.onActive();
    mockAViewModel.onComeBack();
    
    // Assert - 最終状態確認
    verifyViewModelState(
      mockBViewModel,
      isActive: false,
      isDestroyed: true,
    );
    
    verifyViewModelState(
      mockAViewModel,
      isActive: true,
      isDestroyed: false,
    );
  }

  /// モーダル結果取得遷移のテスト
  void testModalResultNavigation() {
    // Arrange
    final mockAViewModel = MockAViewModel();
    final resultData = 'Modal Result Data';
    
    // ホームページアクティブ化
    mockAViewModel.onNavigatedTo();
    mockAViewModel.onActiveFirst();
    mockAViewModel.onViewAppearing();
    mockAViewModel.onActive();
    mockAViewModel.actionLogQueue.clear();
    
    // Act - モーダル結果取得遷移をシミュレート
    final mockBViewModel = MockBViewModel();
    
    // MockBをモーダルで表示
    mockAViewModel.onViewDisappearing();
    mockAViewModel.onInActive();
    mockAViewModel.onNavigatedFrom();
    
    mockBViewModel.onNavigatedTo();
    mockBViewModel.onActiveFirst();
    mockBViewModel.onViewAppearing();
    mockBViewModel.onActive();
    
    // モーダルを結果と共に閉じる
    mockBViewModel.onNavigatedFrom();
    mockBViewModel.onViewDisappearing();
    mockBViewModel.onInActive();
    mockBViewModel.destroy();
    
    // MockAに結果と共に戻る
    mockAViewModel.onViewAppearing();
    mockAViewModel.onActive();
    mockAViewModel.onComeBack();
    
    // Assert
    verifyViewModelState(
      mockBViewModel,
      isActive: false,
      isDestroyed: true,
    );
    
    // モーダルの場合のライフサイクルイベント順序を確認
    verifyActionLog(mockBViewModel, [
      'initializeAsync',
      'onNavigatedTo',
      'onActiveFirst',
      'onViewAppearing',
      'onActive',
      'onNavigatedFrom',
      'onViewDisappearing',
      'onInActive',
      'destroy'
    ]);
    
    verifyViewModelState(
      mockAViewModel,
      isActive: true,
      isDestroyed: false,
    );
    
    // MockAが復帰した確認
    expect(mockAViewModel.actionLogQueue.length, 6);
    final logs = mockAViewModel.actionLogQueue.toList();
    expect(logs.sublist(logs.length - 3), ['onViewAppearing', 'onActive', 'onComeBack']);
  }

  /// ボトムシート結果取得のテスト
  void testBottomSheetResult() {
    // Arrange
    final mockAViewModel = MockAViewModel();
    final sheetResult = 'Bottom Sheet Result';
    
    // ホームページアクティブ化
    mockAViewModel.onNavigatedTo();
    mockAViewModel.onActiveFirst();
    mockAViewModel.onViewAppearing();
    mockAViewModel.onActive();
    mockAViewModel.actionLogQueue.clear();
    
    // Act - ボトムシート表示をシミュレート
    final mockBViewModel = MockBViewModel();
    
    // ボトムシート表示（背景は残る）
    mockBViewModel.onNavigatedTo();
    mockBViewModel.onActiveFirst();
    mockBViewModel.onViewAppearing();
    mockBViewModel.onActive();
    
    // ボトムシートを結果と共に閉じる
    mockBViewModel.onViewDisappearing();
    mockBViewModel.onInActive();
    mockBViewModel.onNavigatedFrom();
    mockBViewModel.destroy();
    
    // Assert - ボトムシートのライフサイクル確認
    verifyViewModelState(
      mockBViewModel,
      isActive: false,
      isDestroyed: true,
    );
    
    verifyActionLog(mockBViewModel, [
      'initializeAsync',
      'onNavigatedTo',
      'onActiveFirst',
      'onViewAppearing',
      'onActive',
      'onViewDisappearing',
      'onInActive',
      'onNavigatedFrom',
      'destroy'
    ]);
    
    // MockAは背景として残り続ける（ボトムシートの場合）
    verifyViewModelState(
      mockAViewModel,
      isActive: true,
      isDestroyed: false,
    );
    
    // ボトムシートクローズ時は背景のViewModelは変化しない
    expect(mockAViewModel.actionLogQueue.length, 0);
  }

  /// 複数の結果取得遷移の組み合わせテスト
  void testMultipleResultNavigation() {
    // Arrange
    final mockAViewModel = MockAViewModel();
    
    // ホームページアクティブ化
    mockAViewModel.onNavigatedTo();
    mockAViewModel.onActiveFirst();
    mockAViewModel.onViewAppearing();
    mockAViewModel.onActive();
    mockAViewModel.actionLogQueue.clear();
    
    // Act - 複数の結果取得遷移をシミュレート
    // Step 1: MockB結果取得遷移
    final mockBViewModel = MockBViewModel();
    
    mockAViewModel.onViewDisappearing();
    mockAViewModel.onInActive();
    mockAViewModel.onNavigatedFrom();
    
    mockBViewModel.onNavigatedTo();
    mockBViewModel.onActiveFirst();
    mockBViewModel.onViewAppearing();
    mockBViewModel.onActive();
    
    // MockBから結果を返す
    mockBViewModel.onViewDisappearing();
    mockBViewModel.onInActive();
    mockBViewModel.onNavigatedFrom();
    mockBViewModel.destroy();
    
    mockAViewModel.onViewAppearing();
    mockAViewModel.onActive();
    mockAViewModel.onComeBack();
    
    // Step 2: 続けてモーダル結果取得遷移
    final modalMockBViewModel = MockBViewModel();
    
    mockAViewModel.onViewDisappearing();
    mockAViewModel.onInActive();
    mockAViewModel.onNavigatedFrom();
    
    modalMockBViewModel.onNavigatedTo();
    modalMockBViewModel.onActiveFirst();
    modalMockBViewModel.onViewAppearing();
    modalMockBViewModel.onActive();
    
    // モーダルから結果を返す
    modalMockBViewModel.onNavigatedFrom();
    modalMockBViewModel.onViewDisappearing();
    modalMockBViewModel.onInActive();
    modalMockBViewModel.destroy();
    
    mockAViewModel.onViewAppearing();
    mockAViewModel.onActive();
    mockAViewModel.onComeBack();
    
    // Assert - 両方のViewModelが正常に破棄されている
    verifyViewModelState(
      mockBViewModel,
      isActive: false,
      isDestroyed: true,
    );
    
    verifyViewModelState(
      modalMockBViewModel,
      isActive: false,
      isDestroyed: true,
    );
    
    // MockAが最終的にアクティブ
    verifyViewModelState(
      mockAViewModel,
      isActive: true,
      isDestroyed: false,
    );
    
    // MockAのライフサイクルログ確認（2回の復帰）
    expect(mockAViewModel.actionLogQueue.length, 12);
    final logs = mockAViewModel.actionLogQueue.toList();
    
    // 最後の3つが最終復帰のログ
    expect(logs.sublist(logs.length - 3), ['onViewAppearing', 'onActive', 'onComeBack']);
  }
}

void main() {
  group('Result Navigation Tests', () {
    final testInstance = ResultNavigationTests();
    
    setUp(() {
      testInstance.setUpTest();
    });
    
    tearDown(() {
      testInstance.tearDownTest();
    });
    
    test('基本的な結果取得遷移', () {
      testInstance.testBasicResultNavigation();
    });
    
    test('パラメータ付き結果取得遷移', () {
      testInstance.testParameterResultNavigation();
    });
    
    test('モーダル結果取得遷移', () {
      testInstance.testModalResultNavigation();
    });
    
    test('ボトムシート結果取得', () {
      testInstance.testBottomSheetResult();
    });
    
    test('複数の結果取得遷移の組み合わせ', () {
      testInstance.testMultipleResultNavigation();
    });
  });
}