import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/core_utils.dart';
import 'package:go/utils/database_strings.dart';
import 'package:go/utils/position.dart';
import 'dart:convert';

import 'package:go/utils/time_and_duration.dart';

class GameMatch {
  List<TimeAndDuration?> lastTimeAndDate = [];
  List<Duration?> playersTimeLeft = [];
  DateTime? startTime;
  bool runStatus = false;
  Map<int?, String?> uid = {};
  int rows;
  int cols;
  List<Position?> moves = [];
  Map<Position, Stone?> playgroundMap = {}; // int gives player id
  String id;
  int time;
  int _turn = 0;

  GameMatch({required this.rows, required this.cols, required this.time, required this.id, required this.uid});

  GameMatch.fromJson(Map<dynamic, dynamic> json)
      : //startTime = DateTime.parse(json['startTime']),
        rows = int.parse(json['rows']),
        cols = int.parse(json['cols']),
        time = int.parse(json['time']),
        id = json['id'],
        // uid = {0: json['uid'][0].toString(), 1: json['uid'][1].toString()},
//         uid = Map.fromIterable(json['uid'], key: (v) => v[0], value: (v) => v[1]);
        // uid = {json['uid'].keys : json['uid'].values},
        uid = uidFromJson(json['uid']),
        runStatus = json['runStatus'] == "true" ? true : false,
        _turn = int.parse(json['turn']) {
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
        'turn': _turn.toString(),
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

  get turn {
    return _turn;
  }

  set turn(dynamic val) {
    _turn = val;
  }

  bool isComplete() {
    return !toJson().values.contains(null);
  }

  get bothPlayers {
    return [uid[0], uid[1]];
  }

  static uidFromJson(List<Object?> uid) {
    var result = Map<int?, String?>.from(uid.asMap().map<int, String>((i, element) {
      return MapEntry(i, element.toString());
    })); // TODO make sure element works in this line changed from json['uid'][id]
    result.removeWhere((key, value) => value == "null");
    return result;
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
