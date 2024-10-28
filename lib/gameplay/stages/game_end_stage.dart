import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:go/constants/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/stone.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/game_board_bloc.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:provider/provider.dart';

// class GameEndStage extends Stage<GameEndStage> {
class GameEndStage extends Stage {
  late final Map<Position, Stone> stonesCopy;

  GameEndStage.fromScratch(context) {}

  GameEndStage(context) {
    // TODO: the constructor shouldn't contain any initializations or state related behaviour

    context.read<GameStateBloc>().timerController[0].pause();
    context.read<GameStateBloc>().timerController[1].pause();
    ScoreCalculation.of(context)!.calculateScore();
  }

  @override
  GameEndStage get stage => this;
  @override
  List<Widget> buttons() {
    return [Pass(), Resign()];
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
  onClickCell(Position? position, BuildContext context) {
    // Before game do nothing on click on cell
  }

  @override
  disposeStage() {}

  @override
  void initializeWhenAllMiddlewareAvailable(context) {
    final gameBoarcBloc = context.read<GameBoardBloc>();
    stonesCopy = gameBoarcBloc.stonesCopy;

    context.read<GameStateBloc>().finalRemovedCluster.forEach((element) {
      ScoreCalculation.of(context)!
          .virtualRemovedCluster
          .add(stonesCopy[element]!.cluster);
    });

    ScoreCalculation.of(context)!.calculateScore();
  }

  @override
  StageType get getType => StageType.GameEnd;
}
