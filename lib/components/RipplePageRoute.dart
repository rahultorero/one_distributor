import 'package:flutter/material.dart';

// Custom page route for ripple effect
class RipplePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Offset center;
  final double radius;
  final Duration duration;

  RipplePageRoute({
    required this.builder,
    required this.center,
    this.radius = 800.0,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Color get barrierColor => Colors.black.withOpacity(0.1);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => '';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return ClipPath(
      clipper: RippleClipper(center, radius * animation.value),
      child: child,
    );
  }

  @override
  bool get maintainState => true; // Return true to maintain the route state
}

// A custom clipper for the ripple effect
class RippleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  RippleClipper(this.center, this.radius);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(RippleClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
