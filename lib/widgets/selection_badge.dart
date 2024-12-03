import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';

class SelectionBadge extends StatelessWidget {
  final bool selected;
  final Widget? child;
  const SelectionBadge({super.key, required this.selected, this.child});

  @override
  Widget build(BuildContext context) {
    return Badge(
      backgroundColor:
          selected ? defaultTheme.enabledColor : defaultTheme.disabledColor,
      label: selected ? const Icon(Icons.check_rounded, size: 20, color: Colors.white,) : null,
      largeSize: 3,
      smallSize: 0,
      child: child,
    );
  }
}
