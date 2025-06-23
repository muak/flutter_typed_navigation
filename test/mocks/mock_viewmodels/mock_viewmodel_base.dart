import 'dart:collection';
import '../../../lib/src/viewmodel_core.dart';

/// テスト用の基底ViewModelクラス
/// MAUI版のMockViewModelBaseと同等の機能を提供
class MockViewModelBase with ViewModelCore {
  static final List<MockViewModelBase> callVmStack = [];
  
  bool _isDestroyed = false;
  bool get isDestroyed => _isDestroyed;
  
  bool _isActive = false;
  bool get isActive => _isActive;
  
  Object? _parameters;
  Object? get parameters => _parameters;
  
  final Queue<String> _actionLogQueue = Queue<String>();
  Queue<String> get actionLogQueue => _actionLogQueue;
  
  MockViewModelBase() {
    callVmStack.add(this);
  }

  void setParameters(Object? params) {
    _parameters = params;
  }

  void destroy() {
    _isDestroyed = true;
    _actionLogQueue.add('destroy');
    print('${runtimeType} destroy');
  }

  @override
  void onActiveFirst() {
    _actionLogQueue.add('onActiveFirst');
    print('${runtimeType} onActiveFirst');
  }

  @override
  void onActive() {
    _isActive = true;
    _actionLogQueue.add('onActive');
    print('${runtimeType} onActive');
  }

  @override
  void onInActive() {
    _isActive = false;
    _actionLogQueue.add('onInActive');
    print('${runtimeType} onInActive');
  }

  @override
  void onPaused() {
    _actionLogQueue.add('onPaused');
    print('${runtimeType} onPaused');
  }

  @override
  void onResumed() {
    _actionLogQueue.add('onResumed');
    print('${runtimeType} onResumed');
  }

  void onNavigatedTo() {
    _actionLogQueue.add('onNavigatedTo');
    print('${runtimeType} onNavigatedTo');
  }

  void onNavigatedFrom() {
    _actionLogQueue.add('onNavigatedFrom');
    print('${runtimeType} onNavigatedFrom');
  }

  void onViewAppearing() {
    _actionLogQueue.add('onViewAppearing');
    print('${runtimeType} onViewAppearing');
  }

  void onViewDisappearing() {
    _actionLogQueue.add('onViewDisappearing');
    print('${runtimeType} onViewDisappearing');
  }

  void onComeBack() {
    _actionLogQueue.add('onComeBack');
    print('${runtimeType} onComeBack');
  }

  static void clearCallVmStack() {
    callVmStack.clear();
  }
}