import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/models/stone.dart';
import 'package:go/playfield/board_utilities.dart';

class GameBoardBloc extends ChangeNotifier {
  final Map<Position, Stone> _stones = {};
  Map<Position, Stone> get stonesCopy => Map.fromEntries(_stones.entries);

  final Game game;

  final Position? koDelete;

  int get rows => game.rows;
  int get cols => game.columns;

  Stone? stoneAt(Position? pos) {
    if (pos == null) {
      return null;
    }

    return _stones[pos];
  }

  void setStoneAt(Position pos, Stone stone) {
    _stones[pos] = stone;
    notifyListeners();
  }

  void removeStoneAt(Position pos) {
    _stones.remove(pos);
    notifyListeners();
  }

  bool checkIfInsideBounds(Position pos) {
    return pos.x > -1 && pos.x < rows && pos.y < cols && pos.y > -1;
  }

  // final Map<int, Cluster> clusters = {};
  GameBoardBloc(this.game) : koDelete = game.koPositionInLastMove {
    // for (var stone_rep_map_entry in game.playgroundMap.entries) {
    //   var currentClusterID = stone_rep_map_entry.value.clusterId;
    //   if (clusters[currentClusterID] == null) {
    //     clusters[currentClusterID] = Cluster(
    //       {stone_rep_map_entry.key},
    //       stone_rep_map_entry.value.clusterFreedoms,
    //       stone_rep_map_entry.value.player,
    //     );
    //   } else {
    //     clusters[currentClusterID]!.data.add(stone_rep_map_entry.key);
    //   }
    // }

    // for (var cluster in clusters.values) {
    //   stones.addEntries(cluster.data.map((position) => MapEntry(
    //       position,
    //       Stone(
    //         position: position,
    //         cluster: cluster,
    //         player: cluster.player,
    //       ))));
    // }

    var board =
        BoardStateUtilities(game.rows, game.columns).BoardStateFromGame(game);
    _stones.addAll(board.playgroundMap);
  }
}
