import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NavigationEntry {
  final String pageId;
  final bool isBuild;

  NavigationEntry({String? pageId, this.isBuild = true})
      : pageId = pageId ?? Uuid().v4();

  NavigationEntry copyWith({String? pageId, bool? isBuild}) => NavigationEntry(
        pageId: pageId ?? this.pageId,
        isBuild: isBuild ?? this.isBuild,
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
    super.isBuild,
  });

  @override
  PageEntry getCurrentEntry() => this;

  @override
  PageEntry copyWith({
    String? registrationKey,
    dynamic param,
    String? pageId,
    bool? isBuild,
  }) =>
      PageEntry(
        registrationKey: registrationKey ?? this.registrationKey,
        param: param ?? this.param,
        pageId: pageId ?? this.pageId,
        isBuild: isBuild ?? this.isBuild,
      );
}

class NavigatorEntry extends NavigationEntry {
  final List<PageEntry> children;
  final GlobalKey<NavigatorState> navigatorKey;

  NavigatorEntry({
    this.children = const [],
    super.pageId,
    super.isBuild,
    required this.navigatorKey,
  });

  @override
  PageEntry getCurrentEntry() => children.last;

  @override
  NavigatorEntry copyWith({
    String? pageId,
    List<PageEntry>? children,
    bool? isBuild,
    GlobalKey<NavigatorState>? navigatorKey,
  }) =>
      NavigatorEntry(
        pageId: pageId ?? this.pageId,
        children: children ?? this.children,
        isBuild: isBuild ?? this.isBuild,
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
    super.isBuild,
  });

  @override
  PageEntry getCurrentEntry() => children[selectedIndex].getCurrentEntry();

  @override
  TabEntry copyWith({
    String? pageId,
    int? selectedIndex,
    List<NavigatorEntry>? children,
    String? registrationKey,
    bool? isBuild,
  }) =>
      TabEntry(
        pageId: pageId ?? this.pageId,
        children: children ?? this.children,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        registrationKey: registrationKey ?? this.registrationKey,
        isBuild: isBuild ?? this.isBuild,
      );
}
