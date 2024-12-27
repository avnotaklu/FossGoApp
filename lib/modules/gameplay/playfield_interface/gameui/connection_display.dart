import 'package:flutter/material.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/services/signal_r_message.dart';

class ConnectionDisplay extends StatelessWidget {
  final Stream<ConnectionStrength> connectionStream;

  const ConnectionDisplay({required this.connectionStream, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStrength>(
      stream: connectionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final connectionStrength = snapshot.data!;
          return Icon(Icons.circle,
              size: 20,
              color: connectionStrength.isStrong ? Colors.green : Colors.red);
        } else {
          return Container();
        }
      },
    );
  }
}
