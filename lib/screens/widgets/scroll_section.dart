import 'package:flutter/material.dart';

class ScrollSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ScrollSection({super.key, required this.child,this.padding = const EdgeInsets.all(12.0)});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
