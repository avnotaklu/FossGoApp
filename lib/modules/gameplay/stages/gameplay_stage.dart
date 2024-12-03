
import 'package:flutter/material.dart';
import 'package:go/modules/gameplay/middleware/score_calculation.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:provider/provider.dart';

// class GameplayStage extends Stage<GameplayStage> {
class GameplayStage extends Stage {
  // StreamSubscription? listenNewStone;

  GameplayStage.fromScratch();

  GameplayStage(context);

  @override
  GameplayStage get stage => this;

  @override
  void initializeWhenAllMiddlewareAvailable(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    gameStateBloc.startPausedTimerOfActivePlayer();
    // listenNewStone = gameStateBloc.listenForMove();
    context.read<ScoreCalculationBloc>().calculateScore();
  }

  @override
  List<Widget> buttons() {
    return [const Pass(), const Resign()];
  }

  @override
  Widget drawCell(Position position, StoneWidget? stone, BuildContext context) {
    return Stack(
      children: [
        stone ??
            Container(
              decoration: const BoxDecoration(color: Colors.transparent),
            ),
      ],
    );
  }

  @override
  onClickCell(Position? position, BuildContext context) {
    StoneLogic stoneLogic = context.read();
    context.read<GameStateBloc>().playMove(position, stoneLogic);
  }

  @override
  disposeStage() {
    // TODO: implement disposeStage
    // listenNewStone?.cancel();
  }

  @override
  StageType get getType => StageType.Gameplay;
}
