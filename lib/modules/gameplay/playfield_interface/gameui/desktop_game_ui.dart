import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/move_tree.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/player_card.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/ui_actions.dart';
import 'package:go/modules/gameplay/stages/analysis_stage.dart';
import 'package:go/modules/gameplay/stages/game_end_stage.dart';
import 'package:go/modules/gameplay/stages/score_calculation_stage.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/services/games_history_batch.dart';
import 'package:go/widgets/section_divider.dart';
import 'package:provider/provider.dart';

class DesktopGameUi extends StatelessWidget {
  final Widget boardWidget;

  const DesktopGameUi({required this.boardWidget, super.key});

  @override
  Widget build(BuildContext context) {
    final sideInfoWidth = context.width * 0.25;

    final showMoveTreeAtSide = sideInfoWidth > 300;

    return Consumer<GameStateBloc>(
      builder: (context, gameStateBloc, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Expanded(
                flex: 3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Column(
                        children: [
                          Container(
                            width: context.width * 0.7,
                            height: context.width * 0.7,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: boardWidget,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: sideInfoWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                            height: 70,
                            child: PlayerDataUi(gameStateBloc.topPlayerUserInfo,
                                gameStateBloc.game),
                          ),
                          SectionDivider(),
                          Container(
                            height: 70,
                            child: PlayerDataUi(
                                gameStateBloc.bottomPlayerUserInfo,
                                gameStateBloc.game),
                          ),
                          showMoveTreeAtSide
                              ? Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        top: 20,
                                      ),
                                      height: context.height * 0.3,
                                      child: MoveTree(
                                        root:
                                            context.read<AnalysisBloc>().start,
                                        direction: TreeDirection.horizontal,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          const SizedBox(
                            height: 30,
                          ),
                          // if (!)
                            Container(
                              width: sideInfoWidth,
                              height: showMoveTreeAtSide ? 80 : 500,
                              child: actionButtons(context),
                            )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget actionButtons(BuildContext context) {
    if (context.read<Stage>() is! GameEndStage) {
      return context.read<Stage>() is ScoreCalculationStage
          ? const ScoreActions()
          : context.read<Stage>() is AnalysisStage
              ? AnalsisModeActions(
                  openTree: () {},
                )
              : const PlayingGameActions();
    } else {
      return const PlayingEndedActions();
    }
  }
}
