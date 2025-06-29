import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'extensions/list_extensions.dart';
import 'extensions/page_extensions.dart';
import 'internal_navigation_service.dart';
import 'viewmodel_core.dart';
import 'navigation_entry.dart';
import 'tab_base_widget.dart';
import 'view_registry.dart';

typedef PageValue = ({PageEntry entry, Widget view});
typedef TabPageValue = ({TabEntry entry, Widget view});

class Empty {}

class EmptyPage extends MaterialPage {
  const EmptyPage({super.key}) : super(child: const SizedBox.shrink());

  @override
  bool canUpdate(Page other) {
    // RuntimeTypeが異なっても同一扱いとする
    return other.key == key;
  }
}

class ContentPage extends MaterialPage {
  const ContentPage({required super.child, super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => child,
    );
  }

  @override
  bool canUpdate(Page other) {
    // RuntimeTypeが異なっても同一扱いとする
    return other.key == key;
  }
}

class NavigatorPage extends MaterialPage {
  const NavigatorPage({required super.child, super.key});

  @override
  bool canUpdate(Page other) {
    // RuntimeTypeが異なっても同一扱いとする
    return other.key == key;
  }

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => child,
    );
  }
}

class TabPage extends MaterialPage {
  const TabPage({required super.child, super.key});

  @override
  bool canUpdate(Page other) {
    // RuntimeTypeが異なっても同一扱いとする
    return other.key == key;
  }

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => child,
    );
  }
}

