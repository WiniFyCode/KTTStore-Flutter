import 'package:flutter/material.dart';

class AnimatedSwitcherWrapper extends StatelessWidget {
  final Widget child;

  const AnimatedSwitcherWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: child,
    );
  }
}
