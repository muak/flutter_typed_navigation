import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NavigationEntry {
  final String pageId;
  final bool isLazy;

  NavigationEntry({String? pageId, this.isLazy = false})
      : pageId = pageId ?? Uuid().v4();

  NavigationEntry copyWith({String? pageId, bool? isLazy}) => NavigationEntry(
        pageId: pageId ?? this.pageId,
        isLazy: isLazy ?? this.isLazy,
      );

  NavigationEntry getCurrentEntry() => this;
}

class PageEntry extends NavigationEntry {
  final String registrationKey;
  final dynamic param;

  PageEntry({
    required this.registrationKey,
    this.param,
    super.pageId,
    super.isLazy,
  });

  @override
  PageEntry getCurrentEntry() => this;

  @override
  PageEntry copyWith({
    String? registrationKey,
    dynamic param,
    String? pageId,
    bool? isLazy,
  }) =>
      PageEntry(
        registrationKey: registrationKey ?? this.registrationKey,
        param: param ?? this.param,
        pageId: pageId ?? this.pageId,
        isLazy: isLazy ?? this.isLazy,
      );
}

class NavigatorEntry extends NavigationEntry {
  final List<PageEntry> children;
  final GlobalKey<NavigatorState> navigatorKey;

  NavigatorEntry({
    this.children = const [],
    super.pageId,
    super.isLazy,
    required this.navigatorKey,
  });

  @override
  PageEntry getCurrentEntry() => children.last;

  @override
  NavigatorEntry copyWith({
    String? pageId,
    List<PageEntry>? children,
    bool? isLazy,
    GlobalKey<NavigatorState>? navigatorKey,
  }) =>
      NavigatorEntry(
        pageId: pageId ?? this.pageId,
        children: children ?? this.children,
        isLazy: isLazy ?? this.isLazy,
        navigatorKey: navigatorKey ?? this.navigatorKey,
      );
}

class TabEntry extends NavigationEntry {
  final List<NavigatorEntry> children;
  final int selectedIndex;
  final String registrationKey;

  TabEntry({
    this.children = const [],
    this.selectedIndex = 0,
    required this.registrationKey,
    super.pageId,
    super.isLazy,
  });

  @override
  PageEntry getCurrentEntry() => children[selectedIndex].getCurrentEntry();

  @override
  TabEntry copyWith({
    String? pageId,
    int? selectedIndex,
    List<NavigatorEntry>? children,
    String? registrationKey,
    bool? isLazy,
  }) =>
      TabEntry(
        pageId: pageId ?? this.pageId,
        children: children ?? this.children,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        registrationKey: registrationKey ?? this.registrationKey,
        isLazy: isLazy ?? this.isLazy,
      );
}
