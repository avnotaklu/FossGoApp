import 'package:flutter/material.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';

class LoaderButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String label;

  const LoaderButton({required this.onPressed, required this.label, super.key});

  @override
  State<LoaderButton> createState() => _LoaderButtonState();
}

class _LoaderButtonState extends State<LoaderButton> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            padding: EdgeInsets.all(4),
            child: CircularProgressIndicator(
              color: context.theme.colorScheme.onSurface,
            ),
          )
        : FilledButton(
            onPressed: () async {
              setState(() {
                loading = true;
              });
              await widget.onPressed();
              setState(() {
                loading = false;
              });
            },
            child: Text(widget.label),
          );
  }
}
