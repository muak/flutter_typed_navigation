import 'dart:collection';

import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'mock_viewmodel_base.dart';

part 'mock_d_viewmodel.g.dart';
part 'mock_d_viewmodel.freezed.dart';

@freezed
abstract class MockDState with _$MockDState {
  const factory MockDState({
    @Default('') String value,
  }) = _MockDState;
}

@riverpod
class MockDViewModel extends _$MockDViewModel
    with ViewModelCore
    implements MockViewModelBase {
  @override
  MockDState build() {
    ViewModelStack.callVmStack.add(this);
    ref.onDispose(() {
      destroy();
    });
    onBuild();
    return MockDState(value: 'MockDStateInit');
  }

  @override
  bool isBuild = false;

  @override
  bool isDestroyed = false;
  @override
  Queue<String> actionLogQueue = Queue<String>();

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
