import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/gameplay/game_state/game_state_oracle.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/move_tree.dart';
import 'package:go/modules/gameplay/stages/analysis_stage.dart';
import 'package:go/modules/gameplay/stages/game_end_stage.dart';
import 'package:go/modules/gameplay/stages/score_calculation_stage.dart';
import 'package:go/modules/gameplay/stages/stage.dart';

import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/player_card.dart';
import 'package:provider/provider.dart';

class GameUi extends StatefulWidget {
  final bool blackTimerStarted = false;
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
            child: MoveTree(root: analysisBloc.start),
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
              ),
            ),
            SizedBox(
              height: context.height * 0.04,
            ),
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
              const PlayingEndedActions()
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

class ActionButtonWidget extends StatelessWidget {
  const ActionButtonWidget(
    this.action,
    this.actionType, {
    super.key,
    this.isDisabled = false,
    this.longPress,
    this.longPressEnd,
    this.longPressStart,
  });
  final bool isDisabled;
  final VoidCallback? longPress;

  final void Function(LongPressStartDetails)? longPressStart;
  final void Function(LongPressEndDetails)? longPressEnd;

  final VoidCallback action;
  final ActionType actionType;

  @override
  Widget build(BuildContext context) {
    // return Material(
    //   child: InkWell(
    //     splashFactory: InkRipple.splashFactory,
    //     onTap: isDisabled ? null : action,
    //     child: SizedBox(
    //       width: 100,
    //       child: Center(
    //         child: Text(
    //           text,
    //           style: context.textTheme.labelLarge,
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    return Expanded(
      child:
          // Material(
          //   child: InkWell(
          //     splashFactory: InkRipple.splashFactory,
          //     onTap: isDisabled ? null : action,
          //     child:
          GestureDetector(
        onTap: isDisabled ? null : action,
        onLongPress: longPress,
        onLongPressStart: longPressStart,
        onLongPressEnd: longPressEnd,
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Icon(
                actionType.icon,
                size: 20,
              ),
              Text(actionType.label, style: context.textTheme.labelSmall),
            ],
          ),
        ),
      ),
      //   ),
      // ),
    );
  }
}

class PlayingEndedActions extends StatelessWidget {
  const PlayingEndedActions({super.key});

  @override
  Widget build(BuildContext context) {
    return const ActionStrip(actions: [
      EnterAnalysisButton(),
      HomeButton(),
      CreateNewButton(),
    ]);
  }
}

class ScoreActions extends StatelessWidget {
  const ScoreActions({super.key});

  @override
  Widget build(BuildContext context) {
    return const ActionStrip(actions: [
      EnterAnalysisButton(),
      Accept(),
      ContinueGame(),
    ]);
  }
}

class PlayingGameActions extends StatelessWidget {
  const PlayingGameActions({super.key});

  @override
  Widget build(BuildContext context) {
    return const ActionStrip(actions: [
      EnterAnalysisButton(),
      Resign(),
      Pass(),
    ]);
  }
}

class AnalsisModeActions extends StatelessWidget {
  final VoidCallback openTree;
  const AnalsisModeActions({required this.openTree, super.key});

  @override
  Widget build(BuildContext context) {
    return ActionStrip(actions: [
      const ExitAnalysisButton(),
      OpenTree(openTree: openTree),
      BackwardButton(),
      ForwardButton(),
    ]);
  }
}

class ActionStrip extends StatelessWidget {
  final List<Widget> actions;
  const ActionStrip({required this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actions,
      ),
    );

    // return Container(
    //   color: context.theme.colorScheme.surfaceContainerHigh,
    //   height: 40,
    //   width: double.infinity,
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //     children: actions,
    //   ),
    // );
  }
}

class Pass extends StatelessWidget {
  const Pass({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(() {
      context.read<Stage>().onClickCell(null, context);
    }, ActionType.pass);
  }
}

class Accept extends StatelessWidget {
  const Accept({super.key});

