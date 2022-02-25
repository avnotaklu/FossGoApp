import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/game_match.dart';
import 'package:go/ui/gameui/time_watch.dart';
import 'package:go/utils/player.dart';
import 'package:go/utils/position.dart';
import 'package:go/utils/time_and_duration.dart';
import 'package:ntp/ntp.dart';
import 'package:timer_count_down/timer_controller.dart';

class GameData extends InheritedWidget {
  ValueNotifier<Stage> curStageNotifier;

  // Call only once after the game has started which is checked by checkGameEnterable
  bool hasGameStarted = false;
  onGameStart(context) {
    assert(match != null);
    GameData.of(context)!.timerController[GameData.of(context)!.getPlayerWithTurn.turn].start();
    GameData.of(context)!.curStageNotifier.value = GameplayStage();
    if (!GameData.of(context)!.hasGameStarted) {
      hasGameStarted = true;
      StoneLogic.of(context)?.fetchNewStoneFromDB(context);
    }
  }

  final List<Player> _players;
  final Widget mChild;
  StreamController<List<TimeAndDuration>> updateController = StreamController<List<TimeAndDuration>>.broadcast();

  List<PlayerCountdownTimer?> timers = [null, null];
  final List<CountdownController> _controller = [CountdownController(autoStart: false), CountdownController(autoStart: false)];
  GameData({
    required List<Player> pplayer,
    required this.mChild,
    required this.match,
    required Stage curStage,
  })  : _players = pplayer,
        curStageNotifier = ValueNotifier(curStage),
        super(child: mChild) {
    timers = [
      PlayerCountdownTimer(controller: _controller[0], time: Duration(seconds: match.time), player: 0),
      PlayerCountdownTimer(controller: _controller[1], time: Duration(seconds: match.time), player: 1)
    ];
  }

  final GameMatch match;
  bool listenNewMove = false;

  // GETTERS
  int get turn => match.turn;
  set turn(dynamic val) => match.turn = val;
  Stage get cur_stage => curStageNotifier.value;
  set cur_stage(Stage stage) {
    cur_stage.disposeStage();

    curStageNotifier.value = stage;
  }

  int get gametime => match.time;
  Player get getPlayerWithTurn => _players[turn % 2];
  Player get getPlayerWithoutTurn => _players[turn % 2 == 0 ? 1 : 0];
  List<CountdownController> get timerController => _controller;

  // Turn player timer needs to be corrected because the player with last turn has sent correct time
  // from database but current player has some lag that needs to be corrected
  correctTurnPlayerTimeAndAddToUpdateController(int turn, context, lastMoveDateTime) {
    NTP.now().then((value) {
      //var updatedTime = calculateCorrectTime(lastMoveDateTime.data, widget.player, dateTimeNowsnapshot.data, context);
      // lastMoveDateTimeSnapshot.data[widget.player].difference(GameData.of(context)?.match.startTime)
      // (Duration(seconds: GameData.of(context)!.match.time) -
      //         (snapshot.data ?? DateTime.now()).difference(
      //             GameData.of(context)?.match.startTime ??
      //                 DateTime.now()))
      //     .inSeconds;

      print("player with turn" + turn.toString());
      Duration durationAfterTimeElapsedCorrection = calculateCorrectTimeFromNow(lastMoveDateTime, turn, value, context);

      lastMoveDateTime[turn] = (TimeAndDuration(lastMoveDateTime[turn]?.datetime, durationAfterTimeElapsedCorrection));

      GameData.of(context)!.updateController.add(List<TimeAndDuration>.from(lastMoveDateTime));
    });
  }

