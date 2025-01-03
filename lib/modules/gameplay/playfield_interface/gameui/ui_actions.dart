import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/services/move_position.dart';
import 'package:provider/provider.dart';

class ActionButtonWidget extends StatelessWidget {
  const ActionButtonWidget(
    this.action,
    this.actionType, {
    super.key,
    this.longPress,
    this.longPressEnd,
    this.longPressStart,
  });
  final VoidCallback? longPress;

  final void Function(LongPressStartDetails)? longPressStart;
  final void Function(LongPressEndDetails)? longPressEnd;

  final VoidCallback? action;
  final ActionType actionType;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        child: InkWell(
          onTap: action,
          splashFactory: InkRipple.splashFactory,
          child: GestureDetector(
            onLongPress: longPress,
            onLongPressStart: longPressStart,
            onLongPressEnd: longPressEnd,
            child: Container(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                children: [
                  Icon(
                    actionType.icon,
                    size: 18,
                  ),
                  Text(actionType.label,
                      style:
                          context.textTheme.labelSmall?.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
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
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) => ActionStrip(actions: [
        if (settingsProvider.moveInput == MoveInputMode.submitButton) Submit(),
        EnterAnalysisButton(),
        Resign(),
        Pass(),
      ]),
    );
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
    return Container(
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions,
        ),
      ),
    );
  }
}

class Submit extends StatelessWidget {
  const Submit({super.key});

  @override
  Widget build(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    return Consumer<BoardStateBloc>(
      builder: (context, boardStateBloc, child) => ActionButtonWidget(
          (gameStateBloc.intermediate == null)
              ? null
              : () {
                  gameStateBloc.makeMove(gameStateBloc.intermediate!);
                  gameStateBloc.intermediate = null;
                },
          ActionType.submit),
    );
  }
}

class Pass extends StatelessWidget {
  const Pass({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(() {
      context.read<GameStateBloc>().makeMove(MovePosition(x: null, y: null));
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
      await context.read<GameStateBloc>().continueGame();
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
      Navigator.pushNamedAndRemoveUntil(context, "/HomePage", (v) => false);
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
      case ActionType.submit:
        return "Submit";
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
      case ActionType.submit:
        return Icons.save;
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
  submit,
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
