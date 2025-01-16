import 'package:flutter/material.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';

class SecondaryButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;

  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  static const Color color = Color(0xfff47174);

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(color),
        textStyle: WidgetStateProperty.all(context.textTheme.bodyLarge),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