class AppRouterDelegate extends RouterDelegate<Empty>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin,
        WidgetsBindingObserver {
  final WidgetRef ref;
  @override
  late final GlobalKey<NavigatorState> navigatorKey;
  final Map<String, ProviderListenable> _providerCache = {};
  late InternalNavigationService _navService;
  late ViewRegistry _viewRegistry;
  final Map<String, List<Page<dynamic>>> _pagesStack = {_rootPageId: []};
  final Map<String, List<Widget>> _tabsCache = {};
  static const String _rootPageId = '0';

  AppRouterDelegate(this.ref) {
    _navService = ref.read(internalNavigationServiceProvider);
    navigatorKey = _navService.rootNavigatorKey;
    _viewRegistry = ref.read(viewRegistryProvider);

    WidgetsBinding.instance.addObserver(this);

    // Riverpodの状態変更時に通知(Stackだけを監視)
    ref.listen<List<NavigationEntry>>(
        navigationServiceStateProvider.select((state) => state.stack),
        (previous, next) {
      if (ref.read(navigationServiceStateProvider).shouldClearCache) {
        // クリアキャッシュフラグが立っている場合はキャッシュをクリアする
        _pagesStack.clear();
        _tabsCache.clear();
        _navService.pageBuildCompleters.clear();
        // // フラグを解除する
        // _navService.setShouldClearCache(false);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModels = _getViewModels().toList();
      for (final viewModel in viewModels.skip(1)) {
        // ignore: invalid_use_of_protected_member
        viewModel.onInActiveInternal();
      }
      
      if (viewModels.isNotEmpty) {
        // ignore: invalid_use_of_protected_member
        viewModels.first.onActiveInternal();
      }
      final pageId = _navService.getCurrentPageId();
      if (_navService.pageBuildCompleters.containsKey(pageId)) {
        debugPrint('pageBuildCompleters[$pageId] complete');
        _navService.pageBuildCompleters[pageId]?.complete(true);
        _navService.pageBuildCompleters.remove(pageId);
      }
    });   

    final pages = _buildOrLoadPages().toList();

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onDidRemovePage: (page) {
        // SystemBackなどでpop処理が実行された時
        // またはpagesの状態を手動で変更した場合に呼ばれる
        // pop処理の場合はページはまだスタックに残っているが
        // 手動でpagesの状態を変更した場合はページはスタックから削除されている
        // そのため状況に合わせて適切に処理する必要がある
        final key = page.key.toStringValue();

        // タブのキャッシュを削除
        if (_tabsCache.containsKey(key)) {
          _tabsCache.remove(key);
        }
        // Navigatorスタックを削除
        if (_pagesStack.containsKey(key)) {
          _pagesStack.remove(key);
        }
        // ルートスタックから削除
        _pagesStack[_rootPageId]!.remove(page);

        // 念の為buildが終わったタイミングでpopする
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navService.systemPop(page.key.toStringValue());
        });
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async {
    // 外部からルートセットする場合（ディープリンクや復元対応など）
    // 例: ref.read(navigationServiceProvider.notifier).setStack(...)
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _navService.onAppResumed();
        for (final viewModel in _getViewModels()) {
          viewModel.onResumed();
        }
        break;
      case AppLifecycleState.paused:
        _navService.onAppPaused();
        for (final viewModel in _getViewModels()) {
          viewModel.onPaused();
        }
        break;
      default:
        break;
    }
  }

  Iterable<Page<dynamic>> _buildOrLoadPages() sync* {
    if (!_pagesStack.containsKey(_rootPageId)) {
      _pagesStack[_rootPageId] = [];
    }
    final stack = _pagesStack[_rootPageId]!;

    for (final entry in ref.read(navigationServiceStateProvider).stack) {
      final index =
          stack.indexWhere((x) => x.key.toStringValue() == entry.pageId);

      // ルートスタックに存在しない場合はビルドする
      if (index == -1) {
        switch (entry) {
          case NavigatorEntry navigatorEntry:
            final navigatorPage = _buildNavigatorPage(navigatorEntry);
            stack.add(navigatorPage);
            yield navigatorPage;
            break;
          case TabEntry tabEntry:
            final tabPage = _buildTabPage(tabEntry);
            stack.add(tabPage);
            yield tabPage;
            break;
        }
        continue;
      }

      final page = stack[index];

      // EmptyPageでかつ遅延対象でない場合はビルドしなおす
      if (page is EmptyPage && !entry.isLazy) {
        switch (entry) {
          case NavigatorEntry navigatorEntry:
            final navigatorPage = _buildNavigatorPage(navigatorEntry);
            stack[index] = navigatorPage;
            yield navigatorPage;
            break;
          case TabEntry tabEntry:
            final tabPage = _buildTabPage(tabEntry);
            stack[index] = tabPage;
            yield tabPage;
            break;
        }
        continue;
      }

      yield page;
    }
  }

  Page<dynamic> _buildTabPage(TabEntry entry) {
    if (entry.isLazy) {
      return EmptyPage(key: ValueKey(entry.pageId));
    }

    // タブの状態オブジェクトを生成
    final tabConfigState = _buildTabConfigState(entry.pageId);
    // タブ本体ページを生成
    final tabPageValue = _getTabPageValue(entry, tabConfigState);

    return TabPage(key: ValueKey(entry.pageId), child: tabPageValue.view);
  }

  Widget _buildNavigator(NavigatorEntry entry, {bool isTab = false}) {
    return Consumer(
      key: isTab ? ValueKey(entry.pageId) : null,
      builder: (context, ref, child) {
        final pages = ref.watch(navigationServiceStateProvider.select((state) {
          final target = state.findNavigatorEntry(entry.pageId);
          if (target == null) {
            return [ContentPage(child: const SizedBox.shrink())];
          }
          return _buildOrLoadContentPages(target).toList();
        }));
        return Navigator(
          key: entry.navigatorKey,
          pages: pages,
          onDidRemovePage: (page) {
            // Navigatorスタック自体が存在しない場合（親が削除された場合）は何もしない
            if (!_pagesStack.containsKey(entry.pageId)) return;

            final key = page.key.toStringValue();
            _pagesStack[entry.pageId]!.remove(page);
            _navService.systemPop(key);
          },
        );
      },
    );
  }

  Page<dynamic> _buildNavigatorPage(NavigatorEntry entry) {
    if (entry.isLazy) {
      return EmptyPage(key: ValueKey(entry.pageId));
    }
    return NavigatorPage(
      key: ValueKey(entry.pageId),
      child: _buildNavigator(entry),
    );
  }

  Iterable<Page<dynamic>> _buildOrLoadContentPages(NavigatorEntry entry) sync* {
    if (!_pagesStack.containsKey(entry.pageId)) {
      _pagesStack[entry.pageId] = [];
    }
    final stack = _pagesStack[entry.pageId]!;

    for (final child in entry.children) {
      final index =
          stack.indexWhere((x) => x.key.toStringValue() == child.pageId);

      // スタックに存在しない場合はビルドする
      if (index == -1) {
        final newPage = _buildContentPage(child);
        stack.add(newPage);
        yield newPage;
        continue;
      }

      final page = stack[index];

      // EmptyPageでかつ遅延対象でない場合はビルドしなおす
      if (page is EmptyPage && !child.isLazy) {
        final newPage = _buildContentPage(child);
        // ページを入れ替える
        stack[index] = newPage;
        yield newPage;
        continue;
      }

      // スタックに存在する場合はそのまま返す
      yield page;
    }
  }

  Page<dynamic> _buildContentPage(PageEntry entry) {
    if (entry.isLazy) {
      return EmptyPage(key: ValueKey(entry.pageId));
    }
    final pageValue = _getPageValue(entry);
    final newPage = ContentPage(
      key: ValueKey(pageValue.entry.pageId),
      child: pageValue.view,
    );
    return newPage;
  }

  TabConfigState _buildTabConfigState(String pageId) {
    // index取得用Providerの生成
    final indexProvider = Provider<int>((ref) {
      return ref.watch(navigationServiceStateProvider.select((state) {
        final target = state.stack
            .whereType<TabEntry>()
            .lastWhereOrNull((e) => e.pageId == pageId);
        if (target == null) return 0;
        return target.selectedIndex;
      }));
    });

    // 子Widgetリスト取得用Providerの生成
    final childProvider = Provider<List<Widget>>((ref) {
      return ref.watch(navigationServiceStateProvider.select((state) {
        final target = state.stack
            .whereType<TabEntry>()
            .lastWhereOrNull((e) => e.pageId == pageId);
        if (target == null) return [const SizedBox.shrink()];

        if (!_tabsCache.containsKey(pageId)) {
          _tabsCache[pageId] = [];
        }
        final tabs = _tabsCache[pageId]!;

        for (final child in target.children) {
          var index =
              tabs.indexWhere((x) => x.key.toStringValue() == child.pageId);
          if (index == -1) {
            final newTab = !child.isLazy
                ? _buildNavigator(child, isTab: true)
                : SizedBox.shrink(key: ValueKey(child.pageId));
            tabs.add(newTab);
            continue;
          }

          final tab = tabs[index];
          if (tab is SizedBox && !child.isLazy) {
            final replacedTab = _buildNavigator(child, isTab: true);
            tabs[index] = replacedTab;
            continue;
          }
        }

        return tabs;
      }));
    });

    // 現在のインデックスを設定するためのセッター関数
    setter(index) {
      _navService.setTabSelectedIndex(pageId, index);
    }

    return TabConfigState(
        childrenProvider: childProvider,
        currentIndexProvider: indexProvider,
        setCurrentIndex: setter);
  }

  Iterable<ProviderListenable?> _getViewModelProviders() sync* {
    final stack = ref.read(navigationServiceStateProvider).stack;
    for (final entry in stack.reversed) {
      yield* _getStackValues(entry, (child) => _getViewModelProvider(child),
          isReverse: true);
    }
  }

  Iterable<ViewModelCore> _getViewModels() sync* {
    for (final provider in _getViewModelProviders()) {
      if (provider == null) continue;
      if (ref.read(provider) case ViewModelCore viewModel) {
        yield viewModel;
      }
    }
  }

  Iterable<T> _getStackValues<T>(
      NavigationEntry entry, T? Function(PageEntry) func,
      {bool isReverse = false}) sync* {
    switch (entry) {
      case TabEntry tabEntry:
        final selectedTab = tabEntry.children[tabEntry.selectedIndex];
        final children = [
          ...tabEntry.children
              .where((child) => child.pageId != selectedTab.pageId),
          selectedTab,
        ];
        for (final navigator in isReverse ? children.reversed : children) {
          yield* _getStackValues(navigator, func, isReverse: isReverse);
        }

        break;
      case NavigatorEntry navigatorEntry:
        for (final child in isReverse
            ? navigatorEntry.children.reversed
            : navigatorEntry.children) {
          final result = func(child);
          if (result != null) yield result;
        }
        break;
      case PageEntry pageEntry:
        final result = func(pageEntry);
        if (result != null) yield result;
        break;
      default:
    }
  }

  ProviderListenable? _getViewModelProvider(PageEntry entry) {
    if (entry.isLazy) return null;

    if (_providerCache.containsKey(entry.pageId)) {
      return _providerCache[entry.pageId];
    }

    if (entry.param != null) {
      final registration = _viewRegistry
              .getRegistrationWithParameter(entry.registrationKey) ??
          (throw Exception('View not registered for ${entry.registrationKey}'));
      final provider = registration.viewModelCreator(entry.param);
      _providerCache[entry.pageId] = provider;
      return provider;
    } else {
      final registration = _viewRegistry
              .getRegistration(entry.registrationKey) ??
          (throw Exception('View not registered for ${entry.registrationKey}'));
      final provider = registration.viewModelProvider;
      _providerCache[entry.pageId] = provider;
      return provider;
    }
  }

  PageValue _getPageValue(PageEntry entry) {
    // 遅延対象の場合は空のWidgetを返す
    if (entry.isLazy) return (entry: entry, view: const SizedBox.shrink());

    if (entry.param != null) {
      final registration = _viewRegistry
              .getRegistrationWithParameter(entry.registrationKey) ??
          (throw Exception('View not registered for ${entry.registrationKey}'));
      final view = registration.viewCreator(entry.param);
      return (entry: entry, view: view);
    } else {
      final registration = _viewRegistry
              .getRegistration(entry.registrationKey) ??
          (throw Exception('View not registered for ${entry.registrationKey}'));
      final view = registration.viewCreator();
      return (entry: entry, view: view);
    }
  }

  TabPageValue _getTabPageValue(TabEntry entry, TabConfigState configState) {
    final registration = _viewRegistry
            .getTabRegistration(entry.registrationKey) ??
        (throw Exception('View not registered for ${entry.registrationKey}'));
    final view = registration.tabCreator(configState);
    return (entry: entry, view: view);
  }
}
