import 'dart:io' show Platform;
import 'package:flutter/material.dart';

class _ModalPageRoute<T> extends PageRoute<T> {
  _ModalPageRoute({
    required this.builder,
    required RouteSettings settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // SlideUp animation for modal appearance
    const begin = Offset(0.0, 1.0); // Start from bottom
    const end = Offset.zero; // End at center
    
    // Use platform-specific curves for more natural animation
    final curve = Platform.isIOS ? Curves.easeOut : Curves.easeInOut;
    final reverseCurve = Platform.isIOS ? Curves.easeIn : Curves.easeInOut;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: animation.status == AnimationStatus.reverse ? reverseCurve : curve),
    );

    final offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}

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
    return _ModalPageRoute(
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
    return _ModalPageRoute(
      settings: this,
      builder: (context) => child,
    );
  }
}
