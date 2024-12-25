// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:barebones_timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/models/minimal_rating.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/services/player_rating.dart';
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge,
                      ),
                      if (widget.playerInfo?.rating != null)
                        ratingText(widget.playerInfo!.rating!),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.09,
                      ),

                      if (player?.stoneType != null)
                        if (getFinalScore(game, player!.stoneType!) != null)
                          Text(
                            " + ${getFinalScore(game, player!.stoneType!)} Points",
                            style: context.textTheme.labelLarge,
                          ),

                      if (player?.stoneType != null)
                        Text(
                          " + ${getPrisonersCount(game, player!.stoneType!)} Prisoners",
                          style: context.textTheme.labelLarge,
                        ),
                      if (player?.stoneType != null &&
                          player?.stoneType == StoneType.white)
                        Text(
                          " + ${getKomi(game, player!.stoneType!)} Komi",
                          style: context.textTheme.labelLarge,
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

  Widget ratingText(MinimalRating rating) {
    return RichText(
      text: TextSpan(
          text: " ( ${rating.stringify()}",
          style: context.textTheme.labelLarge,
          children: [
            if (widget.playerInfo != null)
              ...ratingDiffText(widget.playerInfo!),
            const TextSpan(
              text: " )",
            ),
          ]),
      textAlign: TextAlign.center,
    );
  }

  List<TextSpan> ratingDiffText(DisplayablePlayerData player) {
    final diff = player.ratingDiffOnEnd;
    if (diff != null) {
      final sign = diff > 0 ? "+" : "-";
      return [
        TextSpan(
          text: " $sign${diff.abs()}",
          style: TextStyle(
            color: diff < 0 ? otherColors.loss : otherColors.win,
            fontSize: 12,
          ),
        )
      ];
    }
    return [];
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

  int? getFinalScore(Game game, StoneType stone) {
    if (game.gameOverMethod == GameOverMethod.Score) {
      return game.finalTerritoryScores[stone.index] +
          game.prisoners[stone.index];
    }
    return null;
  }

  Widget gameOverScore(Game game, StoneType stone) {
    return game.gameOverMethod == GameOverMethod.Score
        ? Text(
            " = ${game.finalTerritoryScores[stone.index] + game.prisoners[stone.index] + (stone.index * game.komi)}",
            style: context.textTheme.labelLarge,
          )
        : const SizedBox.shrink();
  }

  TimerController getTimerController(StoneType player) {
    return context.read<GameStateBloc>().timerController[player.index];
  }

  bool isPlayerTurn(StoneType player) {
    return context.read<GameStateBloc>().playerTurn == player.index;
  }

  PlayerTimeSnapshot? getPlayerTimeSnapshot(Game game, StoneType player) {
    if (game.playerTimeSnapshots.length <= player.index) return null;
    return game.playerTimeSnapshots[player.index];
  }

  int? getRatingDiff(Game game, StoneType stone) {
    if (game.playersRatingsDiff.isNotEmpty) {
      return game.playersRatingsDiff[stone.index];
    }
    return null;
  }
}
