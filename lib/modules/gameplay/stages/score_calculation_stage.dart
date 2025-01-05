import 'dart:async';
import 'package:go/constants/constants.dart' as constants;

import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/gameplay/middleware/score_calculation.dart';
import 'package:go/modules/gameplay/middleware/score_calculator.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/playfield_interface/board.dart';
import 'package:go/modules/gameplay/stages/stage.dart';

import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:go/utils/stone_type.dart';
import 'package:provider/provider.dart';

class ScoreCalculationStage extends Stage {
  StreamSubscription? removedClusterSubscription;
  StreamSubscription? opponentConfirmationStream;

  final BoardStateBloc boardStateBloc;
  final GameStateBloc gameStateBloc;

  @override
  void initializeWhenAllMiddlewareAvailable(context) {
    boardStateBloc.resetToReal();
    context.read<ScoreCalculationBloc>().setupScore();
  }

  ScoreCalculationStage(this.boardStateBloc, this.gameStateBloc)
      : super(onCellTap: _onTap(boardStateBloc));

  @override
  Widget drawCell(
      Position position, StoneWidget? deprStone, BuildContext context) {
    final stone = boardStateBloc.stoneAt(position);

    final stoneColor =
        stone != null ? constants.playerColors[stone.player] : null;

    GameMove? move = gameStateBloc.game.moves.lastOrNull;
    var board = gameStateBloc.game.getBoardSize();

    return Stack(
      children: [
        ValueListenableBuilder(
            valueListenable:
                context.read<ScoreCalculationBloc>().areaMap[position]!,
            builder: (context, Area? dyn, wid) {
              return dyn?.owner != null
                  ? Center(
                      child: Stack(
                        children: [
                          stone != null
                              ? StoneWidget(
                                  stoneColor?.withOpacity(0.8), position)
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
                          ? (Stone stone) {
                              if (boardStateBloc.stoneAt(position) != null &&
                                  context
                                      .read<ScoreCalculationBloc>()
                                      .removedClusters
                                      .contains(boardStateBloc
                                          .stoneAt(position)!
                                          .cluster)) {
                                return StoneWidget(
                                    stoneColor!.withOpacity(0.8), position);
                              } else {
                                return StoneWidget(stoneColor, position);
                              }
                            }.call(stone)
                          : Center(
                              child: FractionallySizedBox(
                                heightFactor: 0.3,
                                widthFactor: 0.3,
                                child: Container(
                                  color: Colors.grey,
                                ),
                              ),
                            );
                    }.call();
            }),
        if (move?.toPosition() ==
            position) // last move is pass for score calculation so this actually never renders
          Center(
            child: Padding(
              padding: EdgeInsets.all(board.circleIconPaddingForCells),
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Icon(
                    Icons.circle_outlined,
                    color: stone?.toStoneType().other.materialColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  disposeStage() {
    removedClusterSubscription?.cancel();
    opponentConfirmationStream?.cancel();
  }

  @override
  StageType get getType => StageType.scoreCalculation;

  static void Function(Position? position, BuildContext context) _onTap(
      BoardStateBloc boardStateBloc) {
    return (Position? position, BuildContext context) {
      if (position != null && boardStateBloc.stoneAt(position) != null) {
        context.read<ScoreCalculationBloc>().onClickStone(position);
      }
    };
  }
}
