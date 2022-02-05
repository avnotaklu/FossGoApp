import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/position.dart';

playgroundMapToString(Map<Position?, Stone?> playground_Map) {
  Map<int, Position?> tmpClusterRefer = {};
  int clusterTopTracker = 0;
  return Map<String, Object?>.from(
    playground_Map.map(
      (a, b) => MapEntry(
          a.toString(),
          () {
            return playground_Map[a]?.color == null
                ? null
                : () {
                    int currentClusterTracker = 0;
                    int currentClusterFreedoms = 0;
                    for (var i in tmpClusterRefer.keys) {
                      if (!(playground_Map[tmpClusterRefer[i]]?.cluster.data.contains(a) ?? false)) {
                        clusterTopTracker++;
                        currentClusterTracker = clusterTopTracker;
                      } else {
                        currentClusterTracker = i;
                        break;
                      }
                    }
                    clusterTopTracker = 0;
                    tmpClusterRefer[currentClusterTracker] = a;
                    return ((playground_Map[a]?.color == Colors.black ? 0 : 1).toString() +
                        " $currentClusterTracker ${playground_Map[a]?.cluster.freedoms}");
                  }.call();
          }.call()),
    ),
  );
}
