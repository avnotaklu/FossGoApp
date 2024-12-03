import 'dart:async';
import 'package:go/constants/constants.dart' as constants;

import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/gameplay/middleware/score_calculation.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/game_end_stage.dart';
import 'package:go/modules/gameplay/stages/gameplay_stage.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/modules/gameplay/middleware/board_utility/cluster.dart';

import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/game_board_bloc.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:provider/provider.dart';

// class ScoreCalculationStage extends Stage<ScoreCalculationStage> {
class ScoreCalculationStage extends Stage {
  StreamSubscription? removedClusterSubscription;
  StreamSubscription? opponentConfirmationStream;
  //get context => _context;
  late Map<Position, Stone> stonesCopy;

  @override
  ScoreCalculationStage? get stage => this;
  @override
  void initializeWhenAllMiddlewareAvailable(context) {
    final gameBoarcBloc = context.read<GameBoardBloc>();
    final gameStateBloc = context.read<GameStateBloc>();
    gameStateBloc.timerController[0].pause();
    gameStateBloc.timerController[1].pause();
    context.read<ScoreCalculationBloc>().setupScore();
    stonesCopy = gameBoarcBloc.stones;
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
        valueListenable:
            context.read<ScoreCalculationBloc>().areaMap[position]!,
        builder: (context, Area? dyn, wid) {
          return dyn?.owner != null
              ? Center(
                  child: Stack(
                    children: [
                      stone != null
                          ? StoneWidget(
                              constants.playerColors[dyn!.owner!]
                                  .withOpacity(0.6),
                              position)
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
                          if (stonesCopy.containsKey(stone.pos) &&
                              context
                                  .read<ScoreCalculationBloc>()
                                  .virtualRemovedCluster
                                  .contains(stonesCopy[stone.pos]!.cluster)) {
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
    if (stonesCopy[position] != null) {
      context.read<ScoreCalculationBloc>().onClickStone(position!);
    }
  }

  @override
  disposeStage() {
    removedClusterSubscription?.cancel();
    opponentConfirmationStream?.cancel();
  }

  @override
  StageType get getType => StageType.ScoreCalculation;
}