import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/utils/position.dart';

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
  Widget drawCell(Position position, Stone? stone, BuildContext context) {
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
}
