import 'internal_navigation_service.dart';
import 'navigation_segment.dart';

class RelativeNavigationBuilder {
  final InternalNavigationService _navigationService;
  final List<NavigationSegment> _segments = [];

  RelativeNavigationBuilder(this._navigationService);

  RelativeNavigationBuilder addPage<TViewModel>(
      {dynamic param, bool isAnimated = true}) {
    final pageSegment = PageSegment(
        isAnimated: isAnimated,
        param: param,
        registrationKey: TViewModel.toString(),
        isBuild: true // 相対ビルダーは常にビルド対象
        );

    _segments.add(pageSegment);

    return this;
  }

  RelativeNavigationBuilder addNavigator(void Function(RelativeNavigatorBuilder) builder) {
    final navigatorSegment = NavigatorSegment(isAnimated: false);

    final navigatorBuilder = RelativeNavigatorBuilder(navigatorSegment);
    builder(navigatorBuilder);
    
    _segments.add(navigatorBuilder.build());

    return this;
  }  

  RelativeNavigationBuilder addTabPage<TViewModel>(void Function(RelativeTabBuilder) builder, {int selectedIndex = 0}) {
    final tabSegment = TabSegment(registrationKey: TViewModel.toString(), isAnimated: false, selectedIndex: selectedIndex);
    final tabBuilder = RelativeTabBuilder(tabSegment);
    builder(tabBuilder);

    _segments.add(tabBuilder.build());

    return this;
  }

  RelativeNavigationBuilder addBack() {
    final backSegment = BackSegment();
    _segments.add(backSegment);

    return this;
  }

  RelativeNavigationBuilder addBackToRoot() {
    final backToRootSegment = BackSegment(isRoot: true);
    _segments.add(backToRootSegment);

    return this;
  }

  RelativeNavigationBuilder addModalClose() {
    final modalCloseSegment = BackSegment(isModal: true);
    _segments.add(modalCloseSegment);

    return this;
  }

  RelativeNavigationBuilder addChangeTab(int index) {
    final changeTabSegment = ChangeTabSegment(index: index);
    _segments.add(changeTabSegment);

    return this;
  }

  RelativeNavigationBuilder addDelay(int milliSeconds) {
    final delaySegment = DelaySegment(milliSecondsDelay: milliSeconds);
    _segments.add(delaySegment);

    return this;
  }

  Future<void> navigate() {
    return _navigationService.navigateInternal(_segments);
  }

  Future<TResult?> navigateResult<TResult>() {
    // 結果を返す場合は1つのセグメントしか許可しない
    if (_segments.length != 1) {
      throw Exception('navigateResult must be 1 segment');
    }
    final segment = _segments.first;

    // 結果を返す場合はPageSegment / NavigatorSegment / TabSegment のみ許可する
    switch (segment) {
      case PageSegment():
      case NavigatorSegment():
      case TabSegment():
        break;
      default:
        throw Exception('navigateResult must be PageSegment: ${segment.runtimeType}');
    }    

    return _navigationService.navigateResultInternal<TResult>(segment);
  }
}

class RelativeNavigatorBuilder{
  final NavigatorSegment _navigatorSegment;

  RelativeNavigatorBuilder(this._navigatorSegment);

  RelativeNavigatorBuilder addPage<TViewModel>({dynamic param, bool isBuild = true}) {
    
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

class RelativeTabBuilder{
  final TabSegment _tabSegment;

  RelativeTabBuilder(this._tabSegment);

  RelativeTabBuilder addNavigator(void Function(RelativeNavigatorBuilder) builder, {bool isBuild = true}) {

    final segment = NavigatorSegment(
      isAnimated: false, 
      isBuild: _tabSegment.isBuild && isBuild // 親のisBuildがfalseの場合は子のisBuildもfalseになる
      );
    final navigatorBuilder = RelativeNavigatorBuilder(segment);
    builder(navigatorBuilder);

    _tabSegment.children.add(navigatorBuilder.build());

    return this;
  }

  TabSegment build() {
    return _tabSegment;
  }
}