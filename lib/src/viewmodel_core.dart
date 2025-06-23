import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

mixin ViewModelCore{
  late final String pageId;
  bool _isActiveOnce = false;
  bool _isActive = false;
  bool get isActive => _isActive;  
 
  // 初回アクティブ化時に呼ばれる
  void onActiveFirst(){}
  // アクティブ化時に呼ばれる
  void onActive(){}
  // 非アクティブ化時に呼ばれる
  void onInActive(){}
  // バックグラウンドになった時に呼ばれる
  void onPaused(){}
  // バックグラウンドから復帰した時に呼ばれる
  void onResumed(){}

  @protected
  void onActiveInternal(){
    _isActive = true;
    if(!_isActiveOnce){
      _isActiveOnce = true;
      onActiveFirst();
    }
    onActive();
  }
  
  @protected
  void onInActiveInternal(){
    if(!_isActive) return;
    _isActive = false;
    onInActive();
  }
}