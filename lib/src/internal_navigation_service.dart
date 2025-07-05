import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'absolute_navigation_builder.dart';
import 'extensions/completer_extensions.dart';
import 'extensions/list_extensions.dart';
import 'navigation_segment.dart';
import 'navigation_service.dart';
import 'navigation_state.dart';
import 'relative_navigation_builder.dart';

import 'navigation_entry.dart';
import 'view_registry.dart';

typedef CompletionAttach = (
  void Function(dynamic result) onComplete,
  void Function() onCancel
);

class NavigationResultException implements Exception {
  final String message;
  NavigationResultException(this.message);
}

class InternalNavigationService extends Notifier<NavigationState>
    implements NavigationService {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  late final ViewRegistry _viewRegistry;
  late void Function() _onAppPaused = () => {};
  void Function() get onAppPaused => _onAppPaused;
  late void Function() _onAppResumed = () => {};
  void Function() get onAppResumed => _onAppResumed;
  final Map<String, Completer<bool>> pageBuildCompleters = {};
  final Map<String, CompletionAttach> resultAttaches = {};

  @override
  NavigationState build() {
    _viewRegistry = ref.read(viewRegistryProvider);
    _onAppPaused = () => {};
    return const NavigationState();
  }

  @override
  void setAppOnPaused(void Function(Ref) onPaused) {
    _onAppPaused = () => onPaused(ref);
  }

  @override
  void setAppOnResumed(void Function(Ref) onResumed) {
    _onAppResumed = () => onResumed(ref);
  }

  @override
  AbsoluteNavigationBuilder createAbsoluteBuilder() =>
      AbsoluteNavigationBuilder(this);

  @override
  RelativeNavigationBuilder createRelativeBuilder() =>
      RelativeNavigationBuilder(this);

  @override
  void register(void Function(ViewRegistry) builder) {
    builder(_viewRegistry);
  }

  @override
  void setRoutes(List<NavigationEntry> entries) {
    state = state.copyWith(stack: [...entries], shouldClearCache: true);
  }

  @override
  Future<void> navigate<TViewModel>({dynamic param}) async {
    await createRelativeBuilder().addPage<TViewModel>(param: param).navigate();
  }

  @override
  Future<TResult?> navigateResult<TViewModel, TResult>({dynamic param}) async {
    return await createRelativeBuilder().addPage<TViewModel>(param: param).navigateResult<TResult>();
  }

  @override
  Future<void> navigateModal<TViewModel>({dynamic param}) async {
    await createRelativeBuilder().addNavigator((navBuilder) {
      navBuilder.addPage<TViewModel>(param: param);
    }).navigate();
  }

  @override
  Future<TResult?> navigateModalResult<TViewModel, TResult>({dynamic param}) async {
    return await createRelativeBuilder().addNavigator((navBuilder) {
      navBuilder.addPage<TViewModel>(param: param);
    }).navigateResult<TResult>();
  }

  @override
  Future<void> goBack() async {
    final currentPageId = getCurrentPageId();
    if (currentPageId == null) return;

    await createRelativeBuilder().addBack().navigate();
  }

  @override
  Future<void> goBackToRoot() async {
    await createRelativeBuilder().addBackToRoot().navigate();
  }

  @override
  Future<void> goBackResult<TResult>(TResult result) async {
    final currentPageId = getCurrentPageId();
    if (currentPageId == null) return;

    await createRelativeBuilder().addBack().navigate();

    if (resultAttaches.containsKey(currentPageId)) {
      final (onComplete, _) = resultAttaches[currentPageId]!;
      onComplete(result);
    }
  }

  @override
  Future<void> closeModal() async {
    await createRelativeBuilder().addModalClose().navigate();
  }

  @override
  Future<void> closeModalResult<TResult>(TResult result) async {
    final currentModalPageId = state.stack.lastOrNull?.pageId ??
        (throw Exception('currentModalPageId is null'));
    await createRelativeBuilder().addModalClose().navigate();

    if (resultAttaches.containsKey(currentModalPageId)) {
      final (onComplete, _) = resultAttaches[currentModalPageId]!;
      onComplete(result);
    }
  }

  @override
  Future<void> changeTab(int index) async {
    await createRelativeBuilder().addChangeTab(index).navigate();
  }

  @override
  Future<void> showBottomSheet<TViewModel>() async {
    final registration = _viewRegistry.getRegistration(TViewModel.toString()) ??
        (throw Exception('View not registered for $TViewModel'));

    await showModalBottomSheet(
      context: rootNavigatorKey.currentState!.context,
      builder: (context) => registration.viewCreator(),
    );
  }

  @override
  Future<TResult?> showBottomSheetResult<TViewModel, TResult>() async {
    final registration = _viewRegistry.getRegistration(TViewModel.toString()) ??
        (throw Exception('View not registered for $TViewModel'));

    return await showModalBottomSheet<TResult>(
        context: rootNavigatorKey.currentState!.context,
        builder: (context) => registration.viewCreator());
  }

  @override
  Future<void> showBottomSheetWithParameter<TViewModel, TParameter>(
      TParameter parameter) async {
    final registration =
        _viewRegistry.getRegistrationWithParameter(TViewModel.toString()) ??
            (throw Exception('View not registered for $TViewModel'));

    await showModalBottomSheet(
        context: rootNavigatorKey.currentState!.context,
        builder: (context) => registration.viewCreator(parameter));
  }

  @override
  Future<TResult?>
      showBottomSheetWithParameterResult<TViewModel, TParameter, TResult>(
          TParameter parameter) async {
    final registration =
        _viewRegistry.getRegistrationWithParameter(TViewModel.toString()) ??
            (throw Exception('View not registered for $TViewModel'));

    return await showModalBottomSheet<TResult>(
        context: rootNavigatorKey.currentState!.context,
        builder: (context) => registration.viewCreator(parameter));
  }

  @override
  void closeBottomSheet() {
    rootNavigatorKey.currentState?.pop();
  }

  @override
  void closeBottomSheetResult<TResult>(TResult result) {
    rootNavigatorKey.currentState?.pop(result);
  }

  void closeModalInternal() {
    state = state.copyWith(
        stack: [...state.stack.removeLastImmutable()],
        shouldClearCache: false).copyWithUpdateCurrentPageBuildFlag(true);
  }

  void setShouldClearCache(bool shouldClearCache) {
    state = state.copyWith(shouldClearCache: shouldClearCache);
  }

  Future<void> navigateInternal(List<NavigationSegment> segments) async {
    try {
      var canBack = true;
      var currentPageId =
          getCurrentPageId() ?? (throw Exception('getCurrentPageId() is null'));

      for (final segment in segments) {
        switch (segment) {
          case ActionSegment():
            await segment.action();
            break;
          case BackSegment():
            if (canBack) {
              currentPageId =
                  await _processBackNavigation(segment, currentPageId);
            }
            break;
          case ChangeTabSegment():
            currentPageId =
                await _processChangeTabNavigation(segment, currentPageId);
            break;
          case DelaySegment():
            await Future.delayed(
                Duration(milliseconds: segment.milliSecondsDelay));
            break;
          case PageSegment():
            currentPageId = await _processPageNavigation(segment);
            // 一度でも進むナビゲーションをした後は戻れない
            canBack = false;
            break;
          case NavigatorSegment():
            currentPageId = await _processNavigatorNavigation(segment);
            canBack = false;
            break;
          case TabSegment():
            currentPageId = await _processTabNavigation(segment);
            canBack = false;
            break;
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
      rethrow;
    }
  }

  Future<TResult?> navigateResultInternal<TResult>(
      NavigationSegment segment) async {
    try {
      String targetPageId = '';

      switch (segment) {
        case PageSegment():
          targetPageId = await _processPageNavigation(segment);
          break;
        case NavigatorSegment():
          await _processNavigatorNavigation(segment);
          targetPageId = state.findCurrentNavigatorEntry()?.pageId ??
              (throw Exception('targetPageId is null'));
          break;
        case TabSegment():
          await _processTabNavigation(segment);
          targetPageId = state.stack.last.pageId;
          break;
      }

      final completer = Completer<TResult>();
      resultAttaches[targetPageId] = (
        // 結果が返ってきた場合は型に適合しているかチェックして結果を返す
        (result) {
          if (result is TResult) {
            completer.complete(result);
          } else {
            // 型に適合していない場合はエラーを返す
            completer.completeError(
                NavigationResultException('result is not TResult'));
          }
        },
        // キャンセルされた場合はエラーを返す
        () => completer.completeError(NavigationResultException('canceled'))
      );

      try {
        // 結果が返されるまで待つ
        return await completer.future;
      } on NavigationResultException catch (e) {
        debugPrint(e.message);
        return null;
      } finally {
        // 成否問わず結果が返されたら結果待ちの対象から削除する
        resultAttaches.remove(targetPageId);
      }
    } catch (ex) {
      debugPrint(ex.toString());
      rethrow;
    }
  }

  Future<String> _processPageNavigation(PageSegment segment) async {
    final pageEntry = PageEntry(
      isLazy: false,
      registrationKey: segment.registrationKey,
      param: segment.param,
    );
    final completer = Completer<bool>();
    pageBuildCompleters[pageEntry.pageId] = completer;
    // ページを追加する
    state = state
        .copyWithAddPageToCurrentNavigator(pageEntry)
        .copyWith(shouldClearCache: false);
    await completer.withTimeout(Duration(milliseconds: 500), false,
        onTimeout: () {
      debugPrint('pageBuildCompleters[${pageEntry.pageId}] timeout');
    });
    return pageEntry.pageId;
  }

  Future<String> _processNavigatorNavigation(NavigatorSegment segment) async {
    // 最後の子ページは必ず即座にbuildする（遅延しない）
    segment.children.last.isLazy = false;
    final navigatorEntry = NavigatorEntry(
      children: segment.children
          .map((e) => PageEntry(
                isLazy: e.isLazy,
                registrationKey: e.registrationKey,
                param: e.param,
              ))
          .toList(),
      isLazy: false, // NavigatorEntry自身は必ず即座にbuildする
      navigatorKey: GlobalKey<NavigatorState>(),
    );
    // 最後の子ページを次のCurrentPageとするために、そのページIDを取得する
    final targetPageId = navigatorEntry.children.last.pageId;

    final completer = Completer<bool>();
    pageBuildCompleters[targetPageId] = completer;
    // モーダルスタックに追加する
    state = state.copyWith(
        stack: [...state.stack, navigatorEntry], shouldClearCache: false);
    // ページがbuildされるまで待つ
    await completer.withTimeout(Duration(milliseconds: 500), false,
        onTimeout: () {
      debugPrint('pageBuildCompleters[$targetPageId] timeout');
    });
    // CurrentPageIdとしてそのページIDを返す
    return targetPageId;
  }

  Future<String> _processTabNavigation(TabSegment segment) async {
    // 選択されているタブとその末尾の子ページは必ず即座にbuildする（遅延しない）
    final selectedNavigator = segment.children[segment.selectedIndex];
    selectedNavigator.isLazy = false;
    final lastChild = selectedNavigator.children.last;
    lastChild.isLazy = false;

    final tabEntry = TabEntry(
      registrationKey: segment.registrationKey,
      selectedIndex: segment.selectedIndex,
      isLazy: false, // TabEntry自身は必ず即座にbuildする
      children: segment.children
          .map((navigatorSegment) => NavigatorEntry(
                isLazy: navigatorSegment.isLazy,
                navigatorKey: GlobalKey<NavigatorState>(),
                children: navigatorSegment.children
                    .map((pageSegment) => PageEntry(
                          isLazy: pageSegment.isLazy,
                          registrationKey: pageSegment.registrationKey,
                          param: pageSegment.param,
                        ))
                    .toList(),
              ))
          .toList(),
    );

    // 選択されているタブの末尾の子ページを次のCurrentPageとするために、そのページIDを取得する
    final targetPageId =
        tabEntry.children[tabEntry.selectedIndex].children.last.pageId;

    // ページがbuildされるまで待つ
    final completer = Completer<bool>();
    pageBuildCompleters[targetPageId] = completer;
    // モーダルスタックに追加する
    state = state
        .copyWith(stack: [...state.stack, tabEntry], shouldClearCache: false);
    // ページがbuildされるまで待つ
    await completer.withTimeout(Duration(milliseconds: 500), false,
        onTimeout: () {
      debugPrint('pageBuildCompleters[$targetPageId] timeout');
    });
    // CurrentPageIdとしてそのページIDを返す
    return targetPageId;
  }

  Future<String> _processBackNavigation(
      BackSegment segment, String currentPageId) async {
    final completer = Completer<bool>();

    // モーダルPopの場合
    if (segment.isModal) {
      if (state.stack.length < 2) {
        throw Exception(
            'stack has insufficient elements (${state.stack.length}) to get previous page');
      }
      final targetPageId =
          state.stack[state.stack.length - 2].getCurrentEntry().pageId;
      pageBuildCompleters[targetPageId] = completer;

      closeModalInternal();

      await completer.withTimeout(Duration(milliseconds: 500), false,
          onTimeout: () {
        debugPrint('pageBuildCompleters[$targetPageId] timeout');
      });

      return getCurrentPageId() ??
          (throw Exception('getCurrentPageId() is null'));
      
    } 
    // PopToRoot遷移の場合
    else if (segment.isRoot) {
      final firstChild = state.findCurrentNavigatorFirstChildEntry();
      if (firstChild == null) throw Exception('firstChild is null');
      pageBuildCompleters[firstChild.pageId] = completer;

      // PopToRoot処理実行
      state = state
          .copyWithKeepOnlyFirstChildOfCurrentNavigator()
          .copyWith(shouldClearCache: false);

      await completer.withTimeout(Duration(milliseconds: 500), false,
          onTimeout: () {
        debugPrint('pageBuildCompleters[${firstChild.pageId}] timeout');
      });

      return firstChild.pageId;      
    } 
    // Pop遷移の場合
    else {
      final navigator = state.findCurrentNavigatorEntry() ??
          (throw Exception('currentNavigator is null'));
      if (navigator.children.length < 2) {
        throw Exception(
            'Navigator has insufficient children (${navigator.children.length}) to get previous page');
      }
      final previousPageId =
          navigator.children[navigator.children.length - 2].pageId;
      pageBuildCompleters[previousPageId] = completer;

      pop(currentPageId);

      await completer.withTimeout(Duration(milliseconds: 500), false,
          onTimeout: () {
        debugPrint('pageBuildCompleters[$currentPageId] timeout');
      });

      return previousPageId;
    }
  }

  Future<String> _processChangeTabNavigation(
      ChangeTabSegment segment, String currentPageId) async {
    final tabEntry = state.stack.whereType<TabEntry>().lastOrNull ??
        (throw Exception('tabEntry is null'));
    final navigator = tabEntry.children.elementAtOrNull(segment.index) ??
        (throw Exception('navigator is null'));
    final targetPage = navigator.children.lastOrNull ??
        (throw Exception('targetPage is null'));

    final completer = Completer<bool>();
    pageBuildCompleters[targetPage.pageId] = completer;
    // タブの選択インデックスを変更
    setTabSelectedIndex(tabEntry.pageId, segment.index);
    await completer.withTimeout(Duration(milliseconds: 500), false,
        onTimeout: () {
      debugPrint('pageBuildCompleters[${targetPage.pageId}] timeout');
    });
    return targetPage.pageId;
  }

  // 特定のページが現在表示されているかチェック
  bool isCurrentPage(String pageId) {
    if (state.stack.isEmpty) return false;

    final lastEntry = state.stack.last;
    switch (lastEntry) {
      case PageEntry pageEntry:
        return pageEntry.pageId == pageId;
      case NavigatorEntry navigatorEntry:
        return navigatorEntry.children.isNotEmpty &&
            navigatorEntry.children.last.pageId == pageId;
      case TabEntry tabEntry:
        final selectedNavigator = tabEntry.children[tabEntry.selectedIndex];
        return selectedNavigator.children.isNotEmpty &&
            selectedNavigator.children.last.pageId == pageId;
    }
    return false;
  }

  // 現在表示されているページのPageIdを取得
  String? getCurrentPageId() {
    if (state.stack.isEmpty) return null;

    final lastEntry = state.stack.last;
    switch (lastEntry) {
      case PageEntry pageEntry:
        return pageEntry.pageId;
      case NavigatorEntry navigatorEntry:
        return navigatorEntry.children.isNotEmpty
            ? navigatorEntry.children.last.pageId
            : null;
      case TabEntry tabEntry:
        final selectedNavigator = tabEntry.children[tabEntry.selectedIndex];
        return selectedNavigator.children.isNotEmpty
            ? selectedNavigator.children.last.pageId
            : null;
    }
    return null;
  }

  void pop(String pageId) {
    final path = findEntryWithPath(pageId);
    if (path == null) return;
    state = state
        .copyWithRemoveEntry(path)
        .copyWithUpdateCurrentPageBuildFlag(true)
        .copyWith(shouldClearCache: false);
  }

  void systemPop(String pageId) {
    final path = findEntryWithPath(pageId);
    // ページが見つからない場合は何もしない
    if (path == null) return;

    // 子ページが1つの場合は何もしない
    final firstChild = state.findCurrentNavigatorFirstChildEntry();
    if(firstChild == null || firstChild.pageId == pageId){
      return;
    }

    state = state
        .copyWithRemoveEntry(path)
        .copyWithUpdateCurrentPageBuildFlag(true)
        .copyWith(shouldClearCache: false);

    // 結果待ちの対象ページならキャンセルを通知する
    if (resultAttaches.containsKey(pageId)) {
      final (_, onCancel) = resultAttaches[pageId]!;
      onCancel();
    }

    // 子ページの結果待ちの対象ページがあれば全てキャンセルを通知する
    switch (path.entry) {
      case NavigatorEntry navigatorEntry:
        for (final child in navigatorEntry.children) {
          if (resultAttaches.containsKey(child.pageId)) {
            final (_, onCancel) = resultAttaches[child.pageId]!;
            onCancel();
          }
        }
        break;
      case TabEntry tabEntry:
        for (final navigator in tabEntry.children) {
          for (final child in navigator.children) {
            if (resultAttaches.containsKey(child.pageId)) {
              final (_, onCancel) = resultAttaches[child.pageId]!;
              onCancel();
            }
          }
        }
        break;
    }
  }

  void setTabSelectedIndex(String pageId, int index) {
    final target = state.stack
        .whereType<TabEntry>()
        .lastWhereOrNull((e) => e.pageId == pageId);
    if (target == null) return;
    final tmpState = state.copyWith(
        stack: state.stack
            .replaceImmutable(target, target.copyWith(selectedIndex: index)));
    state = tmpState
        .copyWithUpdateCurrentPageBuildFlag(true)
        .copyWith(shouldClearCache: false);
  }

  // カレントページのisLazyフラグを変更
  void setCurrentPageLazyFlag(bool isLazy) {
    state = state.copyWithUpdateCurrentPageBuildFlag(!isLazy);
  }

  NavigationPath? findEntryWithPath(String pageId) {
    for (int i = state.stack.length - 1; i >= 0; i--) {
      final result = _searchWithPath(state.stack[i], pageId, [i]);
      if (result != null) return result;
    }
    return null;
  }

  NavigationPath? _searchWithPath(
      NavigationEntry entry, String pageId, List<int> currentPath) {
    if (entry.pageId == pageId) {
      return NavigationPath(currentPath, entry);
    }

    switch (entry) {
      case NavigatorEntry navigatorEntry:
        for (int i = navigatorEntry.children.length - 1; i >= 0; i--) {
          final child = navigatorEntry.children[i];
          if (child.pageId == pageId) {
            return NavigationPath([...currentPath, i], child);
          }
        }
        break;
      case TabEntry tabEntry:
        // 選択されているタブから優先探索
        final selectedIndex = tabEntry.selectedIndex;
        final selectedNavigator = tabEntry.children[selectedIndex];
        final found = _searchWithPath(
            selectedNavigator, pageId, [...currentPath, selectedIndex]);
        if (found != null) return found;

        // 他のタブも探索
        for (int i = tabEntry.children.length - 1; i >= 0; i--) {
          if (i != selectedIndex) {
            final found = _searchWithPath(
                tabEntry.children[i], pageId, [...currentPath, i]);
            if (found != null) return found;
          }
        }
        break;
    }
    return null;
  }

  NavigatorEntry? getCurrentNavigatorEntry() {
    return state.findCurrentNavigatorEntry();
  }

  List<NavigationEntry> getModalStack() {
    return state.stack;
  }
}

final navigationServiceStateProvider =
    NotifierProvider<InternalNavigationService, NavigationState>(
        InternalNavigationService.new);

final internalNavigationServiceProvider = Provider<InternalNavigationService>(
    (ref) => ref.read(navigationServiceStateProvider.notifier));
