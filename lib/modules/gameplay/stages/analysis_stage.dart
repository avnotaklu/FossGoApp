import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/constants/constants.dart' as Constants;

class AnalysisStage extends Stage {
  final AnalysisBloc analysisBloc;
  AnalysisStage(this.analysisBloc);

  @override
  void disposeStage() {
    //
  }

  @override
  Widget drawCell(Position position, StoneWidget? stone, BuildContext context) {
    var stoneAt = analysisBloc.stoneAt(position);

    var realStone = stoneAt == null
        ? null
        : StoneWidget(Constants.playerColors[stoneAt!.index], position);

    return Stack(
      children: [
        realStone ??
            Container(
              decoration: const BoxDecoration(color: Colors.transparent),
            ),
      ],
    );
  }

  @override
  StageType get getType => StageType.analysis;

  @override
  void initializeWhenAllMiddlewareAvailable(BuildContext context) {
    //
  }

  @override
  void onClickCell(Position? position, BuildContext context) {
    analysisBloc.addAlternative(position);
  }
}
