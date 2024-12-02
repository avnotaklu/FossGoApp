import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart' as Constants;

class BadukButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Text child;

  const BadukButton({required this.onPressed, required this.child});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Text(
          child.data!,
        )
        );
  }
}
