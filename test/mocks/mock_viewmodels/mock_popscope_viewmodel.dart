import 'dart:collection';

import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'mock_viewmodel_base.dart';
part 'mock_popscope_viewmodel.g.dart';
part 'mock_popscope_viewmodel.freezed.dart';

@freezed
abstract class MockPopScopeState with _$MockPopScopeState {
  const factory MockPopScopeState({
    @Default('') String value,
  }) = _MockPopScopeState;
}

@riverpod
class MockPopScopeViewModel extends _$MockPopScopeViewModel
    with ViewModelCore
    implements MockViewModelBase {
  @override
  MockPopScopeState build() {
    ViewModelStack.callVmStack.add(this);
    ref.onDispose(() {
      destroy();
    });
    onBuild();
    return const MockPopScopeState(value: 'MockPopScopeStateInit');
  }

  @override
  bool isBuild = false;

  @override
  bool isDestroyed = false;
  
  @override
  Queue<String> actionLogQueue = Queue<String>();

  bool _canPop = true;
  bool _onPopInvokedCalled = false;

  bool get canPop => _canPop;
  bool get onPopInvokedCalled => _onPopInvokedCalled;

  void setCanPop(bool value) {
    _canPop = value;
  }

  void onPopInvokedWithResult<T extends Object?>(bool didPop, T? result) {
    _onPopInvokedCalled = true;
    actionLogQueue.add('onPopInvokedWithResult didPop:$didPop result:$result');
  }

  void resetOnPopInvokedCalled() {
    _onPopInvokedCalled = false;
  }

  void onBuild() {
    isBuild = true;
    actionLogQueue.add('build');
    print('${runtimeType} build');
  }

  void destroy() {
    isDestroyed = true;
    actionLogQueue.add('destroy');
    print('${runtimeType} destroy');
  }

  @override
  void onActiveFirst() {
    actionLogQueue.add('onActiveFirst');
    print('${runtimeType} onActiveFirst');
  }

  @override
  void onActive() {
    actionLogQueue.add('onActive');
    print('${runtimeType} onActive');
  }

  @override
  void onInActive() {
    actionLogQueue.add('onInActive');
    print('${runtimeType} onInActive');
  }

  @override
  void onPaused() {
    actionLogQueue.add('onPaused');
    print('${runtimeType} onPaused');
  }

  @override
  void onResumed() {
    actionLogQueue.add('onResumed');
    print('${runtimeType} onResumed');
  }
}