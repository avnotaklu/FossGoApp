import 'package:flutter/material.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/widgets/primary_button.dart';

class LoaderBasicButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final String label;

  const LoaderBasicButton(
      {required this.onPressed, required this.label, super.key});

  @override
  State<LoaderBasicButton> createState() => _LoaderBasicButtonState();
}

class _LoaderBasicButtonState extends State<LoaderBasicButton> {
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
        : PrimaryButton(
            onPressed: widget.onPressed == null
                ? null
                : () async {
                    setState(() {
                      loading = true;
                    });
                    await widget.onPressed!();
                    setState(() {
                      loading = false;
                    });
                  },
            text: widget.label,
          );
  }
}

class LoaderCustomButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget Function(Future<void> Function()) buttonBuilder;

  const LoaderCustomButton(
      {required this.onPressed, required this.buttonBuilder, super.key});

  @override
  State<LoaderCustomButton> createState() => _LoaderCustomButtonState();
}

class _LoaderCustomButtonState extends State<LoaderCustomButton> {
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
        : widget.buttonBuilder(() async {
            setState(() {
              loading = true;
            });
            await widget.onPressed();
            setState(() {
              loading = false;
            });
          });
  }
}
