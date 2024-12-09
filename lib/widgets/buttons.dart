import 'package:flutter/material.dart';

class BadukButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Text child;

  const BadukButton({super.key, required this.onPressed, required this.child});
  @override
  Widget build(BuildContext context) {
    return FilledButton(
        onPressed: onPressed,
        child: Text(
          child.data!,
        ));
  }
}