  @override
  Widget build(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    return ActionButtonWidget(() {
      gameStateBloc.acceptScores();
    }, ActionType.accept);
  }
}

class ContinueGame extends StatelessWidget {
  const ContinueGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(() async {
      final res = await context.read<GameStateBloc>().continueGame();
      res.fold((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
      }, (v) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully continued game"),
          ),
        );
      });
      // });
    }, ActionType.continueGame);
  }
}

class Resign extends StatelessWidget {
  const Resign({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(() {
      context.read<GameStateBloc>().resignGame();
    }, ActionType.resign);
  }
}

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(() {
      // Navigator.pushNamedAndRemoveUntil(context, "/HomePage", (v) => false);
    }, ActionType.home);
  }
}

class CreateNewButton extends StatelessWidget {
  const CreateNewButton({super.key});

  @override
  Widget build(BuildContext context) {
    final gameStat = context.read<GameStateBloc>();
    return ActionButtonWidget(() {
      if (gameStat.getPlatform() == GamePlatform.local) {
        showOverTheBoardCreateCustomGameDialog(context);
      } else if (gameStat.getPlatform() == GamePlatform.online) {
        showLiveCreateCustomGameDialog(context);
      }
    }, ActionType.createNew);
  }
}

class EnterAnalysisButton extends StatelessWidget {
  const EnterAnalysisButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(() {
      context.read<GameStateBloc>().enterAnalysisMode();
    }, ActionType.analyze);
  }
}

class ExitAnalysisButton extends StatelessWidget {
  const ExitAnalysisButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(() {
      context.read<GameStateBloc>().exitAnalysisMode();
    }, ActionType.exitAnalysis);
  }
}

class ForwardButton extends StatelessWidget {
  Timer? timer;
  ForwardButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(
      () {
        context.read<AnalysisBloc>().forward();
      },
      ActionType.forward,
      longPressStart: (det) {
        timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          context.read<AnalysisBloc>().forward();
        });
      },
      longPressEnd: (details) {
        timer?.cancel();
      },
    );
  }
}

class BackwardButton extends StatelessWidget {
  Timer? timer;
  BackwardButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(
      () {
        context.read<AnalysisBloc>().backward();
      },
      ActionType.backward,
      longPressStart: (det) {
        timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          context.read<AnalysisBloc>().backward();
        });
      },
      longPressEnd: (details) {
        timer?.cancel();
      },
    );
  }
}

class OpenTree extends StatelessWidget {
  final VoidCallback openTree;
  const OpenTree({required this.openTree, super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(
      () {
        openTree();
      },
      ActionType.analysisTree,
    );
  }
}

extension ActionButtonUiExt on ActionType {
  String get label {
    switch (this) {
      case ActionType.pass:
        return "Pass";
      case ActionType.accept:
        return "Accept";
      case ActionType.continueGame:
        return "Continue";
      case ActionType.resign:
        return "Resign";
      case ActionType.home:
        return "Home";
      case ActionType.createNew:
        return "Create";
      case ActionType.forward:
        return "Forward";
      case ActionType.backward:
        return "Backward";
      case ActionType.analyze:
        return "Analyze";
      case ActionType.exitAnalysis:
        return "Exit";
      case ActionType.analysisTree:
        return "Lines";
    }
  }

  IconData get icon {
    switch (this) {
      case ActionType.pass:
        return Icons.close;
      case ActionType.accept:
        return Icons.check;
      case ActionType.continueGame:
        return Icons.arrow_forward;
      case ActionType.resign:
        return Icons.exit_to_app;
      case ActionType.home:
        return Icons.home;
      case ActionType.createNew:
        return Icons.add;
      case ActionType.forward:
        return Icons.arrow_forward;
      case ActionType.backward:
        return Icons.arrow_back;
      case ActionType.analyze:
        return Icons.analytics;
      case ActionType.exitAnalysis:
        return Icons.exit_to_app;
      case ActionType.analysisTree:
        return Icons.account_tree;
    }
  }
}

enum ActionType {
  pass,
  accept,
  continueGame,
  resign,
  home,
  createNew,
  forward,
  backward,
  analyze,
  exitAnalysis,
  analysisTree,
}
