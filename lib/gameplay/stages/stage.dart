import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/utils/position.dart';

abstract class Stage { //<Derived extends Stage<Derived>> {
  // Derived child;
  Stage? get stage;
  Stage();

  onClickCell(Position? position, BuildContext context);

  Widget drawCell(Position position,Stone? stone,BuildContext context);

  disposeStage();

  List<Widget> buttons();

  void initializeWhenAllMiddlewareAvailable(context);
}

