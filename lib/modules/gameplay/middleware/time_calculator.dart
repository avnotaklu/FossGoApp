import 'dart:math';

import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';

class TimeCalculator {
  @override
  List<PlayerTimeSnapshot> recalculateTurnPlayerTimeSnapshots(
      StoneType curTurnPlayer,
      List<PlayerTimeSnapshot> playerTimes,
      TimeControl timeControl,
      DateTime curTime) {
    int curTurn = curTurnPlayer.index;

    // Copy the playerTimes list
    List<PlayerTimeSnapshot> newTimes = List.from(playerTimes);

    PlayerTimeSnapshot turnPlayerSnap() => newTimes[curTurn];
    PlayerTimeSnapshot nonTurnPlayerSnap() => newTimes[1 - curTurn];

    int? byoYomiMS = timeControl.byoYomiTime?.byoYomiSeconds != null
        ? timeControl.byoYomiTime!.byoYomiSeconds * 1000
        : null;

    int activePlayerIdx = newTimes.indexWhere((snap) => snap.timeActive);
    var activePlayerSnap = newTimes[activePlayerIdx];

    int activePlayerTimeLeft = activePlayerSnap.mainTimeMilliseconds -
        (curTime.difference(activePlayerSnap.snapshotTimestamp).inMilliseconds);

    int newByoYomi = (activePlayerSnap.byoYomisLeft ?? 0) -
        ((activePlayerSnap.byoYomiActive && activePlayerTimeLeft <= 0) ? 1 : 0);

    int applicableByoYomiTime = (newByoYomi > 0) ? (byoYomiMS ?? 0) : 0;

    int applicableIncrement = activePlayerIdx != curTurn
        ? (timeControl.incrementSeconds ?? 0) * 1000
        : 0;

    newTimes[activePlayerIdx] = PlayerTimeSnapshot(
      snapshotTimestamp: curTime,
      mainTimeMilliseconds: activePlayerTimeLeft > 0
          ? activePlayerTimeLeft + applicableIncrement
          : applicableByoYomiTime,
      byoYomisLeft: max(newByoYomi, 0),
      byoYomiActive: activePlayerTimeLeft <= 0,
      timeActive: newTimes[activePlayerIdx].timeActive,
    );

    newTimes[curTurn] = PlayerTimeSnapshot(
      snapshotTimestamp: curTime,
      mainTimeMilliseconds: turnPlayerSnap().mainTimeMilliseconds,
      byoYomisLeft: turnPlayerSnap().byoYomisLeft,
      byoYomiActive: turnPlayerSnap().byoYomiActive,
      timeActive: true,
    );

    newTimes[1 - curTurn] = PlayerTimeSnapshot(
      snapshotTimestamp: curTime,
      mainTimeMilliseconds: nonTurnPlayerSnap().mainTimeMilliseconds,
      byoYomisLeft: nonTurnPlayerSnap().byoYomisLeft,
      byoYomiActive: false,
      timeActive: false,
    );

    return newTimes;
  }
}
