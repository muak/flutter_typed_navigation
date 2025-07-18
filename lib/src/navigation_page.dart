import 'package:flutter/material.dart';

class _ModalPageRoute<T> extends PageRoute<T> {
  _ModalPageRoute({
    required this.builder,
    required RouteSettings settings,
    this.disableStartAnimation = false,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final bool disableStartAnimation;

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
    const curve = Curves.easeInOut;

    // 開始アニメーションが無効化されている場合
    if (disableStartAnimation) {
      // 開始時は即座に完成状態、終了時は通常のアニメーション
      final effectiveAnimation = animation.status == AnimationStatus.reverse 
          ? animation  // 終了アニメーション時は通常のアニメーションを使用
          : const AlwaysStoppedAnimation(1.0);  // 開始時は完了状態で固定

      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      final offsetAnimation = effectiveAnimation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    }

    // 通常のアニメーション
    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
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
  final bool disableStartAnimation;
  
  const NavigatorPage({required super.child, super.key, this.disableStartAnimation = false});

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
      disableStartAnimation: disableStartAnimation,
    );
  }
}

class TabPage extends MaterialPage {
  final bool disableStartAnimation;
  
  const TabPage({required super.child, super.key, this.disableStartAnimation = false});

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
      disableStartAnimation: disableStartAnimation,
    );
  }
}
