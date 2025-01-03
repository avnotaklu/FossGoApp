import 'package:go/constants/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/gameplay/middleware/score_calculation.dart';
import 'package:go/modules/gameplay/middleware/score_calculator.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/stage.dart';

import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:provider/provider.dart';

class GameEndStage extends Stage {
  final GameStateBloc gameStateBloc;
  final BoardStateBloc boardStateBloc;

  GameEndStage(this.boardStateBloc,this.gameStateBloc);

  @override
  Widget drawCell(
      Position position, StoneWidget? deprStone, BuildContext context) {
    final stone = boardStateBloc.stoneAt(position);
    final stoneColor =
        stone != null ? constants.playerColors[stone.player] : null;

    return ValueListenableBuilder(
        valueListenable:
            context.read<ScoreCalculationBloc>().areaMap[position]!,
        builder: (context, Area? dyn, wid) {
          return dyn?.owner != null
              ? Center(
                  child: Stack(
                    children: [
                      stoneColor != null
                          ? StoneWidget(stoneColor.withOpacity(0.6), position)
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
                      ? (Stone? stone) {
                          if (stone != null &&
                              context
                                  .read<ScoreCalculationBloc>()
                                  .removedClusters
                                  .contains(stone!.cluster)) {
                            return StoneWidget(
                                stoneColor!.withOpacity(0.6), position);
                          } else {
                            return StoneWidget(stoneColor, position);
                          }
                        }.call(stone)
                      : Container(
                          color: Colors.transparent,
                        );
                }.call();
        });
  }

  @override
  void onClickCell(Position? position, BuildContext context) {
    // After game ended do nothing on cell click
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
