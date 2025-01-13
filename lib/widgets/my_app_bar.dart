import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/games_history/games_history_page.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';

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
    final signalR = context.read<SignalRProvider>();
    final connStream = signalR.connectionStream;
    return AppBar(
      leading: widget.showBackButton && Navigator.of(context).canPop()
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
          stream: connStream,
          builder:
              (context, AsyncSnapshot<SignalRConnectionState> connectionSnap) {
            if (connectionSnap.hasData) {
              return FutureBuilder<void>(
                  future: Future.delayed(Duration(seconds: 2)),
                  builder: (context, delayedFutureSnap) {
                    final fW = delayedFutureSnap.connectionState ==
                        ConnectionState.waiting;
                    if (connectionSnap.data!.isReconnecting) {
                      return Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 20,
                            color: Colors.red,
                          ),
                          Text("Reconnecting",
                              style: context.textTheme.labelSmall)
                        ],
                      );
                    }
                    if (connectionSnap.data!.isWeak) {
                      return Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 20,
                            color: Colors.amber,
                          ),
                          Text("Weak Signal",
                              style: context.textTheme.labelSmall)
                        ],
                      );
                    }

                    if ((connectionSnap.data!.isConnected && !fW)) {
                      return Row(
                        children: [
                          Icon(Icons.circle, size: 20, color: Colors.green),
                          Text("Connected",
                              style: context.textTheme.labelSmall)
                        ],
                      );
                    } else if (connectionSnap.data!.isDisconnected) {
                      return Row(
                        children: [
                          Text("Connect", style: context.textTheme.labelSmall),
                          IconButton(
                            onPressed: () async {
                              context.read<AuthProvider>().connectUser();
                            },
                            icon: const Icon(Icons.refresh),
                          )
                        ],
                      );
                    }

                    return SizedBox.shrink();
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
