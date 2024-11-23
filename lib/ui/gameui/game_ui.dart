import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go/constants/constants.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/score_calculation_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/game_match.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/ui/gameui/player_card.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';

class GameUi extends StatefulWidget {
  bool blackTimerStarted = false;
  @override
  State<GameUi> createState() => _GameUiState();
}

class _GameUiState extends State<GameUi> {

  final Stream<String?> _bids = (() async* {
    await Future<void>.delayed(const Duration(seconds: 0));
    yield "hello";
    // yield "hello";
  })();

  @override
  Widget build(BuildContext context) {
    // return LayoutBuilder(
    // builder: (BuildContext context, BoxConstraints constraints){
    int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30;
    return Consumer<GameStateBloc>(
      builder: (context, value, child) {
        return Column(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Spacer(
                    flex: 4,
                  ),

                  // FIXME: hack to emulate getRemotePlayer which is not usable before game has started because it used id that is assigned after player joins and game starts
                  Expanded(
                      flex: 3,
                      child: PlayerDataUi(
                        DisplayablePlayerData(
                          email: context
                              .read<GameStateBloc>()
                              .otherPlayerUserInfo
                              ?.email,
                        ),
                        context.read<GameStateBloc>().getRemotePlayer(),
                        PlayerCardType.other,
                      )),
                ],
              ),
            ),
            Spacer(
              flex: 18,
            ),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                      flex: 3,
                      child: PlayerDataUi(
                        DisplayablePlayerData(
                          email: context
                              .read<GameStateBloc>()
                              .myPlayerUserInfo
                              .email,
                        ),
                        context.read<GameStateBloc>().getClientPlayer(),
                        PlayerCardType.my,
                      )),
                  context.read<Stage>() is GameEndStage &&
                          context.read<GameStateBloc>().game.winnerId != null
                      ? Text(
                          "${() {
                            return context
                                        .read<GameStateBloc>()
                                        .getWinnerStone!
                                        .index ==
                                    0
                                ? 'Black'
                                : 'White';
                          }.call()} won by ${getWinningMethod(context)}",
                          style: TextStyle(color: defaultTheme.mainTextColor),
                        )
                      : Spacer(
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
                            // context.read<GameStateBloc>().cur_stage.buttons()[0],
                            Expanded(
                              flex: 3,
                              child:
                                  context.read<Stage>() is ScoreCalculationStage
                                      ? Accept()
                                      : Pass(),
                            ),
                            VerticalDivider(
                              width: 2,
                            ),
                            Expanded(
                              flex: 3,
                              child:
                                  context.read<Stage>() is ScoreCalculationStage
                                      ? ContinueGame()
                                      : Resign(),
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
  const BottomButton(this.action, this.text, {this.isDisabled = false});
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
        child: Container(
          //height: double.infinity,
          // height: 100,
          width: 100,
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 14),
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
  const Pass({Key? key}) : super(key: key);

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
  const Accept({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    return BottomButton(
      () {
        gameStateBloc.acceptScores();
      },
      "Accept",
      isDisabled: gameStateBloc.iAccepted,
    );
  }
}

class ContinueGame extends StatelessWidget {
  const ContinueGame({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomButton(() async {
      // MultiplayerData.of(context)!
      //     .curGameReferences!
      //     .finalOurConfirmation(context)
      //     .set(false);
      // // GameData.of(context).acceptFinal();
      // MultiplayerData.of(context)!
      //     .curGameReferences!
      //     .finalRemovedClusters
      //     .remove();

      // NTP.now().then((value) {
      //   GameData.of(context)!.match.lastTimeAndDate[
      //           GameData.of(context)!.getPlayerWithoutTurn.turn] =
      //       TimeAndDuration(
      //           value,
      //           GameData.of(context)!
      //               .match
      //               .lastTimeAndDate[
      //                   GameData.of(context)!.getPlayerWithoutTurn.turn]!
      //               .duration);
      //   MultiplayerData.of(context)!
      //       .curGameReferences!
      //       .lastTimeAndDuration
      //       .child(GameData.of(context)!.getPlayerWithoutTurn.turn.toString())
      //       .set(GameData.of(context)!
      //           .match
      //           .lastTimeAndDate[
      //               GameData.of(context)!.getPlayerWithoutTurn.turn]
      //           .toString());

      //   GameData.of(context)!.match.lastTimeAndDate[
      //       GameData.of(context)!
      //           .getPlayerWithTurn
      //           .turn] = TimeAndDuration(
      //       value,
      //       GameData.of(context)!
      //           .match
      //           .lastTimeAndDate[GameData.of(context)!.getPlayerWithTurn.turn]!
      //           .duration);
      //   MultiplayerData.of(context)!
      //       .curGameReferences!
      //       .lastTimeAndDuration
      //       .child(GameData.of(context)!.getPlayerWithTurn.turn.toString())
      //       .set(GameData.of(context)!
      //           .match
      //           .lastTimeAndDate[GameData.of(context)!.getPlayerWithTurn.turn]
      //           .toString());

      final res = await context.read<GameStateBloc>()!.continueGame();
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
  const Resign({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomButton(() {
      context.read<GameStateBloc>().resignGame();
    }, "Resign");
  }
}
