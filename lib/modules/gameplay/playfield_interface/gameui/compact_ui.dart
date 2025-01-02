import 'package:barebones_timer/timer_controller.dart';
import 'package:barebones_timer/timer_display.dart';
import 'package:flutter/material.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';
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
import 'package:go/widgets/stateful_card.dart';
import 'package:google_fonts/google_fonts.dart';
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
              height: context.height * 0.1,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    playerData!.displayName,
                                    style: context.theme.textTheme.titleLarge,
                                  ),
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
                                          "Start: ${p0.duration.smallRepr()}",
                                          style: context.textTheme.bodyLarge,
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
                                            context.theme.textTheme.labelLarge,
                                      ),
                                  ],
                                )
                              // Text(
                              //   playerData!.score.toString(),
                              //   style: context.theme.textTheme.headline6,
                              // ),
                            ]),
                        Spacer(),
                        if (playerData?.stoneType != null)
                          SizedBox(
                            height: 90,
                            width: 90,
                            child: CompactGameTimer(
                              controller: getTimerController(context, player),
                              player: player,
                              isMyTurn: isPlayerTurn(context, player),
                              timeControl: game.timeControl,
                              playerTimeSnapshot:
                                  getPlayerTimeSnapshot(game, player),
                            ),
                          )
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

class CompactGameTimer extends StatefulWidget {
  const CompactGameTimer({
    super.key,
    required this.controller,
    required this.player,
    required this.isMyTurn,
    required this.timeControl,
    required this.playerTimeSnapshot,
    this.customStyle,
  });

  final StoneType player;
  final TextStyle Function(BuildContext context)? customStyle;
  final TimeControl timeControl;
  final PlayerTimeSnapshot? playerTimeSnapshot;
  final TimerController controller;
  final bool isMyTurn;

  @override
  State<CompactGameTimer> createState() => _CompactGameTimerState();
}

class _CompactGameTimerState extends State<CompactGameTimer> {
  @override
  Widget build(BuildContext context) {
    return StatefulCard(
      state: widget.isMyTurn
          ? StatefulCardState.enabled
          : StatefulCardState.disabled,
      builder: (c) => Align(
        alignment: Alignment.centerRight,
        child: CompactMyTimeDisplay(
          customStyle: widget.customStyle,
          controller: widget.controller,
          timeControl: widget.timeControl,
          playerTimeSnapshot: widget.playerTimeSnapshot,
        ),
      ),
    );
  }
}

class CompactMyTimeDisplay extends StatelessWidget {
  final TimeControl timeControl;
  final PlayerTimeSnapshot? playerTimeSnapshot;
  final TimerController controller;
  final TextStyle Function(BuildContext context)? customStyle;

  const CompactMyTimeDisplay({
    required this.controller,
    required this.timeControl,
    required this.playerTimeSnapshot,
    this.customStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: TimerDisplay(
        controller: controller,
        builder: (controller) {
          var parts = controller.duration.getDurationReprParts();

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.ideographic,
                  children: [
                    if (parts.h > 0) ...[
                      largeTimeStepText(context, parts.h.timeStepPadded()),
                      largeTimeStepText(context, ":")
                    ],
                    largeTimeStepText(context, parts.m.timeStepPadded()),
                    if (parts.h == 0) ...[
                      largeTimeStepText(context, ":"),
                      largeTimeStepText(context, parts.s.timeStepPadded()),
                    ],
                    SizedBox(
                      width: 4,
                    ),
                    if (parts.h > 0)
                      smallTimeStepText(context, parts.s.timeStepPadded()),
                    if (parts.h == 0 && parts.m == 0 && parts.s < 10)
                      smallTimeStepText(context, parts.d.timeStepPadded()),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (timeControl.byoYomiTime != null) ...[
                      extraText(context, " +"),
                      extraText(
                        context,
                        playerTimeSnapshot != null
                            ? (playerTimeSnapshot!.byoYomisLeft ?? "")
                                .toString()
                            : (timeControl.byoYomiTime?.byoYomis ?? "")
                                .toString(),
                      ),
                      extraText(
                        context,
                        " x ${(Duration(seconds: timeControl.byoYomiTime!.byoYomiSeconds)).smallRepr()}",
                      ),
                    ]
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Text largeTimeStepText(BuildContext context, String text) {
    return Text(
      text,
      style: (context.textTheme.bodyLarge)?.copyWith(
        fontFamily: GoogleFonts.spaceMono().fontFamily,
      ),
    );
  }

  Text smallTimeStepText(BuildContext context, String text) {
    return Text(
      text,
      style: (context.textTheme.bodySmall)?.copyWith(
        fontFamily: GoogleFonts.spaceMono().fontFamily,
      ),
    );
  }

  Text extraText(BuildContext context, String text) {
    return Text(
      text,
      style: (context.textTheme.bodySmall)?.copyWith(
          // fontFamily: GoogleFonts.spaceMono().fontFamily,
          ),
    );
  }
}
