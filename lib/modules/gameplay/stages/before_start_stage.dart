import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/gameplay_stage.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:provider/provider.dart';

// class BeforeStartStage extends Stage<BeforeStartStage> {
class BeforeStartStage extends Stage {
  BeforeStartStage();

  @override
  Widget drawCell(Position position, StoneWidget? stone, BuildContext context) {
    return Container(
      color: Colors.transparent,
    );
  }

  @override
  void onClickCell(Position? position, BuildContext context) {
    final bloc = context.read<GameStateBloc>();

    if (bloc.game.bothPlayersIn()) {
      GameplayStage.makeMove(context, position);
    }
  }

  @override
  disposeStage() {}

  @override
  void initializeWhenAllMiddlewareAvailable(context) {}

  @override
  StageType get getType => StageType.beforeStart;
}
