import 'extensions/list_extensions.dart';
import 'navigation_entry.dart';

class NavigationPath {
  final List<int> indices; // 各階層でのインデックス
  final NavigationEntry entry;

  NavigationPath(this.indices, this.entry);
}

class NavigationState {
  final List<NavigationEntry> stack;
  final bool shouldClearCache;

  const NavigationState({this.stack = const [], this.shouldClearCache = false});

  NavigatorEntry? findNavigatorEntry(String pageId) {
    for (final entry in stack) {
      if (entry is NavigatorEntry && entry.pageId == pageId) {
        return entry;
      }
      if (entry is TabEntry) {
        for (final child in entry.children) {
          if (child.pageId == pageId) {
            return child;
          }
        }
      }
    }
    return null;
  }

  // 現在のNavigatorEntryを取得
  NavigatorEntry? findCurrentNavigatorEntry() {
    if (stack.isEmpty) return null;

    final lastEntry = stack.last;

    switch (lastEntry) {
      case NavigatorEntry navigatorEntry:
        // 直接NavigatorEntryの場合、その最初の子を返す
        return navigatorEntry;

      case TabEntry tabEntry:
        // TabEntryの場合、選択されたNavigatorEntryの最初の子を返す
        final selectedNavigator = tabEntry.children[tabEntry.selectedIndex];
        return selectedNavigator;

      default:
        return null;
    }
  }

  // 現在のNavigatorの最初の子を取得
  PageEntry? findCurrentNavigatorFirstChildEntry() {
    final currentNavigator = findCurrentNavigatorEntry();
    if (currentNavigator == null) return null;

    if(currentNavigator.children.isEmpty) return null;
    return currentNavigator.children.first;
  }

  NavigationState copyWith(
          {List<NavigationEntry>? stack, bool? shouldClearCache}) =>
      NavigationState(
          stack: stack ?? this.stack,
          shouldClearCache: shouldClearCache ?? this.shouldClearCache);

  NavigationState copyWithRemoveEntry(NavigationPath path) {
    if (path.indices.isEmpty) return this;

    // 第1階層（stackレベル）の削除
    if (path.indices.length == 1) {
      final index = path.indices[0];
      final targetEntry = stack[index];
      final newStack = stack.removeImmutable(targetEntry);
      return copyWith(stack: newStack);
    }

    // 第2階層以降の削除
    final stackIndex = path.indices[0];
    final targetEntry = stack[stackIndex];

    switch (targetEntry) {
      case NavigatorEntry navigatorEntry:
        if (path.indices.length == 2) {
          // NavigatorEntry内のPageEntryを削除
          final childIndex = path.indices[1];
          final targetChild = navigatorEntry.children[childIndex];
          final newChildren =
              navigatorEntry.children.removeImmutable(targetChild);
          final newNavigatorEntry =
              navigatorEntry.copyWith(children: newChildren);
          final newStack =
              stack.replaceImmutable(targetEntry, newNavigatorEntry);
          return copyWith(stack: newStack);
        }
        break;

      case TabEntry tabEntry:
        if (path.indices.length == 3) {
          // TabEntry > NavigatorEntry > PageEntryを削除
          final tabChildIndex = path.indices[1];
          final pageIndex = path.indices[2];
          final targetNavigator = tabEntry.children[tabChildIndex];
          final targetPage = targetNavigator.children[pageIndex];
          final newPageChildren =
              targetNavigator.children.removeImmutable(targetPage);
          final newNavigatorEntry =
              targetNavigator.copyWith(children: newPageChildren);
          final newTabChildren = tabEntry.children
              .replaceImmutable(targetNavigator, newNavigatorEntry);
          final newTabEntry = tabEntry.copyWith(children: newTabChildren);
          final newStack = stack.replaceImmutable(targetEntry, newTabEntry);
          return copyWith(stack: newStack);
        }
        break;
    }

    // 対応していない階層構造の場合は変更なし
    return this;
  }

