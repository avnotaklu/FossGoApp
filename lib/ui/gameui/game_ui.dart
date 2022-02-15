import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';
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
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () => {
                    NTP.now().then((value) {
                      GameData.of(context)?.newMovePlayed(context, value, null);
                      GameData.of(context)?.toggleTurn(context);
                    })
                  },
                  child: const Text("Pass"),
                ),
              ),
              Spacer(),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                    onPressed: () => Clipboard.setData(ClipboardData(text: GameData.of(context)?.match.id)), child: const Text('game id')),
              ),
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
