import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go/constants/constants.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/score_calculation_stage.dart';
import 'package:go/models/game_match.dart';
import 'package:go/ui/gameui/player_card.dart';
import 'package:go/utils/time_and_duration.dart';
import 'package:ntp/ntp.dart';

class GameUi extends StatefulWidget {
  bool blackTimerStarted = false;
  @override
  State<GameUi> createState() => _GameUiState();
}

class _GameUiState extends State<GameUi> {
  // Timer? _everySecond;
  // String? _now;
  // @override
  // void initState() {
  //   super.initState();

  //   // sets first value
  //   _now = DateTime.now().second.toString();
  //   print("objecht");

  //   // defines a timer
  //   _everySecond = Timer.periodic(Duration(seconds: 1), (Timer t) {
  //     setState(() {
  //       _now = DateTime.now().second.toString();
  //     });
  //   });
  // }

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
              Expanded(flex: 3, child: PlayerDataUi(pplayer: GameData.of(context)!.getClientPlayer(context) == 0 ? 1 : 0)),
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
              Expanded(flex: 3, child: PlayerDataUi(pplayer: GameData.of(context)!.getClientPlayer(context))),
              GameData.of(context)!.cur_stage.stage is GameEndStage
                  ? Text(
                      "${() {
                        return ScoreCalculation.of(context)!.getWinner(context).mColor == Colors.black ? 'Black' : 'White';
                      }.call()} won by ${(GameData.of(context)!.getPlayerWithTurn.score - GameData.of(context)!.getPlayerWithoutTurn.score).abs()}",
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
                        // GameData.of(context)!.cur_stage.buttons()[0],
                        Expanded(
                          flex: 3,
                          child: GameData.of(context)!.cur_stage.stage is ScoreCalculationStage ? Accept() : Pass(),
                        ),
                        VerticalDivider(
                          width: 2,
                        ),
                        Expanded(
                          flex: 3,
                          child: GameData.of(context)!.cur_stage.stage is ScoreCalculationStage ? ContinueGame() : Resign(),
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
  }
}

class BottomButton extends StatelessWidget {
  BottomButton(this.action, this.text);
  VoidCallback action;
  String text;

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
        onTap: action,
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
      print("pass");
      NTP.now().then((value) {
        GameData.of(context)!.cur_stage.onClickCell(null, context);
        // GameData.of(context)?.newMovePlayed(context, value, null);
        // GameData.of(context)?.toggleTurn(context);
      });
    }, "Pass");
  }
}

class Accept extends StatelessWidget {
  const Accept({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomButton(() {
      MultiplayerData.of(context)!.curGameReferences!.finalOurConfirmation(context).set(true);
      // GameData.of(context).acceptFinal();
      MultiplayerData.of(context)!
          .curGameReferences!
          .finalRemovedClusters
          .set(GameMatch.removedClusterToJson(ScoreCalculation.of(context)!.virtualRemovedCluster));

      ScoreCalculation.of(context)!.stoneRemovalAccepted.add(GameData.of(context)!.getClientPlayer(context) as int);
      ScoreCalculation.of(context)!.onGameEnd(context, ScoreCalculation.of(context)!.virtualRemovedCluster);
    }, "Accept");
  }
}

class ContinueGame extends StatelessWidget {
  const ContinueGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomButton(() {
      MultiplayerData.of(context)!.curGameReferences!.finalOurConfirmation(context).set(false);
      // GameData.of(context).acceptFinal();
      MultiplayerData.of(context)!.curGameReferences!.finalRemovedClusters.remove();

      NTP.now().then((value) {
        GameData.of(context)!.match.lastTimeAndDate[GameData.of(context)!.getPlayerWithoutTurn.turn] =
            TimeAndDuration(value, GameData.of(context)!.match.lastTimeAndDate[GameData.of(context)!.getPlayerWithoutTurn.turn]!.duration);
        MultiplayerData.of(context)!
            .curGameReferences!
            .lastTimeAndDuration
            .child(GameData.of(context)!.getPlayerWithoutTurn.turn.toString())
            .set(GameData.of(context)!.match.lastTimeAndDate[GameData.of(context)!.getPlayerWithoutTurn.turn].toString());

        GameData.of(context)!.match.lastTimeAndDate[GameData.of(context)!.getPlayerWithTurn.turn] =
            TimeAndDuration(value, GameData.of(context)!.match.lastTimeAndDate[GameData.of(context)!.getPlayerWithTurn.turn]!.duration);
        MultiplayerData.of(context)!
            .curGameReferences!
            .lastTimeAndDuration
            .child(GameData.of(context)!.getPlayerWithTurn.turn.toString())
            .set(GameData.of(context)!.match.lastTimeAndDate[GameData.of(context)!.getPlayerWithTurn.turn].toString());

        GameData.of(context)!.cur_stage = GameplayStage(context);
      });
    }, "Continue");
  }
}

class Resign extends StatelessWidget {
  const Resign({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomButton(() {
      print("resign");
      Clipboard.setData(ClipboardData(text: GameData.of(context)!.match.id));
    }, "Resign");
  }
}
