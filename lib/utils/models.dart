import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/position.dart';
import 'dart:convert';

class GameMatch {
  bool runStatus = false;
  Map<int?, String?> uid = {};
  int? rows;
  int? cols;
  List<Position?>? moves = [];
  Map<Position, Stone?>? playgroundMap = {}; // int gives player id
  String id;
  int? time;
  int _turn = 0;

  GameMatch(this.rows, this.cols, this.time, this.id,
      [this.uid = const {null: null}]);
     
  GameMatch.empty(this.id);
  GameMatch.fromJson(Map<dynamic, dynamic> json)
      : rows = int.parse(json['rows']),
        cols = int.parse(json['cols']),
        time = int.parse(json['time']),
        id = json['id'],
        // uid = {0: json['uid'][0].toString(), 1: json['uid'][1].toString()},
//         uid = Map.fromIterable(json['uid'], key: (v) => v[0], value: (v) => v[1]);
        // uid = {json['uid'].keys : json['uid'].values},
        uid = Map<int?,String?>.from(json["uid"].asMap().map((i,element) => MapEntry(i as int,element.toString()))),// TODO make sure element works in this line changed from json['uid'][id]

        runStatus = json['runStatus'] == "true" ? true : false,
        _turn = int.parse(json['turn']) {
    json['moves']?.forEach((v) {
      if (v != null) {
        if (v == "null") {
          moves?.add(null);
        } else
          moves?.add(Position.fromString(v));
      }
    });

    Map<int?, Position?> clusterRefer = {};
    json['playgroundMap']?.forEach((k, v) {
      var currentClusterID = int.parse(v.split(' ')[1]);
      var previousClusterTrackingPosition = clusterRefer[currentClusterID];
      playgroundMap?[previousClusterTrackingPosition]
          ?.cluster
          .data
          .add(Position.fromString(k));

      clusterRefer[currentClusterID] = Position.fromString(k);

      playgroundMap?[clusterRefer[currentClusterID] as Position] = Stone(
          int.parse(v.split(' ')[0]) == 0 ? Colors.black : Colors.white,
          clusterRefer[currentClusterID] as Position);
      playgroundMap?[clusterRefer[currentClusterID] as Position]?.cluster =
          playgroundMap?[previousClusterTrackingPosition]?.cluster ??
              playgroundMap?[clusterRefer[currentClusterID] as Position]?.cluster
                  as Cluster;
      playgroundMap?[clusterRefer[currentClusterID] as Position]
          ?.cluster
          .freedoms = int.parse(v.split(' ')[2]);
    });
  }

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'rows': rows.toString(),
        'cols': cols.toString(),
        'time': time.toString(),
        'id': id,
        'uid': {
          0.toString(): uid[0]?.toString(),
          1.toString(): uid[1]?.toString()
        },
        'runStatus': runStatus.toString(),
        'moves': moves,
        'turn': _turn.toString(),
        'playgroundMap': json.decode(playgroundMap.toString()),
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

  get  bothPlayers {
    return [uid[0],uid[1]];
  }
}

class Move {
  final Position pos;
  Move(this.pos);
  Move.fromJson(Map<dynamic, dynamic> json)
      : pos = Position.fromString(json['pos']);
  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'pos': pos.toString(),
      };
}
