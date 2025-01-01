import 'package:go/constants/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/middleware/score_calculation.dart';
import 'package:go/modules/gameplay/middleware/score_calculator.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/stage.dart';

import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/game_board_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:provider/provider.dart';

class GameEndStage extends Stage {
  late Map<Position, Stone> stonesCopy;

  final GameStateBloc gameStateBloc;
  GameEndStage(this.gameStateBloc);

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
                      stone?.color != null
                          ? StoneWidget(
                              stone!.color!.withOpacity(0.6), position)
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
                          if (stonesCopy[stone.pos] != null &&
                              context
                                  .read<ScoreCalculationBloc>()
                                  .removedClusters
                                  .contains(stonesCopy[stone.pos]!.cluster)) {
                            return StoneWidget(
                                stone.color!.withOpacity(0.6), position);
                          } else {
                            return stone;
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
    stonesCopy = context.read<GameBoardBloc>().stones;
  }

  @override
  StageType get getType => StageType.gameEnd;
}
