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
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 400);

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
    // SlideUp animation for modal appearance with enhanced smoothness
    const begin = Offset(0.0, 1.0); // Start from bottom
    const end = Offset.zero; // End at center

    // より滑らかなカーブを使用（Material Designのstandard curve）
    const curve = Curves.fastOutSlowIn;
    const fadeCurve = Curves.easeInOut;

    // スライドとフェードを組み合わせてより滑らかに
    final slideAnimation = animation.drive(
      Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
    );

    // フェードアニメーションを少し遅らせて開始することで、より自然な印象に
    final fadeAnimation = animation.drive(
      Tween(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: const Interval(0.0, 0.8, curve: fadeCurve)),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
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

class _SmartContentPageRoute<T> extends MaterialPageRoute<T> {
  _SmartContentPageRoute({
    required super.builder,
    required RouteSettings settings,
  }) : super(settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 親Navigatorが閉じられているかを判定
    // 親が閉じられている場合はsecondaryAnimationがforwardかcompletedになる
    final isParentClosing = secondaryAnimation.status == AnimationStatus.forward ||
                           secondaryAnimation.status == AnimationStatus.completed;
    
    if (isParentClosing) {
      // 親が閉じられている場合：アニメーション無効化
      // 無効化しないと親と子のアニメーションが同時に実行されてしまう
      return child;
    }
    
    // 通常の遷移：MaterialPageRouteのデフォルト動作
    return super.buildTransitions(context, animation, secondaryAnimation, child);
  }  
}

class ContentPage extends MaterialPage {
  const ContentPage({required super.child, super.key});

  @override
  Route createRoute(BuildContext context) {
    return _SmartContentPageRoute(
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
