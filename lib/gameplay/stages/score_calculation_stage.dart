import 'dart:async';
import 'package:go/constants/constants.dart' as constants;

import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/game_match.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/gameboard_bloc.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:provider/provider.dart';

// class ScoreCalculationStage extends Stage<ScoreCalculationStage> {
class ScoreCalculationStage extends Stage {
  StreamSubscription? removedClusterSubscription;
  StreamSubscription? opponentConfirmationStream;
  //get context => _context;

  @override
  ScoreCalculationStage? get stage => this;
  @override
  void initializeWhenAllMiddlewareAvailable(context) {
    context.read<GameStateBloc>().finalRemovedCluster.forEach((element) {
      ScoreCalculation.of(context)!
          .virtualRemovedCluster
          .add(StoneLogic.of(context)!.playgroundMap[element]!.cluster);
    });

    context.read<GameStateBloc>().timerController[0].pause();
    context.read<GameStateBloc>().timerController[1].pause();
    ScoreCalculation.of(context)!.calculateScore(StoneLogic.of(context)!);
    removedClusterSubscription = listenForRemovedCluster(context);
    opponentConfirmationStream = listenForOpponentConfirmation(context);
    // ScoreCalculation.of(context)!.calculateScore(context);
  }

  ScoreCalculationStage();

  @override
  List<Widget> buttons() {
    return [Accept(), Resign()];
  }

  @override
  Widget drawCell(Position position, StoneWidget? stone, BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ScoreCalculation.of(context)!.areaMap[position]!,
        builder: (context, Area? dyn, wid) {
          return dyn?.owner != null
              ? Center(
                  child: Stack(
                    children: [
                      stone != null
                          ? StoneWidget(stone.color!.withOpacity(0.6), position)
                          : const SizedBox.shrink(),
                      Center(
                        child: FractionallySizedBox(
                          heightFactor: 0.3,
                          widthFactor: 0.3,
                          child: Container(
                            color: constants.playerColors[dyn!.owner!],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : () {
                  return stone != null
                      ? (StoneWidget stone) {
                          if (ScoreCalculation.of(context)!
                              .virtualRemovedCluster
                              .contains(context
                                  .read<GameboardBloc>()
                                  .stones[stone.pos]!
                                  .cluster)) {
                            return StoneWidget(
                                stone.color!.withOpacity(0.6), position);
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
    if (StoneLogic.of(context)!.playgroundMap[position] != null) {
      if (ScoreCalculation.of(context)!
          .virtualRemovedCluster
          .contains(StoneLogic.of(context)!.playgroundMap[position]!.cluster)) {
        var cluster = StoneLogic.of(context)!.playgroundMap[position]!.cluster;
        ScoreCalculation.of(context)!.virtualRemovedCluster.remove(cluster);
        context.read<GameStateBloc>().removeClusterFromRemovedClusters(cluster);

        // MultiplayerData.of(context)!
        //     .curGameReferences!
        //     .removedClusters
        //     .child(cluster.smallestPosition().toString())
        //     .remove();
      } else {
        var cluster = StoneLogic.of(context)!.playgroundMap[position]!.cluster;
        ScoreCalculation.of(context)!.virtualRemovedCluster.add(cluster);

        context.read<GameStateBloc>().addClusterToRemovedClusters(cluster);
        // MultiplayerData.of(context)!
        //     .curGameReferences!
        //     .removedClusters
        //     .update({cluster.smallestPosition().toString(): false});
      }
      ScoreCalculation.of(context)!.calculateScore(StoneLogic.of(context)!);
    }
  }

  StreamSubscription listenForRemovedCluster(BuildContext context) {
    final stoneLogic = StoneLogic.of(context);
    final scoreCalculation = ScoreCalculation.of(context);
    return context
        .read<GameStateBloc>()
        .listenFromRemovedCluster
        .listen((event) {
      if (stoneLogic!.playgroundMap[event.$2]?.cluster != null) {
        final cluster = stoneLogic.playgroundMap[event.$2]!.cluster;
        if (event.$1) {
          scoreCalculation!.virtualRemovedCluster.add(cluster);
        } else {
          scoreCalculation!.virtualRemovedCluster.remove(cluster);
        }
      }
      // MultiplayerData.of(context)!
      //     .curGameReferences!
      //     .removedClusters
    });
    // return [
    //     MultiplayerData.of(context)!
    //         .curGameReferences
    //         ?.removedClusters
    //         .onChildAdded
    //         .listen((event) {
    //       ScoreCalculation.of(context)?.virtualRemovedCluster.add(StoneLogic.of(
    //               context)!
    //           .playgroundMap[Position.fromString(event.snapshot.key as String)]
    //           ?.value
    //           ?.cluster as Cluster);

    //       ScoreCalculation.of(context)?.calculateScore(context);
    //     }),
    //     MultiplayerData.of(context)!
    //         .curGameReferences
    //         ?.removedClusters
    //         .onChildRemoved
    //         .listen((event) {
    //       if (StoneLogic.of(context)!
    //               .playgroundMap[
    //                   Position.fromString(event.snapshot.key as String)]
    //               ?.value
    //               ?.cluster !=
    //           null) {
    //         ScoreCalculation.of(context)?.virtualRemovedCluster.remove(StoneLogic
    //                 .of(context)!
    //             .playgroundMap[Position.fromString(event.snapshot.key as String)]
    //             ?.value
    //             ?.cluster as Cluster);

    //         ScoreCalculation.of(context)?.calculateScore(context);
    //       }
    //     })
    //   ];
    // }
  }

  StreamSubscription listenForOpponentConfirmation(BuildContext context) {
    final gameState = context.read<GameStateBloc>();
    final scoreCalculator = ScoreCalculation.of(context)!;
    final stoneLogic = StoneLogic.of(context)!;

    return gameState.listenFromOpponentConfirmation.listen((data) {
      if (data) {
        listenForGameEndRequest(scoreCalculator, gameState, stoneLogic);
      } else {
        gameState.cur_stage_type = StageType.Gameplay;
      }
    });
  }

  listenForGameEndRequest(ScoreCalculation scoreCalculator,
      GameStateBloc gameState, StoneLogic stoneLogic) {
    // return MultiplayerData.of(context)!.curGameReferences?.removedClusters.get().then((data) {
    Set<Cluster> opponentsCluster = gameState.getRemovedClusters();
    scoreCalculator.virtualRemovedCluster = opponentsCluster;
    scoreCalculator.calculateScore(stoneLogic);
    scoreCalculator.stoneRemovalAccepted.add(gameState.getRemotePlayerIndex());

    scoreCalculator.onGameEnd(gameState, opponentsCluster);
    // bool declareResult = true;
    // opponentsCluster.forEach((element) {
    //   if (!ScoreCalculation.of(context)!.virtualRemovedCluster.contains(element)) {
    //     declareResult = false;
    //   }
    // });
    // if (opponentsCluster.length != ScoreCalculation.of(context)?.virtualRemovedCluster.length) {
    //   declareResult = false;
    // }
    // });
  }

  @override
  disposeStage() {
    removedClusterSubscription?.cancel();
    opponentConfirmationStream?.cancel();
  }

  @override
  StageType get getType => StageType.ScoreCalculation;
}

// class GameBoardBloc {
// }
