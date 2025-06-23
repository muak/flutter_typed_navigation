import 'package:flutter/widgets.dart';
import 'internal_navigation_service.dart';

import 'navigation_entry.dart';
import 'navigation_segment.dart';

class AbsoluteNavigationBuilder{
  final InternalNavigationService _navigationService;
  final List<NavigationSegment> _segments = [];

  AbsoluteNavigationBuilder(this._navigationService);

  void setCurrentPageBuildFlag() {
    final lastSegment = _segments.last;
    switch (lastSegment) {
      case PageSegment pageSegment:
        pageSegment.isBuild = true;
        break;
      case NavigatorSegment navigatorSegment:
        navigatorSegment.isBuild = true;      
        final lastChild = navigatorSegment.children.last;
        lastChild.isBuild = true;        
        break;
      case TabSegment tabSegment:
        tabSegment.isBuild = true;
        final selectedNavigator = tabSegment.children[tabSegment.selectedIndex];
        selectedNavigator.isBuild = true;
        final lastChild = selectedNavigator.children.last;
        lastChild.isBuild = true;
        break;
    }
  }

  AbsoluteNavigationBuilder addNavigator(void Function(AbsoluteNavigatorBuilder) builder, {bool isBuild = true}) {
    final navigatorSegment = NavigatorSegment(isAnimated: false, isBuild: isBuild);

    final navigatorBuilder = AbsoluteNavigatorBuilder(navigatorSegment);
    builder(navigatorBuilder);
    
    _segments.add(navigatorBuilder.build());

    return this;
  }  

  AbsoluteNavigationBuilder addTabPage<TViewModel>(void Function(AbsoluteTabBuilder) builder, {int selectedIndex = 0, bool isBuild = true}) {
    final tabSegment = TabSegment(registrationKey: TViewModel.toString(), isAnimated: false, selectedIndex: selectedIndex, isBuild: isBuild);
    final tabBuilder = AbsoluteTabBuilder(tabSegment);
    builder(tabBuilder);

    _segments.add(tabBuilder.build());

    return this;
  }

  void setRoutes(){
    _navigationService.setRoutes(build());
  }

  List<NavigationEntry> build() {
    // カレントページのisBuildフラグをtrueに設定
    setCurrentPageBuildFlag();

    final entries = _segments.map((segment) {
      return switch (segment) {
        NavigatorSegment() => NavigatorEntry(
          children: segment.children.map((pageSegment) => PageEntry(
            registrationKey: pageSegment.registrationKey,
            param: pageSegment.param,
            isBuild: pageSegment.isBuild,
          )).toList(),
          isBuild: segment.isBuild,
          navigatorKey: GlobalKey<NavigatorState>(),
        ),
        TabSegment() => TabEntry(
          registrationKey: segment.registrationKey,
          selectedIndex: segment.selectedIndex,
          isBuild: segment.isBuild,
          children: segment.children.map((navigatorSegment) => NavigatorEntry(
            children: navigatorSegment.children.map((pageSegment) => PageEntry(
              registrationKey: pageSegment.registrationKey,
              param: pageSegment.param,
              isBuild: pageSegment.isBuild,
            )).toList(),
            isBuild: navigatorSegment.isBuild,
            navigatorKey: GlobalKey<NavigatorState>(),
          )).toList(),
        ),
        _ => throw ArgumentError('未対応のセグメントタイプ: ${segment.runtimeType}'),
      };
    }).toList();
    
    return entries;
  }
}



class AbsoluteNavigatorBuilder{
  final NavigatorSegment _navigatorSegment;

  AbsoluteNavigatorBuilder(this._navigatorSegment);

  AbsoluteNavigatorBuilder addPage<TViewModel>({dynamic param, bool isBuild = true}) {
    
    final pageSegment = PageSegment(
      param: param, 
      registrationKey: TViewModel.toString(), 
      isBuild: _navigatorSegment.isBuild && isBuild); // 親のisBuildがfalseの場合は子のisBuildもfalseになる
    _navigatorSegment.children.add(pageSegment);

    return this;
  }

  NavigatorSegment build() {
    return _navigatorSegment;
  }  
}

class AbsoluteTabBuilder{
  final TabSegment _tabSegment;

  AbsoluteTabBuilder(this._tabSegment);

  AbsoluteTabBuilder addNavigator(void Function(AbsoluteNavigatorBuilder) builder, {bool isBuild = true}) {

    final segment = NavigatorSegment(
      isAnimated: false, 
      isBuild: _tabSegment.isBuild && isBuild // 親のisBuildがfalseの場合は子のisBuildもfalseになる
      );
    final navigatorBuilder = AbsoluteNavigatorBuilder(segment);
    builder(navigatorBuilder);

    _tabSegment.children.add(navigatorBuilder.build());

    return this;
  }

  TabSegment build() {
    return _tabSegment;
  }
}