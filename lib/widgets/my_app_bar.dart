import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar(
    this.title, {
    this.showBackButton = false,
    this.trailing,
    this.leading,
    super.key,
  })  : preferredSize = const Size.fromHeight(kToolbarHeight),
        assert(
          showBackButton == false || leading == null,
        );

  @override
  final Size preferredSize; // default is 56.0

  final String title; // default is 56.0
  final bool showBackButton;
  final Widget? trailing;
  final Widget? leading;

  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : widget.leading ?? const SizedBox.shrink(),
      centerTitle: true,
      title: Text(widget.title),
      actions: [
        if (widget.trailing != null) ...[widget.trailing!]
      ],
    );
  }
}
