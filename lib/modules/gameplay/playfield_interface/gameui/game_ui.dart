import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/move_tree.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/ui_actions.dart';
import 'package:go/modules/gameplay/stages/analysis_stage.dart';
import 'package:go/modules/gameplay/stages/game_end_stage.dart';
import 'package:go/modules/gameplay/stages/score_calculation_stage.dart';
import 'package:go/modules/gameplay/stages/stage.dart';

import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/player_card.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:provider/provider.dart';

class GameUi extends StatefulWidget {
  final Widget boardWidget;

  const GameUi({super.key, required this.boardWidget});
  @override
  State<GameUi> createState() => _GameUiState();
}

class _GameUiState extends State<GameUi> {
  void openBottomSheet(AnalysisBloc analysisBloc) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ChangeNotifierProvider<AnalysisBloc>.value(
          value: analysisBloc,
          child: Container(
            height: context.height * 0.8,
            child: MoveTree(
              root: analysisBloc.start,
              direction: TreeDirection.horizontal,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateBloc>(
      builder: (context, gameStateBloc, child) {
        return Column(
          children: [
            SizedBox(
              height: context.height * 0.05,
            ),
            SizedBox(
              height: context.height * 0.08,
              child: PlayerDataUi(
                gameStateBloc.topPlayerUserInfo,
                gameStateBloc.game,
                connectionStream: gameStateBloc.gameOracle.getPlatform() ==
                        GamePlatform.online
                    ? () async* {
                        yield ConnectionStrength(ping: 0);
                        yield* gameStateBloc.opponentConnection!;
                      }()
                    : null,
              ),
            ),
            SizedBox(
              height: context.height * 0.02,
            ),
            Container(
              // height: context.height * 0.6,
              child: widget.boardWidget,
            ),
            SizedBox(
              height: context.height * 0.02,
            ),
            SizedBox(
              height: context.height * 0.08,
              child: PlayerDataUi(
                gameStateBloc.bottomPlayerUserInfo,
                gameStateBloc.game,
                connectionStream: gameStateBloc.gameOracle.getPlatform() ==
                        GamePlatform.online
                    ? Stream.fromFuture(Future.microtask(() async {
                        await Future.delayed(Duration(seconds: 2));
                        return ConnectionStrength(ping: 0);
                      }))
                    : null,
              ),
            ),
            Spacer(),
            if (context.read<Stage>() is! GameEndStage)
              context.read<Stage>() is ScoreCalculationStage
                  ? const ScoreActions()
                  : context.read<Stage>() is AnalysisStage
                      ? AnalsisModeActions(
                          openTree: () => openBottomSheet(
                            context.read<AnalysisBloc>(),
                          ),
                        )
                      : const PlayingGameActions()
            else
              const PlayingEndedActions(),
            SizedBox(
              height: 5,
            ),
          ],
        );
      },
    );
  }

  String getWinningMethod(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    if (gameStateBloc.game.gameOverMethod == GameOverMethod.Score) {
      return "${(gameStateBloc.getSummedPlayerScores[0] - gameStateBloc.getSummedPlayerScores[1]).abs()} Point(s)";
    }
    return gameStateBloc.game.gameOverMethod!.actualName;
  }
}
