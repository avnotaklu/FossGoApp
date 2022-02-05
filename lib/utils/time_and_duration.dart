import 'package:flutter/material.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/utils/core_utils.dart';

import 'package:firebase_database/firebase_database.dart';

class TimeAndDuration {
  final DateTime _time;
  final Duration _duration;
  TimeAndDuration(this._time, this._duration);
  TimeAndDuration.fromString(String str)
      : _time = DateTime.parse(str.split("|")[0]),
        _duration = parseDurationFromString(str.split("|")[1]);
  @override
  String toString() {
    return _time.toString() + "|" + _duration.toString();
  }

  get datetime => _time;
  get duration => _duration;
}

updateTimeInDatabase(List<TimeAndDuration?> lastMoveDateTime, BuildContext context, DateTime time, int player) {
  print("putting" + time.toString());
  DatabaseReference ref = MultiplayerData.of(context)!.database.child('game').child(GameData.of(context)?.match.id as String);
  ref.child('lastTimeAndDuration').child((player).toString()).orderByKey().get().then((value) {
    print(value);
    ref.child('lastTimeAndDuration').update({(player).toString(): TimeAndDuration(time, lastMoveDateTime[player]!.duration).toString()});
  });
}

updateTimeAndDurationInDatabase(BuildContext context, TimeAndDuration timeAndDuration, int player) {
  DatabaseReference ref = MultiplayerData.of(context)!.database.child('game').child(GameData.of(context)?.match.id as String);
// ref.child('lastTimeAndDuration').child((player).toString()).orderByKey().get().then((value) {
//     print(value);
//     print("putting" + TimeAndDuration.fromString(value.value as String)._time.toString());
  ref.child('lastTimeAndDuration').update({(player).toString(): timeAndDuration.toString()});
  //});
}

updateDurationInDatabase(List<TimeAndDuration?> lastMoveDateTime, BuildContext context, Duration dur, int player) {
  DatabaseReference ref = MultiplayerData.of(context)!.database.child('game').child(GameData.of(context)?.match.id as String);
  ref.child('lastTimeAndDuration').child((player).toString()).orderByKey().get().then((value) {
    print(value);
    print("putting" + TimeAndDuration.fromString(value.value as String)._time.toString());
    ref.child('lastTimeAndDuration').update({(player).toString(): TimeAndDuration(lastMoveDateTime[player]!._time, dur).toString()});
  });
}

calculateCorrectTime(lastMoveDateTime, player, dateTimeNowsnapshot, context) {
  Duration updatedTimeBeforeNewMoveForBothPlayers = Duration(seconds: 0);
  try {
    updatedTimeBeforeNewMoveForBothPlayers = lastMoveDateTime[player].datetime.difference(
          lastMoveDateTime[player == 0 ? 1 : 0].datetime,
        );
  } catch (err) {}

  Duration updatedTime = (lastMoveDateTime[player].duration);
  try {
    updatedTime = /*((GameData.of(context)?.turn % 2) == 0 ? 1 : 0)*/
        // player // FIXME This is async so turn can probably change in different order which will cause issues
        (lastMoveDateTime[player].duration) - updatedTimeBeforeNewMoveForBothPlayers.abs();
    //: (lastMoveDateTime[player].duration) - ((lastMoveDateTime[player == 0 ? 1 : 0].datetime.difference(dateTimeNowsnapshot)).abs() ?? Duration(seconds: 0));
  } catch (err) {}
  return updatedTime.abs();
}

calculateCorrectTimeFromNow(lastMoveDateTime, player, dateTimeNowsnapshot, context) {
  var updatedTime;
  try {
    updatedTime = (lastMoveDateTime[player].duration) -
        ((lastMoveDateTime[player == 0 ? 1 : 0].datetime.difference(dateTimeNowsnapshot)).abs() ?? Duration(seconds: 0));
  } catch (err) {}
  return updatedTime.abs();
}
