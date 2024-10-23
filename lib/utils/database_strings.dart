import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/models/position.dart';

// playgroundMapToString(Map<Position?,StoneWidget?> playgroundMap) {
//   Map<int, Position?> tmpClusterRefer = {};
//   int clusterTopTracker = 0;
//   return Map<String,Object?>.from(
//     playgroundMap.map(
//       (a, b) => MapEntry(
//           a.toString(),
//           () {
//             return playgroundMap[a]?.color == null
//                 ? null
//                 : () {
//                     int currentClusterTracker = 0;
//                     int currentClusterFreedoms = 0;
//                     for (var i in tmpClusterRefer.keys) {
//                       if (!(playgroundMap[tmpClusterRefer[i]]?.cluster.data.contains(a) ?? false)) {
//                         clusterTopTracker++;
//                         currentClusterTracker = clusterTopTracker;
//                       } else {
//                         currentClusterTracker = i;
//                         break;
//                       }
//                     }
//                     clusterTopTracker = 0;
//                     tmpClusterRefer[currentClusterTracker] = a;
//                     return (( playgroundMap[a]?.color == Colors.black ? 0 : 1).toString() +
//                         " $currentClusterTracker ${playgroundMap[a]?.cluster.freedoms}");
//                   }.call();
//           }.call()),
//     ),
//   );
// }