  bool movePlayed = false;
  newMovePlayed(BuildContext context, DateTime timeOfPlay, Position? playPosition) {
    // Check if newMovePlayed ends game
    // this happens when there are two consecutive passes

    // assert(getPlayerWithTurn.turn == getclientPlayer(context)); // The rest of the function depends on it
    movePlayed = true;
    // MultiplayerData.of(context)
    //     ?.database
    //     .child('game')
    //     .child(match.id as String)
    //     .child('lastTimeAndDuration')
    //     //.child(getPlayerWithoutTurn.toString())
    //     .orderByKey()
    //     .get()
    //     .then((dataEvent) {

    // if (dataEvent.value != null) {
    // List<TimeAndDuration?> lastMoveDateTime = [null, null];
    List<TimeAndDuration?> lastMoveDateTime = [...match.lastTimeAndDate];
    // lastMoveDateTime[0] = TimeAndDuration.fromString((dataEvent.value as List)[0]);
    // lastMoveDateTime[1] = TimeAndDuration.fromString((dataEvent.value as List)[1]);

    lastMoveDateTime[getClientPlayer(context)!] = TimeAndDuration(timeOfPlay, lastMoveDateTime[getClientPlayer(context)!]!.duration);
    Duration updatedTime = calculateCorrectTime(lastMoveDateTime, getClientPlayer(context), null, context);
    lastMoveDateTime[getClientPlayer(context)!] = (TimeAndDuration(timeOfPlay, updatedTime));

    // updateTimeInDatabase(lastMoveDateTime, context, timeOfPlay, getclientPlayer(context));
    // updateDurationInDatabase(lastMoveDateTime, context, updatedTime, getclientPlayer(context));
    updateTimeAndDurationInDatabase(context, lastMoveDateTime[getClientPlayer(context)!] as TimeAndDuration, getClientPlayer(context)!);
    updateMoveIntoDatabase(context, playPosition);

    for (var element in lastMoveDateTime) {
      print(element.toString());
    }

    // turn hasn't been updated here so without turn is actually the player with turn
    correctTurnPlayerTimeAndAddToUpdateController(GameData.of(context)!.getPlayerWithoutTurn.turn, context, lastMoveDateTime);
    match.lastTimeAndDate = [...lastMoveDateTime];
    match.moves.add(playPosition);
    //}
    // });
  }

  updateMoveIntoDatabase(BuildContext context, Position? position) {
    var thisGame = MultiplayerData.of(context)?.database.child('game').child(match.id);
    thisGame?.child('moves').update({(match.turn).toString(): position.toString()});
    thisGame?.update({'turn': (turn + 1).toString()});
  }

  toggleTurn(BuildContext context) {
    GameData.of(context)?.timerController[turn % 2].pause();

    turn += 1;
    // turn = turn %2 == 0 ? 1 : 0;
    GameData.of(context)?.timerController[turn % 2].start();
    listenNewMove = true;
  }

  DatabaseReference? getMatch(BuildContext context) {
    return MultiplayerData.of(context)?.database.child('game').child(match.id);
  }

  int? getRemotePlayer(BuildContext context) {
    //   match.uid.(MultiplayerData.of(context)?.curUser);
    // return (GameData.of(context)?.match.uid[GameData.of(context)?.turn % 2]) == MultiplayerData.of(context)?.curUser.uid;
    try {
      return match.uid.keys.firstWhere((k) => match.uid[k] != MultiplayerData.of(context)?.curUser!.uid, orElse: () {
        throw TypeError;
      });
    } on TypeError {
      throw ("current client not found");
    }
  }

  int? getClientPlayer(BuildContext context) {
    //   match.uid.(MultiplayerData.of(context)?.curUser);
    // return (GameData.of(context)?.match.uid[GameData.of(context)?.turn % 2]) == MultiplayerData.of(context)?.curUser.uid;
    try {
      return match.uid.keys.firstWhere((k) => match.uid[k] == MultiplayerData.of(context)?.curUser!.uid, orElse: () {
        throw TypeError;
      });
    } on TypeError {
      throw ("current client not found");
    }
  }

  @override
  bool updateShouldNotify(GameData oldWidget) {
    return oldWidget.turn != turn || oldWidget.curStageNotifier != curStageNotifier;
  }

  static GameData? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<GameData>();
}
