import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go/playfield/game.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/utils/player.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:flutter/services.dart';



class UiData extends InheritedWidget {
  static List<CountdownController> _controller = [
    CountdownController(autoStart: true),
    CountdownController(autoStart: false)
  ];

  UiData(var mChild) : super(child: mChild);

  // Inheritance Widget related functions
  @override
  bool updateShouldNotify(UiData oldWidget) {
    return true;
    // return oldWidget.playgroundMap == playgroundMap;
  }

  static UiData? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UiData>();

  static get timerController => _controller;
}

class GameUi extends StatefulWidget {
  @override
  State<GameUi> createState() => _GameUiState();
}

class _GameUiState extends State<GameUi> {
  Timer? _everySecond;
  String? _now;
  @override
  void initState() {
    super.initState();

    // sets first value
    _now = DateTime.now().second.toString();
    print("objecht");

    // defines a timer
    _everySecond = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        _now = DateTime.now().second.toString();
      });
    });
  }

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
    return StreamBuilder(
        stream: _bids,
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          return Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),

                      PlayerDataUi(pplayer: 0),

                      const SizedBox(
                        width: 20,
                      ),
                      PlayerDataUi(pplayer: 1),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(onPressed: () => Clipboard.setData(ClipboardData(text: GameData.of(context)?.match.id)), child: Text('copy game id'))
                      // SizedBox(width: constraints.maxWidth/3 - constraints.maxWidth/5,),
                    ],
                  ),
                ),
                Container(
                  height: 100,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () => GameData.of(context)?.toggleTurn(context,null),
                  child: Text("Pass"),
                ),
              ],
            ),
          );
        });
  }
}

class TimeWatch extends StatefulWidget {
  CountdownController mController;
  @override
  State<TimeWatch> createState() => _TimeWatchState();
  TimeWatch(controller, {required pplayer})
      : mController = controller,
        player = pplayer;
  int player;
}

class _TimeWatchState extends State<TimeWatch> {
  @override
  Widget build(BuildContext context) {
    return Countdown(
      controller: widget.mController,
      seconds: GameData.of(context)!.match.time as int, 
      build: (BuildContext context, double time) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            (time.toInt() ~/ 60).toString(),
            style: TextStyle(
                fontSize: 25,
                color: GameData.of(context)
                    ?.turnPlayerColor[widget.player == 0 ? 1 : 0]),
          ),
          Text(
            ':',
            style: TextStyle(
                fontSize: 25,
                color: GameData.of(context)
                    ?.turnPlayerColor[widget.player == 0 ? 1 : 0]),
          ),
          Text(
            (time.toInt() % 60).toString(),
            style: TextStyle(
                fontSize: 25,
                color: GameData.of(context)
                    ?.turnPlayerColor[widget.player == 0 ? 1 : 0]),
          ),
        ],
      ),
      interval: const Duration(milliseconds: 100),
      onFinished: () {
        print('Timer is done!');
      },
    );
  }
}

class PlayerDataUi extends StatefulWidget {
  int player;
  @override
  State<PlayerDataUi> createState() => _PlayerDataUiState();
  PlayerDataUi({required pplayer}) : player = pplayer;
}

class _PlayerDataUiState extends State<PlayerDataUi> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.5),
            color: GameData.of(context)?.turnPlayerColor[widget.player],
          ),
          child: Column(
            children: [
              TimeWatch(
                UiData._controller[widget.player],
                pplayer: widget.player,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
