// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:barebones_timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/services/game_over_message.dart';
import 'package:provider/provider.dart';

import 'package:go/constants/constants.dart' as Constants;
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_timer.dart';


class PlayerDataUi extends StatefulWidget {
  final DisplayablePlayerData? playerInfo;
  final Game game;

  @override
  State<PlayerDataUi> createState() => _PlayerDataUiState();
  const PlayerDataUi(this.playerInfo, this.game, {super.key});
}

class _PlayerDataUiState extends State<PlayerDataUi> {
  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final player = widget.playerInfo;
    final ratings = widget.playerInfo?.rating;

    final size = MediaQuery.of(context).size;

    return Container(
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.09,
                        child: player == null
                            ? const Center(
                                child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator()),
                              )
                            : Container(
                                width: 15,
                                height: 15,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.lightGreenAccent,
                                ),
                              ),
                      ),
                      Text(
                        player?.displayName ?? "Unknown",
                        style: TextStyle(
                            color: Constants.defaultTheme.mainTextColor,
                            fontSize: 18),
                      ),
                      if (ratings != null)
                        if (player?.rating != null)
                          Text(
                            "(${player!.rating!.glicko.rating})",
                            style: TextStyle(
                                color: Constants.defaultTheme.mainTextColor,
                                fontSize: 14),
                          ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.09,
                      ),
                      if (player?.stoneType != null)
                        Text(
                          " + ${getPrisonersCount(game, player!.stoneType!)} Prisoners",
                          style: TextStyle(
                              color: Constants.defaultTheme.mainTextColor),
                        ),
                      if (player?.stoneType != null)
                        Text(
                          " + ${getKomi(game, player!.stoneType!)} Komi",
                          style: TextStyle(
                              color: Constants.defaultTheme.mainTextColor),
                        ),
                      // : const Spacer(
                      //     flex: 2,
                      //   ),
                      const Spacer(
                        flex: 3,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.09,
                      ),
                      if (player?.stoneType != null)
                        gameOverScore(game, player!.stoneType!)
                    ],
                  ),
                ],
              )),
          if (player?.stoneType != null)
            Expanded(
              flex: 2,
              child: Consumer<GameStateBloc>(
                builder: (context, bloc, child) {
                  return GameTimer(
                    controller: getTimerController(player!.stoneType!),
                    player: player.stoneType!,
                    isMyTurn: isPlayerTurn(player.stoneType!),
                    timeControl: game.timeControl,
                    playerTimeSnapshot:
                        getPlayerTimeSnapshot(game, player.stoneType!),
                  );
                },
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  int getPrisonersCount(Game game, StoneType stone) {
    return game.prisoners[stone.index];
  }

  double getKomi(Game game, StoneType stone) {
    if (stone == StoneType.white) {
      return game.komi;
    } else {
      return 0;
    }
  }

  Widget gameOverScore(Game game, StoneType stone) {
    return game.gameOverMethod == GameOverMethod.Score
        ? Text(
            " = ${game.finalTerritoryScores[stone.index] + game.prisoners[stone.index] + (stone.index * game.komi)}",
            style: TextStyle(color: Constants.defaultTheme.mainTextColor),
          )
        : const SizedBox.shrink();
  }

  TimerController getTimerController(StoneType player) {
    return context.read<GameStateBloc>().timerController[player.index];
  }

  bool isPlayerTurn(StoneType player) {
    return context.read<GameStateBloc>().playerTurn == player.index;
  }

  PlayerTimeSnapshot getPlayerTimeSnapshot(Game game, StoneType player) {
    return game.playerTimeSnapshots[player.index];
  }
}
