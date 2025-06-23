import 'dart:collection';
import 'package:riverpod/riverpod.dart';
import '../../../lib/src/viewmodel_core.dart';
import '../../mocks/test_parameter.dart';

/// Widget Test用のMock ViewModel基底ミックスイン
/// 実際のViewModelCoreミックスインを使用してライフサイクルを管理
mixin WidgetMockViewModelMixin on StateNotifier {
  bool _isDestroyed = false;
  bool _isActive = false;
  Object? _parameters;
  final Queue<String> _actionLogQueue = Queue<String>();
  
  /// ViewModelが破棄されているかどうか
  bool get isDestroyed => _isDestroyed;
  
  /// ViewModelがアクティブかどうか
  bool get isActive => _isActive;
  
  /// パラメータ
  Object? get parameters => _parameters;
  
  /// アクションログキュー
  Queue<String> get actionLogQueue => _actionLogQueue;
  
  /// パラメータを設定
  void setParameters(Object? parameters) {
    _parameters = parameters;
  }
  
  /// ログを記録
  void _log(String action) {
    _actionLogQueue.add(action);
  }
  
  /// ViewModelCoreのライフサイクルメソッド
  void onActiveFirst() {
    _log('onActiveFirst');
    _isActive = true;
  }
  
  void onActive() {
    _log('onActive');
    _isActive = true;
  }
  
  void onInActive() {
    _log('onInActive');
    _isActive = false;
  }
  
  void onPaused() {
    _log('onPaused');
  }
  
  void onResumed() {
    _log('onResumed');
  }
  
  /// ViewModelの破棄
  void destroy() {
    _log('destroy');
    _isDestroyed = true;
    _isActive = false;
  }
  
  /// ナビゲーション関連のイベント
  void onNavigatedTo() {
    _log('onNavigatedTo');
  }
  
  void onNavigatedFrom() {
    _log('onNavigatedFrom');
  }
  
  void onViewAppearing() {
    _log('onViewAppearing');
  }
  
  void onViewDisappearing() {
    _log('onViewDisappearing');
  }
  
  void onComeBack() {
    _log('onComeBack');
  }
}

/// Mock A ViewModel（パラメータなし）
class WidgetMockAViewModel extends StateNotifier<WidgetMockAViewModelState> 
    with WidgetMockViewModelMixin, ViewModelCore {
  
  WidgetMockAViewModel() : super(WidgetMockAViewModelState()) {
    actionLogQueue.add('initializeAsync');
  }
}

class WidgetMockAViewModelState {
  const WidgetMockAViewModelState();
}

/// Mock B ViewModel（パラメータあり）
class WidgetMockBViewModel extends StateNotifier<WidgetMockBViewModelState> 
    with WidgetMockViewModelMixin, ViewModelCore {
  
  WidgetMockBViewModel(TestParameter? parameter) : super(WidgetMockBViewModelState()) {
    setParameters(parameter);
    actionLogQueue.add('initializeAsync');
    
    // キャンセル処理のシミュレート
    if (parameter?.isCancel == true) {
      actionLogQueue.add('initializeAsyncCancel');
      return;
    }
  }
}

class WidgetMockBViewModelState {
  const WidgetMockBViewModelState();
}

/// Mock C ViewModel（パラメータあり）
class WidgetMockCViewModel extends StateNotifier<WidgetMockCViewModelState> 
    with WidgetMockViewModelMixin, ViewModelCore {
  
  WidgetMockCViewModel(TestParameter? parameter) : super(WidgetMockCViewModelState()) {
    setParameters(parameter);
    actionLogQueue.add('initializeAsync');
    
    // キャンセル処理のシミュレート
    if (parameter?.isCancel == true) {
      actionLogQueue.add('initializeAsyncCancel');
      return;
    }
  }
}

class WidgetMockCViewModelState {
  const WidgetMockCViewModelState();
}

/// Mock Tab Root ViewModel
class WidgetMockTabRootViewModel extends StateNotifier<WidgetMockTabRootViewModelState> 
    with WidgetMockViewModelMixin, ViewModelCore {
  
  WidgetMockTabRootViewModel() : super(WidgetMockTabRootViewModelState()) {
    actionLogQueue.add('initializeAsync');
  }
}

class WidgetMockTabRootViewModelState {
  const WidgetMockTabRootViewModelState();
}

/// Riverpod Providers
final widgetMockAViewModelProvider = StateNotifierProvider<WidgetMockAViewModel, WidgetMockAViewModelState>((ref) {
  return WidgetMockAViewModel();
});

final widgetMockBViewModelProvider = StateNotifierProvider.family<WidgetMockBViewModel, WidgetMockBViewModelState, TestParameter?>((ref, param) {
  return WidgetMockBViewModel(param);
});

final widgetMockCViewModelProvider = StateNotifierProvider.family<WidgetMockCViewModel, WidgetMockCViewModelState, TestParameter?>((ref, param) {
  return WidgetMockCViewModel(param);
});

final widgetMockTabRootViewModelProvider = StateNotifierProvider<WidgetMockTabRootViewModel, WidgetMockTabRootViewModelState>((ref) {
  return WidgetMockTabRootViewModel();
});