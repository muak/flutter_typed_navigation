class NavigationSegment{
  bool isBuild;
  NavigationSegment({
    this.isBuild = true,
  });
}

class PageSegment extends NavigationSegment{
  final bool isAnimated;
  final bool isModal;  
  final bool isReplace;
  final String registrationKey;
  final dynamic param;  

  PageSegment({
    required this.registrationKey,
    this.isAnimated = true,
    this.isModal = false,
    this.isReplace = false,
    this.param,
    super.isBuild,
  });
}


class NavigatorSegment extends NavigationSegment{
  final List<PageSegment> children = [];
  final bool isAnimated;
  final bool isModal;  

  NavigatorSegment({
    this.isAnimated = true,
    this.isModal = false,
    super.isBuild,
  });
}

class TabSegment extends NavigationSegment{
  final List<NavigatorSegment> children = [];
  final int selectedIndex;
  final bool isAnimated;
  final bool isModal;  
  final String registrationKey;

  TabSegment({ 
    this.isAnimated = true,
    this.isModal = false,
    this.selectedIndex = 0,
    required this.registrationKey,
    super.isBuild,
  });
}

class ChangeTabSegment extends NavigationSegment{
  final int index;
  
  ChangeTabSegment({
    required this.index,
  });
}

class BackSegment extends NavigationSegment{
  final bool isModal;  
  final bool isRoot;

  BackSegment({
    this.isModal = false,
    this.isRoot = false,
  });
}

class DelaySegment extends NavigationSegment{
  final int milliSecondsDelay;

  DelaySegment({
    required this.milliSecondsDelay,
  });
}
