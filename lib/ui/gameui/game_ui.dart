import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/score_calculation_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/game.dart';
import 'package:go/ui/gameui/player_card.dart';
import 'package:go/ui/gameui/time_watch.dart';
import 'package:go/models/game_match.dart';
import 'package:go/utils/player.dart';
import 'package:go/utils/position.dart';
import 'package:ntp/ntp.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:flutter/services.dart';

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
          flex: 9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Spacer(),
              Expanded(flex: 5, child: PlayerDataUi(pplayer: 0)),
              Spacer(),
              Expanded(flex: 5, child: PlayerDataUi(pplayer: 1)),
              Spacer(),
            ],
          ),
        ),
        Spacer(),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Spacer(),
              // GameData.of(context)!.cur_stage.buttons()[0],
              GameData.of(context)!.cur_stage.stage is ScoreCalculationStage ? const Accept() : const Pass(),
              Spacer(),
              GameData.of(context)!.cur_stage.stage is ScoreCalculationStage ? const ContinueGame() : const CopyId(),
              // GameData.of(context)!.cur_stage.buttons()[1],
              Spacer(),
            ],
          ),
        ),
        Spacer(),
      ],
    );
  }
}

class OnlineCountdownTimer extends StatefulWidget {
  @override
  State<OnlineCountdownTimer> createState() => _OnlineCountdownTimerState();
  Duration duration;
  Duration? time;
  OnlineCountdownTimer({required this.duration}) {
    time = duration;
  }
}

class _OnlineCountdownTimerState extends State<OnlineCountdownTimer> {
  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      NTP.now().asStream().asBroadcastStream().listen((value) {
        widget.time = Duration(seconds: GameData.of(context)!.match.time) - (value).difference(GameData.of(context)?.match.startTime ?? value);
        setState(() {});
      });
    });
    return Column(
      children: [
        Text((widget.time.toString())),
      ],
    );
  }
}

class Pass extends StatelessWidget {
  const Pass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ElevatedButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: () => {
          NTP.now().then((value) {
            GameData.of(context)!.cur_stage.onClickCell(null, context);
            // GameData.of(context)?.newMovePlayed(context, value, null);
            // GameData.of(context)?.toggleTurn(context);
          })
        },
        child: const Text("Pass"),
      ),
    );
  }
}

class Accept extends StatelessWidget {
  const Accept({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      onPressed: () {
        MultiplayerData.of(context)!.curGameReferences!.finalOurConfirmation(context).set(true);
        // GameData.of(context).acceptFinal();
        MultiplayerData.of(context)!
            .curGameReferences!
            .finalRemovedClusters
            .set(GameMatch.removedClusterToJson(ScoreCalculation.of(context)!.virtualRemovedCluster));

        ScoreCalculation.of(context)!.stoneRemovalAccepted.add(GameData.of(context)!.getClientPlayer(context) as int);
        ScoreCalculation.of(context)!.onGameEnd(context, ScoreCalculation.of(context)!.virtualRemovedCluster);
      },
      child: const Text("Accept"),
    );
  }
}

class ContinueGame extends StatelessWidget {
  const ContinueGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      onPressed: () {
        MultiplayerData.of(context)!.curGameReferences!.finalOurConfirmation(context).set(false);
        // GameData.of(context).acceptFinal();
        MultiplayerData.of(context)!.curGameReferences!.finalRemovedClusters.remove();
        GameData.of(context)!.cur_stage = GameplayStage(context);
      },
      child: const Text("Continue Game"),
    );
  }
}

class CopyId extends StatelessWidget {
  const CopyId({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ElevatedButton(onPressed: () => Clipboard.setData(ClipboardData(text: GameData.of(context)?.match.id)), child: const Text("game id")),
    );
  }
}
