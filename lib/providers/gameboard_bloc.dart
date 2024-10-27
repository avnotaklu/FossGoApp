import 'package:flutter/material.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/models/stone.dart';
import 'package:go/playfield/board_utilities.dart';

class GameboardBloc extends ChangeNotifier {
  final Map<Position, Stone> stones = {};
  // final Map<int, Cluster> clusters = {};
  GameboardBloc(Game game) {
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
    stones.addAll(board.playgroundMap);
  }
}
