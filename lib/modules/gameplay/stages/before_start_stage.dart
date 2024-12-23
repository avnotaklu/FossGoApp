import 'package:flutter/material.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
import 'package:go/models/position.dart';

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
  onClickCell(Position? position, BuildContext context) {
    // Before game do nothing on click on cell
  }

  @override
  disposeStage() {}

  @override
  void initializeWhenAllMiddlewareAvailable(context) {}

  @override
  StageType get getType => StageType.beforeStart;
}
