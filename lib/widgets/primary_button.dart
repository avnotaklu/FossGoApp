
import 'package:flutter/material.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';

class PrimaryButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
        // elevation: WidgetStateProperty.all(100),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        ),
        textStyle: WidgetStateProperty.all(context.textTheme.bodyLarge),
        // side: WidgetStateProperty.all(
        //   BorderSide(
        //     // color: Colors.white,
        //     color: context.theme.shadowColor,
        //     width: 1,
        //   ),
        // ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}