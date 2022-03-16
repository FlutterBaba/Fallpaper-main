import 'package:flutter/material.dart';

class ColorRemover extends StatelessWidget {
  final Widget child;
  const ColorRemover({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();

        return true;
      },
      child: child,
    );
  }
}
