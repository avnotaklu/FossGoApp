import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/core_utils.dart';
import 'package:go/utils/database_strings.dart';
import 'package:go/utils/position.dart';
import 'dart:convert';

import 'package:go/utils/time_and_duration.dart';

class GameMatch {
  /// time and date of last move played by players. In database it's stored as TimeAndDuration string
  List<TimeAndDuration?> lastTimeAndDate = [];

  DateTime? startTime;

  /// this is true when game is being played GameplayStage and ScoreCalculationStage both have runStatus of true. BeforeGameStart has runStatus of false.
  bool runStatus = true;

  Map<int?, String?> uid = {};
  int rows;
  int cols;

  /// moves is the list of moves played. In database position are stored in {x y} format and iff move is pass then it is stored as "null"
  List<Position?> moves = [];

  /// playground map stores the entire map of stones. In database this is stored in {player cluster freedoms} format to avoid rebuilding entire table of freedoms for each cluster on each load
  Map<Position, Stone?> playgroundMap = {}; // int gives player id
  String id;
  int time;
  ValueNotifier<int> _turn = ValueNotifier(0);
  Set<Position> finalRemovedCluster = {};

  GameMatch({required this.rows, required this.cols, required this.time, required this.id, required this.uid});

  GameMatch.fromJson(Map<dynamic, dynamic> json)
      : rows = int.parse(json['rows']),
        cols = int.parse(json['cols']),
        time = int.parse(json['time']),
        id = json['id'],
        uid = uidFromJson(json['uid']),
        runStatus = json['runStatus'] == "true" ? true : false {
    _turn.value = int.parse(json['turn']);

    json['gameEndData']?['finalRemovedClusters']?.forEach((v) {
      finalRemovedCluster.add(Position.fromString(v));
    });
    json['moves']?.forEach((v) {
      if (v != null) {
        if (v == "null") {
          moves.add(null);
        } else {
          moves.add(Position.fromString(v));
        }
      }
    });
    lastTimeAndDate.clear();
    json['lastTimeAndDuration']?.forEach((v) {
      lastTimeAndDate.add(TimeAndDuration.fromString(v));
    });

    playgroundMap.clear();
    Map<int?, Position?> clusterRefer = {};
    json['playgroundMap']?.forEach((k, v) {
      var currentClusterID = int.parse(v.split(' ')[1]);
      var previousClusterTrackingPosition = clusterRefer[currentClusterID];
      playgroundMap[previousClusterTrackingPosition]?.cluster.data.add(Position.fromString(k));

      clusterRefer[currentClusterID] = Position.fromString(k);

      playgroundMap[clusterRefer[currentClusterID] as Position] =
          Stone(int.parse(v.split(' ')[0]) == 0 ? Colors.black : Colors.white, clusterRefer[currentClusterID] as Position);
      playgroundMap[clusterRefer[currentClusterID] as Position]?.cluster =
          playgroundMap[previousClusterTrackingPosition]?.cluster ?? playgroundMap[clusterRefer[currentClusterID] as Position]?.cluster as Cluster;
      playgroundMap[clusterRefer[currentClusterID] as Position]?.cluster.freedoms = int.parse(v.split(' ')[2]);
    });
  }

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'rows': rows.toString(),
        'cols': cols.toString(),
        'time': time.toString(),
        'id': id,
        'uid': Map<String, String>.from(uid.map((key, value) => MapEntry(key.toString(), value.toString()))),
        'runStatus': runStatus.toString(),
        'moves': moves,
        'turn': turn.toString(),
        'playgroundMap': (playgroundMapToString(playgroundMap)),
        'startTime': startTime.toString(),
        'playersTimeLeft': (() {
          List<String> playersTimeLeftString = [];
          for (var element in playersTimeLeftString) {
            playersTimeLeftString.add(element.toString());
          }
          return playersTimeLeftString;
        }).call(),
        'lastTimeAndDuration': (() {
          List<String> lastTimeAndDateString = [];
          for (var element in lastTimeAndDate) {
            lastTimeAndDateString.add(element.toString());
          }
          return lastTimeAndDateString;
        }).call()
      };

  int get turn {
    return _turn.value;
  }

  ValueNotifier<int> get turnNotifier {
    return _turn;
  }

  set turn(int val) {
    _turn.value = val;
  }

  bool isComplete() {
    return !toJson().values.contains(null);
  }

  get bothPlayers {
    return [uid[0], uid[1]];
  }

  static Map<int?, String?> uidFromJson(List<Object?> uid) {
    var result = Map<int?, String?>.from(uid.asMap().map<int, String>((i, element) {
      return MapEntry(i, element.toString());
    })); // TODO make sure element works in this line changed from json['uid'][id]
    result.removeWhere((key, value) => value == "null");
    return result;
  }

  static List<String> removedClusterToJson(Set<Cluster> clusters) {
    List<String> result = [];
    clusters.forEach((element) {
      result.add(element.smallestPosition().toString());
    });
    return result;
  }

  Set<Cluster> removedClusterFromJson(clusters, context, [GameMatch? match]) {
    Set<Cluster> result = {};
    clusters?.forEach((i) {
      // TODO: inside gamematch accessing data that's in match with inherited widgets shouldn't be a thing access playgroundMap of this match directly
      var j;
      try {
        j = StoneLogic.of(context)!.playground_Map[Position.fromString(i)]!.value!.cluster;
      } catch (Exception) {
        j = match!.playgroundMap[i]!.cluster;
      }
      if (j != null) {
        result.add(j);
      }
    });

    return result;
  }

  static bool isRunning(runStatus) {
    if (runStatus == "true") return true;
    return false;
  }
}

class Move {
  final Position pos;
  Move(this.pos);
  Move.fromJson(Map<dynamic, dynamic> json) : pos = Position.fromString(json['pos']);
  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'pos': pos.toString(),
      };
}
