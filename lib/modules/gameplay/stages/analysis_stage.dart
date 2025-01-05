import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/board.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:go/utils/stone_type.dart';

class AnalysisStage extends Stage {
  final AnalysisBloc analysisBloc;
  final GameStateBloc gameStateBloc;

  AnalysisStage(this.analysisBloc, this.gameStateBloc)
      : super(onCellTap: _onTap(analysisBloc));

  @override
  void disposeStage() {
  }

  @override
  Widget drawCell(Position position, StoneWidget? stone, BuildContext context) {
    var stoneAt = analysisBloc.stoneAt(position);
    var currentMove = analysisBloc.currentMove;
    var nextMove = currentMove?.primary ?? analysisBloc.start.primary;

    var stoneWidget =
        stoneAt == null ? null : StoneWidget(stoneAt!.materialColor, position);

    var board = gameStateBloc.game.getBoardSize();

    return Stack(
      children: [
        if (stoneWidget != null) stoneWidget,
        if (nextMove != null && nextMove.position == position)
          Center(
            child: Padding(
              padding: EdgeInsets.all(board.crossIconPaddingForCells),
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        if (currentMove?.position == position)
          Center(
            child: Padding(
              padding: EdgeInsets.all(board.circleIconPaddingForCells),
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Icon(
                    Icons.circle_outlined,
                    color: stoneAt!.other.materialColor,
                  ),
                ),
              ),
            ),
          ),
        Container(
          color: Colors.transparent,
        )
      ],
    );
  }

  @override
  StageType get getType => StageType.analysis;

  @override
  void initializeWhenAllMiddlewareAvailable(BuildContext context) {
    //
  }

  static Function(Position? position, BuildContext context) _onTap(
      AnalysisBloc bloc) {
    return (Position? position, BuildContext context) {
      bloc.addAlternative(position);
    };
  }
}
