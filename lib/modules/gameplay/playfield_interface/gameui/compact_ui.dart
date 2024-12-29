import 'package:barebones_timer/timer_controller.dart';
import 'package:barebones_timer/timer_display.dart';
import 'package:flutter/material.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_timer.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/move_tree.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/ui_actions.dart';
import 'package:go/modules/gameplay/stages/analysis_stage.dart';
import 'package:go/modules/gameplay/stages/game_end_stage.dart';
import 'package:go/modules/gameplay/stages/score_calculation_stage.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:provider/provider.dart';

class CompactGameUi extends StatelessWidget {
  final Widget boardWidget;

  const CompactGameUi({required this.boardWidget, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateBloc>(builder: (context, gameStateBloc, child) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            SizedBox(
              height: context.height * 0.02,
            ),
            Container(
              height: context.height * 0.08,
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Expanded(
                    child: CompactPlayerCard(
                      playerData: gameStateBloc.topPlayerUserInfo,
                      game: gameStateBloc.game,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: CompactPlayerCard(
                      playerData: gameStateBloc.bottomPlayerUserInfo,
                      game: gameStateBloc.game,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: boardWidget,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              height: context.height * 0.25,
              child: MoveTree(
                root: context.read<AnalysisBloc>().start,
                direction: TreeDirection.horizontal,
              ),
            ),
            Spacer(),
            if (context.read<Stage>() is! GameEndStage)
              context.read<Stage>() is ScoreCalculationStage
                  ? const ScoreActions()
                  : context.read<Stage>() is AnalysisStage
                      ? AnalsisModeActions(
                          openTree: () {},
                          // openTree: () => openBottomSheet(
                          //   context.read<AnalysisBloc>(),
                          // ),
                        )
                      : const PlayingGameActions()
            else
              const PlayingEndedActions(),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      );
    });
  }
}

class CompactPlayerCard extends StatelessWidget {
  final DisplayablePlayerData? playerData;
  final Game game;
  const CompactPlayerCard(
      {required this.game, required this.playerData, super.key});

  StoneType get player => playerData!.stoneType!;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Constants.playerColors[playerData!.stoneType!.index]
            .withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade700.withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Theme(
          data: context.theme.copyWith(
              textTheme: Constants.buildTextTheme(
                  Constants.playerColors[playerData!.stoneType!.other.index])),
          child: Builder(builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: playerData == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Waiting ...",
                          style: context.theme.textTheme.titleLarge,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      ],
                    )
                  : Row(
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    playerData!.displayName,
                                    style: context.theme.textTheme.titleLarge,
                                  ),
                                  if (playerData?.stoneType != null)
                                    Container(
                                      height: 28,
                                      width: 60,
                                      child: GameTimer(
                                          customStyle: (context) =>
                                              context.textTheme.bodySmall!,
                                          controller: getTimerController(
                                              context, player),
                                          player: player,
                                          isMyTurn:
                                              isPlayerTurn(context, player),
                                          timeControl: game.timeControl,
                                          playerTimeSnapshot:
                                              getPlayerTimeSnapshot(
                                                  game, player)),
                                    )
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              if (game.bothPlayersIn() &&
                                  game.gameState == GameState.waitingForStart &&
                                  player == StoneType.black)
                                Row(
                                  children: [
                                    Container(
                                      width: context.width * 0.09,
                                    ),
                                    TimerDisplay(
                                      builder: (p0) {
                                        return Text(
                                          "Time for first move: ${p0.duration.smallRepr()}",
                                          style: context.textTheme.labelLarge,
                                        );
                                      },
                                      controller: context
                                          .read<GameStateBloc>()
                                          .headsUpTimeController,
                                    )
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    if (playerData!.komi != null)
                                      Text(
                                        "Komi: ${playerData!.komi} | ",
                                        style:
                                            context.theme.textTheme.labelSmall,
                                      ),
                                  ],
                                )
                              // Text(
                              //   playerData!.score.toString(),
                              //   style: context.theme.textTheme.headline6,
                              // ),
                            ]),
                      ],
                    ),
            );
          })),
    );
  }

  PlayerTimeSnapshot? getPlayerTimeSnapshot(Game game, StoneType player) {
    if (game.playerTimeSnapshots.length <= player.index) return null;
    return game.playerTimeSnapshots[player.index];
  }

  bool isPlayerTurn(BuildContext context, StoneType player) {
    return context.read<GameStateBloc>().playerTurn == player.index;
  }

  TimerController getTimerController(BuildContext context, StoneType player) {
    return context.read<GameStateBloc>().timerController[player.index];
  }
}
