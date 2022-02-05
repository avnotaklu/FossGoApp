
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/models/game_match.dart';
import 'package:go/ui/gameui/time_watch.dart';
import 'package:go/utils/player.dart';
import 'package:go/utils/position.dart';
import 'package:go/utils/time_and_duration.dart';
import 'package:ntp/ntp.dart';
import 'package:timer_count_down/timer_controller.dart';

class GameData extends InheritedWidget {
  // Call only once after the game has started which is checked by checkGameEnterable
  bool hasGameStarted = false;
  onGameStart(context) {
    if (!GameData.of(context)!.hasGameStarted) {
      hasGameStarted = true;
      StoneLogic.of(context)!.fetchNewStoneFromDB(context);
    }
  }

  final List<Player> _players;
  final Widget mChild;
  StreamController<List<TimeAndDuration>> updateController = StreamController<List<TimeAndDuration>>.broadcast();

  List<PlayerCountdownTimer?> timers = [null, null];
  final List<CountdownController>? _controller = [CountdownController(autoStart: false), CountdownController(autoStart: false)];
  GameData({
    required List<Player> pplayer,
    required this.mChild,
    required this.match,
  })  : _players = pplayer,
        super(child: mChild) {
    timers = [
      PlayerCountdownTimer(controller: _controller![0], time: Duration(seconds: match.time), player: 0),
      PlayerCountdownTimer(controller: _controller![1], time: Duration(seconds: match.time), player: 1)
    ];
  }

  final GameMatch match;

  correctRemoteUserTimeAndAddToUpdateController(context, lastMoveDateTime) {
    NTP.now().then((value) {
      //var updatedTime = calculateCorrectTime(lastMoveDateTime.data, widget.player, dateTimeNowsnapshot.data, context);
      // lastMoveDateTimeSnapshot.data[widget.player].difference(GameData.of(context)?.match.startTime)
      // (Duration(seconds: GameData.of(context)!.match.time) -
      //         (snapshot.data ?? DateTime.now()).difference(
      //             GameData.of(context)?.match.startTime ??
      //                 DateTime.now()))
      //     .inSeconds;
      print("player with turn" + GameData.of(context)!.getPlayerWithTurn.turn.toString());
      Duration durationAfterTimeElapsedCorrection =
          calculateCorrectTimeFromNow(lastMoveDateTime, GameData.of(context)?.getPlayerWithTurn.turn, value, context);

      lastMoveDateTime[GameData.of(context)?.getPlayerWithTurn.turn] =
          (TimeAndDuration(lastMoveDateTime[GameData.of(context)?.getPlayerWithTurn.turn]?.datetime, durationAfterTimeElapsedCorrection));

      GameData.of(context)!.updateController.add(List<TimeAndDuration>.from(lastMoveDateTime));
    });
  }

  bool movePlayed = false;
  newMovePlayed(BuildContext context, DateTime timeOfPlay, Position? playPosition) {
    assert(getPlayerWithTurn.turn == getclientPlayer(context)); // The rest of the function depends on it
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

    lastMoveDateTime[getclientPlayer(context)] = TimeAndDuration(timeOfPlay, lastMoveDateTime[getclientPlayer(context)]!.duration);
    Duration updatedTime = calculateCorrectTime(lastMoveDateTime, getclientPlayer(context), null, context);
    lastMoveDateTime[getclientPlayer(context)] = (TimeAndDuration(timeOfPlay, updatedTime));

    // updateTimeInDatabase(lastMoveDateTime, context, timeOfPlay, getclientPlayer(context));
    // updateDurationInDatabase(lastMoveDateTime, context, updatedTime, getclientPlayer(context));
    updateTimeAndDurationInDatabase(context, lastMoveDateTime[getclientPlayer(context)] as TimeAndDuration, getclientPlayer(context));
    updateMoveIntoDatabase(context, playPosition);

    lastMoveDateTime.forEach((element) {
      print(element.toString());
    });

    correctRemoteUserTimeAndAddToUpdateController(context, lastMoveDateTime);
    match.lastTimeAndDate = [...lastMoveDateTime];
    //}
    // });
  }

  updateMoveIntoDatabase(BuildContext context, Position? position) {
    var thisGame = MultiplayerData.of(context)?.database.child('game').child(match.id as String);
    thisGame?.child('moves').update({(match.turn).toString(): position.toString()});
    thisGame?.update({'turn': (turn + 1).toString()});
  }

  toggleTurn(BuildContext context) {
    GameData.of(context)?.timerController[turn % 2]?.pause();

    turn += 1;
    // turn = turn %2 == 0 ? 1 : 0;
    GameData.of(context)?.timerController[turn % 2]?.start();
  }

  DatabaseReference? getMatch(BuildContext context) {
    return MultiplayerData.of(context)?.database.child('game').child(match.id as String);
  }

  get turn => match.turn;
  set turn(dynamic val) => match.turn = val;

  get gametime => match.time;
  // get turnPlayerColor => [_players[0].mColor, _players[1].mColor];
  // Gives color of player with turn
  Player get getPlayerWithTurn => _players[turn % 2];
  Player get getPlayerWithoutTurn => _players[turn % 2 == 0 ? 1 : 0];
  get timerController => _controller;

  getRemotePlayer(BuildContext context) {
    //   match.uid.(MultiplayerData.of(context)?.curUser);
    // return (GameData.of(context)?.match.uid[GameData.of(context)?.turn % 2]) == MultiplayerData.of(context)?.curUser.uid;
    try {
      return match.uid.keys.firstWhere((k) => match.uid[k] != MultiplayerData.of(context)?.curUser.uid, orElse: () {
        throw TypeError;
      });
    } on TypeError {
      throw ("current client not found");
    }
  }

  getclientPlayer(BuildContext context) {
    //   match.uid.(MultiplayerData.of(context)?.curUser);
    // return (GameData.of(context)?.match.uid[GameData.of(context)?.turn % 2]) == MultiplayerData.of(context)?.curUser.uid;
    try {
      return match.uid.keys.firstWhere((k) => match.uid[k] == MultiplayerData.of(context)?.curUser.uid, orElse: () {
        throw TypeError;
      });
    } on TypeError {
      throw ("current client not found");
    }
  }

  @override
  bool updateShouldNotify(GameData oldWidget) {
    return oldWidget.turn != turn;
  }

  static GameData? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<GameData>();
}