import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:go/constants/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
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

  // GameEndStage.fromScratch(context) {}

  final GameStateBloc gameStateBloc;
  GameEndStage(this.gameStateBloc) {
    // gameStateBloc.timerController[0].pause();
    // gameStateBloc.timerController[1].pause();
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
        valueListenable:
            context.read<ScoreCalculationBloc>().areaMap[position]!,
        builder: (context, Area? dyn, wid) {
          return dyn?.owner != null
              ? Center(
                  child: Stack(
                    children: [
                      stone?.color != null
                          ? StoneWidget(stone!.color!.withOpacity(0.6), position)
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
    // After game ended do nothing on cell click
  }

  @override
  disposeStage() {}

  @override
  void initializeWhenAllMiddlewareAvailable(context) {
    stonesCopy = context.read<GameBoardBloc>().stones;
  }

  @override
  StageType get getType => StageType.GameEnd;
}
