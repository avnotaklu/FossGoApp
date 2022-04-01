import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/game_match.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/utils/position.dart';

// class ScoreCalculationStage extends Stage<ScoreCalculationStage> {
class ScoreCalculationStage extends Stage {
  var removedClusterSubscription;
  var opponentConfirmationStream;
  //get context => _context;

  @override
  ScoreCalculationStage? get stage => this;
  @override
  void initializeWhenAllMiddlewareAvailable(context) {
    GameData.of(context)?.match.finalRemovedCluster.forEach((element) {
      ScoreCalculation.of(context)!.virtualRemovedCluster.add(StoneLogic.of(context)!.playground_Map[element]!.value!.cluster);
    });

    GameData.of(context)?.timerController[0].pause();
    GameData.of(context)?.timerController[1].pause();
    ScoreCalculation.of(context)!.calculateScore(context);
    removedClusterSubscription = listenForRemovedCluster(context);
    opponentConfirmationStream = listenForOpponentConfirmation(context);
    // ScoreCalculation.of(context)!.calculateScore(context);
  }

  ScoreCalculationStage(context) {
  }

  @override
  List<Widget> buttons() {
    return [Accept(), Resign()];
  }

  @override
  Widget drawCell(Position position, Stone? stone, BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ScoreCalculation.of(context)!.areaMap[position]!,
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
                          if (ScoreCalculation.of(context)!.virtualRemovedCluster.contains(stone.cluster)) {
                            return Stone(stone.color!.withOpacity(0.6), position);
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

  List listenForRemovedCluster(context) {
    return [
      MultiplayerData.of(context)!.curGameReferences?.removedClusters.onChildAdded.listen((event) {
        ScoreCalculation.of(context)
            ?.virtualRemovedCluster
            .add(StoneLogic.of(context)!.playground_Map[Position.fromString(event.snapshot.key as String)]?.value?.cluster as Cluster);

        ScoreCalculation.of(context)?.calculateScore(context);
      }),
      MultiplayerData.of(context)!.curGameReferences?.removedClusters.onChildRemoved.listen((event) {
        if (StoneLogic.of(context)!.playground_Map[Position.fromString(event.snapshot.key as String)]?.value?.cluster != null) {
          ScoreCalculation.of(context)
              ?.virtualRemovedCluster
              .remove(StoneLogic.of(context)!.playground_Map[Position.fromString(event.snapshot.key as String)]?.value?.cluster as Cluster);

          ScoreCalculation.of(context)?.calculateScore(context);
        }
      })
    ];
  }

  listenForOpponentConfirmation(context) {
    return MultiplayerData.of(context)!.curGameReferences?.finalOpponentConfirmation(context).onValue.listen((event) {
      if (event.snapshot.value == true) {
        listenForGameEndRequest(context);
      } else if (event.snapshot.value == false) {

        GameData.of(context)!.cur_stage = GameplayStage(context);
      }
    });
  }

  listenForGameEndRequest(context) {
    // return MultiplayerData.of(context)!.curGameReferences?.runStatus.onValue.listen((event) {
    MultiplayerData.of(context)!.curGameReferences?.finalRemovedClusters.get().then((cluster) {
      Set<Cluster> opponentsCluster = GameData.of(context)!.match.removedClusterFromJson(cluster.value, context);

      ScoreCalculation.of(context)!.virtualRemovedCluster = opponentsCluster;
      ScoreCalculation.of(context)!.calculateScore(context);
      ScoreCalculation.of(context)!.stoneRemovalAccepted.add(GameData.of(context)!.getRemotePlayer(context) as int);

      ScoreCalculation.of(context)!.onGameEnd(context, opponentsCluster);
      // bool declareResult = true;
      // opponentsCluster.forEach((element) {
      //   if (!ScoreCalculation.of(context)!.virtualRemovedCluster.contains(element)) {
      //     declareResult = false;
      //   }
      // });
      // if (opponentsCluster.length != ScoreCalculation.of(context)?.virtualRemovedCluster.length) {
      //   declareResult = false;
      // }
    });
  }

  @override
  disposeStage() {
    
    removedClusterSubscription.forEach((element) {
      element.cancel();
    });
    opponentConfirmationStream.cancel();
  }
}
