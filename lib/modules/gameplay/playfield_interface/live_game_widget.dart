import 'package:flutter/material.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/gameplay/game_state/game_entrance_data.dart';
import 'package:go/modules/gameplay/game_state/oracle/live_game_oracle.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game_and_opponent.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:provider/provider.dart';

class LiveGameWidget extends StatelessWidget {
  final Game game;
  final GameEntranceData? joinMessage;
  final IStatsRepository statsRepo;

  const LiveGameWidget(this.game, this.joinMessage, this.statsRepo,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
        value: statsRepo,
        builder: (context, child) {
          return FutureBuilder(
              future: statsRepo.getStats(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return GameWidget(
                      game: game,
                      gameOracle: LiveGameOracle(
                        api: Api(),
                        systemUtilities: const SystemUtilities(),
                        authBloc: context.read<AuthProvider>(),
                        signalRbloc: context.read<SignalRProvider>(),
                        ratings: snapshot.data?.fold((l) => null, (r) => r.$2),
                        joiningData: joinMessage,
                      ));
                } else {
                  return Scaffold(
                    body: Center(
                      child: Container(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
              });
        });
  }
}
