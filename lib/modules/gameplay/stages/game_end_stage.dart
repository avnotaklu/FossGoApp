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

class GameEndStage extends Stage {
  final GameStateBloc gameStateBloc;
  final BoardStateBloc boardStateBloc;

  GameEndStage(this.boardStateBloc, this.gameStateBloc);

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
                                  stone.toStoneType(), opacity: 0.6, position)
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
                              if (context
                                  .read<ScoreCalculationBloc>()
                                  .removedClusters
                                  .contains(stone!.cluster)) {
                                return StoneWidget(
                                    stone.toStoneType(),
                                    opacity: (0.6),
                                    position);
                              } else {
                                return StoneWidget(
                                    stone.toStoneType(), position);
                              }
                            }.call(stone)
                          : Container(
                              color: Colors.transparent,
                            );
                    }.call();
            }),
        if (move?.toPosition() == position)
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
  disposeStage() {}

  @override
  void initializeWhenAllMiddlewareAvailable(context) {
    boardStateBloc.resetToReal();
  }

  @override
  StageType get getType => StageType.gameEnd;
}
