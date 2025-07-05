import 'dart:async';
import 'package:flutter/services.dart';

class PlatformService {
  static const MethodChannel _channel = MethodChannel('flutter_typed_navigation');

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
} 