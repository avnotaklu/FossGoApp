import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/game_match.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/utils/position.dart';

// class GameEndStage extends Stage<GameEndStage> {
class GameEndStage extends Stage{

  GameEndStage.fromScratch(context) {}

  GameEndStage(context) {
    // TODO: the constructor shouldn't contain any initializations or state related behaviour
    GameData.of(context)?.timerController[0].pause();
    GameData.of(context)?.timerController[1].pause();
    ScoreCalculation.of(context)!.calculateScore(context);
  }

  @override
  GameEndStage get stage => this;
  @override
  List<Widget> buttons() {
    return [Pass(), CopyId()];
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
    GameData.of(context)?.match.finalRemovedCluster.forEach((element) {
      ScoreCalculation.of(context)!.virtualRemovedCluster.add(StoneLogic.of(context)!.playground_Map[element]!.value!.cluster);
    });
    ScoreCalculation.of(context)!.calculateScore(context);
  }
}
