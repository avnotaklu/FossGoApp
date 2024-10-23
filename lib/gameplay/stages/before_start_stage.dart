import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/models/position.dart';

// class BeforeStartStage extends Stage<BeforeStartStage> {
class BeforeStartStage extends Stage {
  BeforeStartStage();

  @override
  BeforeStartStage get stage => this;

  

  @override
  List<Widget> buttons() {
    return [Pass(), Resign()];
  }

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
  StageType get getType => StageType.BeforeStart;
}
