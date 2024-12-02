// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:barebones_timer/timer_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/user_rating.dart';
import 'package:provider/provider.dart';

import 'package:go/constants/constants.dart' as Constants;
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/ui/gameui/game_timer.dart';
import 'package:go/utils/core_utils.dart';
import 'package:go/utils/player.dart';

class DisplayablePlayerData {
  final String? displayName;
  final StoneType? stoneType;
  final UserRating? rating;

  DisplayablePlayerData({
    required this.displayName,
    required this.stoneType,
    required this.rating,
  });

  factory DisplayablePlayerData.from(
      PublicUserInfo? publicUserInfo, StoneType? stoneType) {
    return DisplayablePlayerData(
      displayName: publicUserInfo?.email,
      stoneType: stoneType,
      rating: publicUserInfo?.rating,
    );
  }
}

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
                      Container(
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
                        if (getGameRatingData(game, ratings) != null)
                          Text(
                            "(${getGameRatingData(game, ratings)!.glicko.rating})",
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

  PlayerRatingData? getGameRatingData(Game game, UserRating ratings) {
    return ratings.getRatingForGame(game);
  }
}
