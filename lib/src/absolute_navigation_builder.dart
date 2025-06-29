import 'package:flutter/widgets.dart';
import 'internal_navigation_service.dart';

import 'navigation_entry.dart';
import 'navigation_segment.dart';

class AbsoluteNavigationBuilder{
  final InternalNavigationService _navigationService;
  final List<NavigationSegment> _segments = [];

  AbsoluteNavigationBuilder(this._navigationService);

  void setCurrentPageLazyFlag() {
    final lastSegment = _segments.last;
    switch (lastSegment) {
      case PageSegment pageSegment:
        pageSegment.isLazy = false;
        break;
      case NavigatorSegment navigatorSegment:
        navigatorSegment.isLazy = false;      
        final lastChild = navigatorSegment.children.last;
        lastChild.isLazy = false;        
        break;
      case TabSegment tabSegment:
        tabSegment.isLazy = false;
        final selectedNavigator = tabSegment.children[tabSegment.selectedIndex];
        selectedNavigator.isLazy = false;
        final lastChild = selectedNavigator.children.last;
        lastChild.isLazy = false;
        break;
    }
  }

  AbsoluteNavigationBuilder addNavigator(
      void Function(AbsoluteNavigatorBuilder) builder,
      {bool isLazy = false}) {
    final navigatorSegment =
        NavigatorSegment(isAnimated: false, isLazy: isLazy);

    final navigatorBuilder = AbsoluteNavigatorBuilder(navigatorSegment);
    builder(navigatorBuilder);
    
    _segments.add(navigatorBuilder.build());

    return this;
  }  

  AbsoluteNavigationBuilder addTabPage<TViewModel>(
      void Function(AbsoluteTabBuilder) builder,
      {int selectedIndex = 0,
      bool isLazy = false}) {
    final tabSegment = TabSegment(
        registrationKey: TViewModel.toString(),
        isAnimated: false,
        selectedIndex: selectedIndex,
        isLazy: isLazy);
    final tabBuilder = AbsoluteTabBuilder(tabSegment);
    builder(tabBuilder);

    _segments.add(tabBuilder.build());

    return this;
  }

  void setRoutes(){
    _navigationService.setRoutes(build());
  }

  List<NavigationEntry> build() {
    // カレントページのisLazyフラグをfalseに設定（即座にビルド）
    setCurrentPageLazyFlag();

    final entries = _segments.map((segment) {
      return switch (segment) {
        NavigatorSegment() => NavigatorEntry(
          children: segment.children.map((pageSegment) => PageEntry(
            registrationKey: pageSegment.registrationKey,
            param: pageSegment.param,
                      isLazy: pageSegment.isLazy,
          )).toList(),
            isLazy: segment.isLazy,
          navigatorKey: GlobalKey<NavigatorState>(),
        ),
        TabSegment() => TabEntry(
          registrationKey: segment.registrationKey,
          selectedIndex: segment.selectedIndex,
            isLazy: segment.isLazy,
          children: segment.children.map((navigatorSegment) => NavigatorEntry(
            children: navigatorSegment.children.map((pageSegment) => PageEntry(
              registrationKey: pageSegment.registrationKey,
              param: pageSegment.param,
                                isLazy: pageSegment.isLazy,
            )).toList(),
                      isLazy: navigatorSegment.isLazy,
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

  AbsoluteNavigatorBuilder addPage<TViewModel>(
      {dynamic param, bool isLazy = false}) {
    
    final pageSegment = PageSegment(
      param: param, 
      registrationKey: TViewModel.toString(), 
        isLazy: _navigatorSegment.isLazy ||
            isLazy); // 親がisLazy=trueの場合は子もisLazy=trueになる
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

  AbsoluteTabBuilder addNavigator(
      void Function(AbsoluteNavigatorBuilder) builder,
      {bool isLazy = false}) {

    final segment = NavigatorSegment(
      isAnimated: false, 
        isLazy:
            _tabSegment.isLazy || isLazy // 親がisLazy=trueの場合は子もisLazy=trueになる
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