import 'dart:async';
import 'package:flutter/services.dart';

class PlatformService {
  static const MethodChannel _channel = MethodChannel('flutter_typed_navigation');
  static const EventChannel _eventChannel = EventChannel('flutter_typed_navigation_events');
  
  static StreamSubscription? _backPressedSubscription;
  static void Function()? _onBackPressed;

  /// アプリを最小化（バックグラウンドに移動）します
  /// 
  /// Android: moveTaskToBack()を呼び出してアプリをバックグラウンドに移動
  /// iOS: サポートされていません（App Storeのガイドラインに反するため）
  /// 
  /// Returns: 成功した場合はtrue、失敗した場合はfalse
  static Future<bool> minimizeApp() async {
    try {
      final result = await _channel.invokeMethod<bool>('minimizeApp');
      return result ?? false;
    } on PlatformException catch (e) {
      // プラットフォーム固有のエラーが発生した場合
      print('minimizeApp failed: ${e.message}');
      return false;
    } catch (e) {
      // その他のエラーが発生した場合
      print('minimizeApp failed: $e');
      return false;
    }
  }

  /// バックボタンが押された時のコールバック関数を登録します
  /// 
  /// [onBackPressed]: バックボタンが押された時に呼び出される関数
  /// 
  /// Returns: 成功した場合はtrue、失敗した場合はfalse
  static Future<bool> registerBackPressedCallback(void Function() onBackPressed) async {
    try {
      _onBackPressed = onBackPressed;
      
      // イベントストリームを監視開始
      _backPressedSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
        if (event is Map && event['event'] == 'backPressed') {
          _onBackPressed?.call();
        }
      });
      
      // ネイティブ側にコールバック登録を要求
      final result = await _channel.invokeMethod<bool>('registerBackPressedDispatcher');
      return result ?? false;
    } on PlatformException catch (e) {
      print('registerBackPressedCallback failed: ${e.message}');
      return false;
    } catch (e) {
      print('registerBackPressedCallback failed: $e');
      return false;
    }
  }

  /// バックボタンのコールバック関数を解除します
  /// 
  /// Returns: 成功した場合はtrue、失敗した場合はfalse
  static Future<bool> unregisterBackPressedCallback() async {
    try {
      // イベントストリームの監視を停止
      await _backPressedSubscription?.cancel();
      _backPressedSubscription = null;
      _onBackPressed = null;
      
      // ネイティブ側にコールバック解除を要求
      final result = await _channel.invokeMethod<bool>('unregisterBackPressedDispatcher');
      return result ?? false;
    } on PlatformException catch (e) {
      print('unregisterBackPressedCallback failed: ${e.message}');
      return false;
    } catch (e) {
      print('unregisterBackPressedCallback failed: $e');
      return false;
    }
  }
} 