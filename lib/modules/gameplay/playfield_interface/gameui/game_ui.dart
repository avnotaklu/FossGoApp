import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/modules/gameplay/stages/game_end_stage.dart';
import 'package:go/modules/gameplay/stages/score_calculation_stage.dart';
import 'package:go/modules/gameplay/stages/stage.dart';

import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/player_card.dart';
import 'package:provider/provider.dart';

class GameUi extends StatefulWidget {
  final bool blackTimerStarted = false;
  final Widget boardWidget;

  const GameUi({super.key, required this.boardWidget});
  @override
  State<GameUi> createState() => _GameUiState();
}

class _GameUiState extends State<GameUi> {
  // final Stream<String?> _bids = (() async* {
  //   await Future<void>.delayed(const Duration(seconds: 0));
  //   yield "hello";
  //   // yield "hello";
  // })();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateBloc>(
      builder: (context, gameStateBloc, child) {
        return Column(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  const Spacer(
                    flex: 4,
                  ),

                  // FIXME: hack to emulate getRemotePlayer which is not usable before game has started because it used id that is assigned after player joins and game starts
                  Expanded(
                    flex: 3,
                    child: PlayerDataUi(
                      gameStateBloc.topPlayerUserInfo,
                      gameStateBloc.game,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 18,
              child: widget.boardWidget,
            ),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: PlayerDataUi(
                      gameStateBloc.bottomPlayerUserInfo,
                      gameStateBloc.game,
                    ),
                  ),
                  context.read<Stage>() is GameEndStage &&
                          gameStateBloc.game.result != null
                      ? Text(
                          "${() {
                            return gameStateBloc.getWinnerStone!.index == 0
                                ? 'Black'
                                : 'White';
                          }.call()} won by ${getWinningMethod(context)}",
                          style: TextStyle(color: defaultTheme.mainTextColor),
                        )
                      : const Spacer(
                          flex: 2,
                        ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.blue,
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // gameStateBloc.cur_stage.buttons()[0],
                            Expanded(
                              flex: 3,
                              child:
                                  context.read<Stage>() is ScoreCalculationStage
                                      ? const Accept()
                                      : const Pass(),
                            ),
                            const VerticalDivider(
                              width: 2,
                            ),
                            Expanded(
                              flex: 3,
                              child:
                                  context.read<Stage>() is ScoreCalculationStage
                                      ? const ContinueGame()
                                      : const Resign(),
                            )
                            // GameData.of(context)!.cur_stage.buttons()[1],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Spacer(),
            // Expanded(flex: 3, child: PlayerDataUi(pplayer: 1)),
          ],
        );
      },
    );
  }

  String getWinningMethod(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    if (gameStateBloc.game.gameOverMethod == GameOverMethod.Score) {
      return "${(gameStateBloc.getSummedPlayerScores[0] - gameStateBloc.getSummedPlayerScores[1]).abs()} Point(s)";
    }
    return gameStateBloc.game.gameOverMethod!.actualName;
  }
}

class BottomButton extends StatelessWidget {
  const BottomButton(this.action, this.text, {super.key, this.isDisabled = false});
  final bool isDisabled;
  final VoidCallback action;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.blue.shade700,

        // Colors.transparent,
        //splashColor: Colors.blue,
        onTap: isDisabled ? null : action,
        child: SizedBox(
          //height: double.infinity,
          // height: 100,
          width: 100,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
    // return InkWell(
    //   onTap: action,
    //   child: Container(
    //     color: Colors.blue.shade700,
    //     child: Expanded(
    //       child: Text(
    //         text,
    //         style: TextStyle(color: Colors.white),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class Pass extends StatelessWidget {
  const Pass({super.key});

  @override
  Widget build(BuildContext context) {
    // return ElevatedButton(
    //   style: ButtonStyle(
    //     foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    //   ),
    return BottomButton(() {
      context.read<Stage>().onClickCell(null, context);
    }, "Pass");
  }
}

class Accept extends StatelessWidget {
  const Accept({super.key});

  @override
  Widget build(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    return BottomButton(
      () {
        gameStateBloc.acceptScores();
      },
      "Accept",
      // isDisabled: gameStateBloc.iAccepted,
    );
  }
}

class ContinueGame extends StatelessWidget {
  const ContinueGame({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomButton(() async {
      final res = await context.read<GameStateBloc>().continueGame();
      res.fold((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
      }, (v) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully continued game"),
          ),
        );
      });
      // });
    }, "Continue");
  }
}

class Resign extends StatelessWidget {
  const Resign({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomButton(() {
      context.read<GameStateBloc>().resignGame();
    }, "Resign");
  }
}
