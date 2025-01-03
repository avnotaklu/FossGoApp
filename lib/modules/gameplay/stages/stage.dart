import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/analysis_stage.dart';
import 'package:go/modules/gameplay/stages/before_start_stage.dart';
import 'package:go/modules/gameplay/stages/game_end_stage.dart';
import 'package:go/modules/gameplay/stages/gameplay_stage.dart';
import 'package:go/modules/gameplay/stages/score_calculation_stage.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/models/position.dart';

enum StageType { beforeStart, gameplay, gameEnd, scoreCalculation, analysis }

extension Constructor on StageType {
  Stage stageConstructor(
    GameStateBloc gameStateBloc,
    BoardStateBloc boardStateBloc,
    AnalysisBloc analysisBloc,
  ) =>
      switch (this) {
        StageType.beforeStart => BeforeStartStage(),
        StageType.gameplay => GameplayStage(boardStateBloc,gameStateBloc),
        StageType.gameEnd => GameEndStage(boardStateBloc, gameStateBloc),
        StageType.scoreCalculation =>
          ScoreCalculationStage(boardStateBloc, gameStateBloc),
        StageType.analysis => AnalysisStage(analysisBloc),
      };
}

abstract class Stage extends ChangeNotifier {
  Stage() {
    notifyListeners();
  }

  void onClickCell(Position? position, BuildContext context);

  Widget drawCell(Position position, StoneWidget? stone, BuildContext context);

  void disposeStage();

  void initializeWhenAllMiddlewareAvailable(BuildContext context);

  StageType get getType;
}
