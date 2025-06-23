import 'dart:async';

/// Completerにタイムアウト機能を追加する拡張メソッド
extension CompleterExtensions<T> on Completer<T> {


  /// 指定した時間でタイムアウトするFutureを返す
  /// 
  /// [timeout] タイムアウト時間
  /// [timeoutValue] タイムアウト時に返すデフォルト値
  /// [onTimeout] タイムアウト時に実行されるコールバック（オプション）
  /// 
  /// タイムアウトが発生した場合：
  /// - [onTimeout]が指定されている場合はそのコールバックを実行
  /// - [timeoutValue]が指定されている場合はその値を返す

  Future<T> withTimeout(
    Duration timeout, T timeoutValue, {
    void Function()? onTimeout,
  }) {
    return future.timeout(
      timeout,
      onTimeout: () {
        if(onTimeout != null){
          onTimeout();
        }
        return timeoutValue;
      },
    );
  }

  /// 指定した時間でタイムアウトし、タイムアウト時にCompleterを自動的にcompleteする
  /// 
  /// [timeout] タイムアウト時間
  /// [timeoutValue] タイムアウト時にcompleteする値
  /// 
  /// タイムアウトが発生した場合、Completerが自動的に[timeoutValue]でcompleteされる
  Future<T> withAutoComplete(Duration timeout, T timeoutValue) {
    Timer(timeout, () {
      if (!isCompleted) {
        complete(timeoutValue);
      }
    });
    return future;
  }

  /// 指定した時間でタイムアウトし、タイムアウト時にCompleterを自動的にcompleteWithErrorする
  /// 
  /// [timeout] タイムアウト時間
  /// [error] タイムアウト時にcompleteWithErrorする例外（デフォルト：TimeoutException）
  /// [stackTrace] スタックトレース（オプション）
  /// 
  /// タイムアウトが発生した場合、Completerが自動的に[error]でcompleteWithErrorされる
  Future<T> withAutoError(
    Duration timeout, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    Timer(timeout, () {
      if (!isCompleted) {
        completeError(
          error ?? TimeoutException('Operation timed out', timeout),
          stackTrace,
        );
      }
    });
    return future;
  }

  /// 複数のタイムアウト条件を設定できる高度なタイムアウト機能
  /// 
  /// [warningTimeout] 警告タイムアウト時間
  /// [onWarning] 警告タイムアウト時のコールバック
  /// [finalTimeout] 最終タイムアウト時間
  /// [onFinalTimeout] 最終タイムアウト時のコールバック
  /// [timeoutValue] 最終タイムアウト時に返すデフォルト値
  /// 
  /// 警告タイムアウトが発生した場合は[onWarning]が実行され、
  /// 最終タイムアウトが発生した場合は[onFinalTimeout]が実行される
  Future<T> withAdvancedTimeout({
    Duration? warningTimeout,
    void Function()? onWarning,
    required Duration finalTimeout,
    FutureOr<T> Function()? onFinalTimeout,
    T? timeoutValue,
  }) {
    // 警告タイマーの設定
    if (warningTimeout != null && onWarning != null) {
      Timer(warningTimeout, () {
        if (!isCompleted) {
          onWarning();
        }
      });
    }

    // 最終タイムアウトの設定
    return future.timeout(
      finalTimeout,
      onTimeout: () {
        if (timeoutValue != null) {
          return timeoutValue;
        }
        if (onFinalTimeout != null) {
          return onFinalTimeout();
        }
        throw TimeoutException('Operation timed out', finalTimeout);
      },
    );
  }
}
