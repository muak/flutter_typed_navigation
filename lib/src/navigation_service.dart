import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'internal_navigation_service.dart';
import 'relative_navigation_builder.dart';
import 'absolute_navigation_builder.dart';
import 'view_registry.dart';
import 'navigation_entry.dart';

abstract interface class NavigationService {
  // 前のページに戻る
  Future<void> goBack();
  // 前のページに戻り、結果を返す
  Future<void> goBackResult<TResult>(TResult result);
  // モーダルを閉じる
  Future<void> closeModal();
  // モーダルを閉じ、結果を返す
  Future<void> closeModalResult<TResult>(TResult result);
  // タブを切り替える
  Future<void> changeTab(int index);

  // ボトムシートを閉じる
  void closeBottomSheet();
  // ボトムシートを閉じり、結果を返す
  void closeBottomSheetResult<TResult>(TResult result);
  // アプリがバックグラウンドになった時に呼ばれる
  void setAppOnPaused(void Function(Ref) onPaused);
  // アプリがバックグラウンドから復帰した時に呼ばれる
  void setAppOnResumed(void Function(Ref) onResumed);
  // 絶対パスでページを表示するためのビルダーを作成する
  AbsoluteNavigationBuilder createAbsoluteBuilder();
  // 相対パスでページを表示するためのビルダーを作成する
  RelativeNavigationBuilder createRelativeBuilder();
  // ViewModelProviderとページのマッピングを登録する
  void register(void Function(ViewRegistry) builder);
  // ルートを設定する
  void setRoutes(List<NavigationEntry> entries);
  // ボトムシートを表示する
  Future<void> showBottomSheet<TViewModel>();
  // ボトムシートを表示し、結果を返す
  Future<TResult?> showBottomSheetResult<TViewModel, TResult>();
  // ボトムシートを表示し、パラメータを渡す
  Future<void> showBottomSheetWithParameter<TViewModel, TParameter>(TParameter parameter);
  // ボトムシートを表示し、パラメータを渡し、結果を返す
  Future<TResult?> showBottomSheetWithParameterResult<TViewModel, TParameter, TResult>(TParameter parameter);
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return ref.read(internalNavigationServiceProvider);
});