  // カレントNavigatorEntryのchildrenにPageEntryをイミュータブルに追加
  NavigationState copyWithAddPageToCurrentNavigator(PageEntry pageEntry) {
    if (stack.isEmpty) return this;

    final lastEntry = stack.last;

    switch (lastEntry) {
      case NavigatorEntry navigatorEntry:
        // 直接NavigatorEntryの場合、そのchildrenにPageEntryを追加
        final newChildren = navigatorEntry.children.addImmutable(pageEntry);
        final updatedNavigatorEntry =
            navigatorEntry.copyWith(children: newChildren);
        final newStack =
            stack.replaceImmutable(lastEntry, updatedNavigatorEntry);
        return copyWith(stack: newStack);

      case TabEntry tabEntry:
        // TabEntryの場合、選択されたNavigatorEntryのchildrenにPageEntryを追加
        final selectedNavigator = tabEntry.children[tabEntry.selectedIndex];
        final newChildren = selectedNavigator.children.addImmutable(pageEntry);
        final updatedNavigator =
            selectedNavigator.copyWith(children: newChildren);
        final newTabChildren = tabEntry.children
            .replaceImmutable(selectedNavigator, updatedNavigator);
        final updatedTabEntry = tabEntry.copyWith(children: newTabChildren);
        final newStack = stack.replaceImmutable(lastEntry, updatedTabEntry);
        return copyWith(stack: newStack);

      default:
        return this;
    }
  }

  // カレントページのisLazyフラグを変更（内部的にはisBuildとして扱う）
  NavigationState copyWithUpdateCurrentPageBuildFlag(bool isBuild) {
    if (stack.isEmpty) return this;

    final lastEntry = stack.last;

    switch (lastEntry) {
      case PageEntry pageEntry:
        // 直接PageEntryの場合
        final updatedEntry = pageEntry.copyWith(isLazy: !isBuild);
        final newStack = stack.replaceImmutable(lastEntry, updatedEntry);
        return copyWith(stack: newStack);

      case NavigatorEntry navigatorEntry:
        // NavigatorEntry内の最後のPageEntryを更新し、NavigatorEntry自身のisLazyも変更
        if (navigatorEntry.children.isNotEmpty) {
          final lastChild = navigatorEntry.children.last;
          final updatedChild = lastChild.copyWith(isLazy: !isBuild);
          final newChildren =
              navigatorEntry.children.replaceImmutable(lastChild, updatedChild);
          final updatedNavigatorEntry =
              navigatorEntry.copyWith(children: newChildren, isLazy: !isBuild);
          final newStack =
              stack.replaceImmutable(lastEntry, updatedNavigatorEntry);
          return copyWith(stack: newStack);
        }
        break;

      case TabEntry tabEntry:
        // TabEntry内の選択されたNavigatorEntryの最後のPageEntryを更新し、TabEntry自身のisLazyも変更
        final selectedNavigator = tabEntry.children[tabEntry.selectedIndex];
        if (selectedNavigator.children.isNotEmpty) {
          final lastChild = selectedNavigator.children.last;
          final updatedChild = lastChild.copyWith(isLazy: !isBuild);
          final newChildren = selectedNavigator.children
              .replaceImmutable(lastChild, updatedChild);
          final updatedNavigator = selectedNavigator.copyWith(
              children: newChildren, isLazy: !isBuild);
          final newTabChildren = tabEntry.children
              .replaceImmutable(selectedNavigator, updatedNavigator);
          final updatedTabEntry =
              tabEntry.copyWith(children: newTabChildren, isLazy: !isBuild);
          final newStack = stack.replaceImmutable(lastEntry, updatedTabEntry);
          return copyWith(stack: newStack);
        }
        break;
    }

    // 更新対象が見つからない場合は変更なし
    return this;
  }

  // 現在のNavigatorの最初の子だけを残して他を削除
  NavigationState copyWithKeepOnlyFirstChildOfCurrentNavigator() {
    if (stack.isEmpty) return this;

    final lastEntry = stack.last;

    switch (lastEntry) {
      case NavigatorEntry navigatorEntry:
        // 直接NavigatorEntryの場合、その最初の子だけを残す
        if (navigatorEntry.children.isEmpty) return this;
        final firstChild = navigatorEntry.children.first;
        final updatedNavigatorEntry =
            navigatorEntry.copyWith(children: [firstChild]);
        final newStack =
            stack.replaceImmutable(lastEntry, updatedNavigatorEntry);
        return copyWith(stack: newStack);

      case TabEntry tabEntry:
        // TabEntryの場合、選択されたNavigatorEntryの最初の子だけを残す
        final selectedNavigator = tabEntry.children[tabEntry.selectedIndex];
        if (selectedNavigator.children.isEmpty) return this;
        final firstChild = selectedNavigator.children.first;
        final updatedNavigator =
            selectedNavigator.copyWith(children: [firstChild]);
        final newTabChildren = tabEntry.children
            .replaceImmutable(selectedNavigator, updatedNavigator);
        final updatedTabEntry = tabEntry.copyWith(children: newTabChildren);
        final newStack = stack.replaceImmutable(lastEntry, updatedTabEntry);
        return copyWith(stack: newStack);

      default:
        // PageEntryの場合は何もしない（Navigatorではないため）
        return this;
    }
  }
}
