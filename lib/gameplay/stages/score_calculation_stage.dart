import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/position.dart';

class ScoreCalculationStage extends Stage {
  int blackScore = 0;
  int whiteScore = 0;
  BuildContext? _context;
  var removedClusterSubscription;
  get context => _context;

  ScoreCalculationStage(context) {
    _context = context;
    GameData.of(context)?.timerController[0].pause();
    GameData.of(context)?.timerController[1].pause();
    ScoreCalculation.of(context)!.calculateScore(context);

    removedClusterSubscription = removedClusterSubscription ?? ScoreCalculation.of(context)!.listenForRemovedCluster(context);
  }

  @override
  Widget drawCell(Position position, Stone? stone) {
    return ValueListenableBuilder(
        valueListenable: ScoreCalculation.of(_context!)!.areaMap[position]!,
        builder: (context, Area? dyn, wid) {
          return dyn?.owner != null
              ? Center(
                  child: Stack(
                    children: [
                      stone != null ? Stone(stone.color!.withOpacity(0.6), position) : const SizedBox.shrink(),
                      Center(
                        child: FractionallySizedBox(
                          heightFactor: 0.3,
                          widthFactor: 0.3,
                          child: Container(
                            color: dyn?.owner,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : () {
                  return stone != null
                      ? (Stone stone) {
                          if (_context != null) {
                            if (ScoreCalculation.of(_context!)!.virtualRemovedCluster.contains(stone.cluster)) {
                              return Stone(stone.color!.withOpacity(0.6), position);
                            } else {
                              return stone;
                            }
                          } else {
                            return stone;
                          }
                        }.call(stone)
                      : Container(
                          color: Colors.grey.withOpacity(0.5),
                        );
                }.call();
        });
  }

  @override
  onClickCell(Position? position, BuildContext context) {
    _context = context;
    if (StoneLogic.of(context)!.playground_Map[position]?.value != null) {
      if (ScoreCalculation.of(context)!.virtualRemovedCluster.contains(StoneLogic.of(context)!.playground_Map[position]!.value!.cluster)) {
        var cluster = StoneLogic.of(context)!.playground_Map[position]!.value!.cluster;
        ScoreCalculation.of(context)!.virtualRemovedCluster.remove(cluster);

        MultiplayerData.of(context)!.curGameReferences!.removedClusters.child(cluster.smallestPosition().toString()).remove();
      } else {
        var cluster = StoneLogic.of(context)!.playground_Map[position]!.value!.cluster;
        ScoreCalculation.of(context)!.virtualRemovedCluster.add(cluster);
        MultiplayerData.of(context)!.curGameReferences!.removedClusters.update({cluster.smallestPosition().toString(): false});
      }
      ScoreCalculation.of(context)!.calculateScore(context);
    }
  }

  @override
  disposeStage() {
    removedClusterSubscription.forEach((element) {
      element.cancel();
    });
  }
}
