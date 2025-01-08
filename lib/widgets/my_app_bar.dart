import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/games_history/games_history_page.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

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
      leading: widget.showBackButton && context.isMobile
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
        if (widget.trailing != null) widget.trailing!,
        StreamBuilder(
          stream: context.read<SignalRProvider>().reconnectionStream,
          builder: (context, AsyncSnapshot<bool> connectionSnap) {
            if (connectionSnap.hasData) {
              return FutureBuilder<void>(
                  future: Future.delayed(Duration(seconds: 2)),
                  builder: (context, delayedFutureSnap) {
                    if (delayedFutureSnap.connectionState ==
                            ConnectionState.waiting ||
                        !connectionSnap.data!) {
                      return Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 20,
                            color: connectionSnap.data!
                                ? Colors.green
                                : Colors.red,
                          ),
                          Text(
                              connectionSnap.data!
                                  ? "Reconnected"
                                  : "Reconnecting",
                              style: context.textTheme.labelSmall)
                        ],
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  });
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}
