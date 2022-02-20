import 'package:flutter/src/widgets/framework.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/utils/position.dart';

class BeforeStartStage extends Stage {
  const BeforeStartStage();
  @override
  onClickCell(Position position, BuildContext context) {
    // Before game do nothing on click on cell
  }
}
