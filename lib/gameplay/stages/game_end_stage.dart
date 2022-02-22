import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/cell.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/position.dart';

class GameEndStage extends Stage {
  int blackScore = 0;
  int whiteScore = 0;
  Map? finalScoreMap;
  BuildContext? _context;

  GameEndStage(context) {
    _context = context;
    GameData.of(context)?.timerController[0].pause();
    GameData.of(context)?.timerController[1].pause();
    finalScoreMap = ScoreCalculation.of(context)!.calculateScore(context);
  }

  @override
  Widget drawCell(Position position, Stone? stone) {
    return finalScoreMap?[position]?.owner != null
        ? Center(
            child: FractionallySizedBox(
              heightFactor: 0.3,
              widthFactor: 0.3,
              child: Container(
                color: finalScoreMap?[position].owner,
              ),
            ),
          )
        : () {
            return stone != null
                ? (Stone stone) {
                    if (_context != null) {
                      if (ScoreCalculation.of(_context!)!.virtualRemovedCluster.contains(stone.cluster)) {
                        return Stone(stone.color!.withOpacity(0.6), position);
                      } else {
                        return stone;
                      }
                    } else {
                      return stone;
                    }
                  }.call(stone)
                : Container(
                    color: Colors.transparent,
                  );
          }.call();
  }

  @override
  onClickCell(Position? position, BuildContext context) {
    _context = context;
    if (StoneLogic.of(context)!.playground_Map[position]?.value != null) {
      ScoreCalculation.of(context)!.virtualRemovedCluster.add(StoneLogic.of(context)!.playground_Map[position]!.value!.cluster);
      GameData.of(context)!.cur_stage = GameEndStage(context);
    }
  }
}
