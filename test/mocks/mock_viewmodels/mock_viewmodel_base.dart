import 'dart:collection';

import 'package:flutter/widgets.dart';


class ViewModelStack {
  ViewModelStack._();

  static final List<MockViewModelBase> callVmStack = [];

  static void clearCallVmStack() {
    callVmStack.clear();
  }
}

/// テスト用の基底ViewModelクラス
/// MAUI版のMockViewModelBaseと同等の機能を提供
abstract interface class MockViewModelBase {
  bool isBuild = false;
  bool isDestroyed = false;
  bool get isActive => false;

  Queue<String> actionLogQueue = Queue<String>();
}
