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
import 'package:go/models/move_position.dart';
import 'package:go/widgets/secondary_button.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ActionButtonWidget extends StatefulWidget {
  const ActionButtonWidget(
    this.action,
    this.actionType, {
    super.key,
    this.longPress,
    this.longPressEnd,
    this.longPressStart,
    this.twoStep = false,
  });
  final VoidCallback? longPress;
  final bool twoStep;

  final void Function(LongPressStartDetails)? longPressStart;
  final void Function(LongPressEndDetails)? longPressEnd;

  final VoidCallback? action;
  final ActionType actionType;

  @override
  State<ActionButtonWidget> createState() => _ActionButtonWidgetState();
}

class _ActionButtonWidgetState extends State<ActionButtonWidget> {
  bool overlay = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 40,
          maxHeight: 60,
        ),
        // height: 30,
        child: Material(
          elevation: overlay ? 5 : 0,
          shadowColor: Colors.blue,
          borderRadius: BorderRadius.circular(10),
          color: overlay ? SecondaryButton.color : null,
          child: TapRegion(
            onTapOutside: (ev) {
              setState(() {
                overlay = false;
              });
            },
            child: InkWell(
              onTap: !widget.twoStep || overlay
                  ? () {
                      widget.action?.call();
                      setState(() {
                        overlay = false;
                      });
                    }
                  : () {
                      setState(() {
                        overlay = true;
                      });
                    },
              splashFactory: InkRipple.splashFactory,
              child: Container(
                child: GestureDetector(
                  onLongPress: widget.longPress,
                  onLongPressStart: widget.longPressStart,
                  onLongPressEnd: widget.longPressEnd,
                  child: Container(
                    padding: const EdgeInsets.only(top: 4),
                    child: LayoutBuilder(
                      builder: (context, cons) => Column(
                        children: [
                          Icon(
                            widget.actionType.icon,
                            size: cons.maxHeight * 0.2,
                          ),
                          Text(widget.actionType.label,
                              style: context.textTheme.labelSmall?.copyWith(
                                fontSize: cons.maxHeight * 0.2,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
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
        if (settingsProvider.moveInput == MoveInputMode.twoStep) Submit(),
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
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) => ActionStrip(actions: [
        const ExitAnalysisButton(),
        const AnalysisPass(),
        if (!settingsProvider.compactGameUISetting
            .isCompact(StageType.analysis))
          OpenTree(openTree: openTree),
        BackwardButton(),
        ForwardButton(),
      ]),
    );
  }
}

class ActionStrip extends StatelessWidget {
  final List<Widget> actions;
  const ActionStrip({required this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      //   return IntrinsicWidth(
      //     child: IntrinsicHeight(
      //       child:
      return ResponsiveRowColumn(
        layout: cons.maxWidth > 300
            ? ResponsiveRowColumnType.ROW
            : ResponsiveRowColumnType.COLUMN,
        rowMainAxisAlignment: MainAxisAlignment.spaceAround,
        columnCrossAxisAlignment: CrossAxisAlignment.stretch,
        columnSpacing: 20,
        children:
            actions.map((e) => ResponsiveRowColumnItem(child: e)).toList(),
      );
      // )// ,
      //   );
    });
  }
}

class Submit extends StatelessWidget {
  const Submit({super.key});

  @override
  Widget build(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    return Consumer<BoardStateBloc>(
      builder: (context, boardStateBloc, child) => ActionButtonWidget(
          (boardStateBloc.intermediate == null)
              ? null
              : () {
                  gameStateBloc.makeMove(
                      boardStateBloc.intermediate!, boardStateBloc);
                },
          ActionType.submit),
    );
  }
}

class Pass extends StatefulWidget {
  Pass() : super(key: GlobalKey());

  @override
  State<Pass> createState() => _PassState();
}

class _PassState extends State<Pass> {
  // bool showHigh = false;
  // OverlayEntry? entry;

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(
      () {
        // if (context.read<SettingsProvider>().moveInput ==
        //         MoveInputMode.immediate) {
        pass(context);

        // setState(() {
        //   showHigh = false;
        // });
        // } else {
        //   setState(() {
        //     showHigh = true;
        //   });
        //   // showOverlay(context);
        // }
      },
      ActionType.pass,
      twoStep:
          context.read<SettingsProvider>().moveInput == MoveInputMode.twoStep,
    );
  }

  void pass(BuildContext context) {
    context.read<GameStateBloc>().makeMove(
          MovePosition(x: null, y: null),
          context.read<BoardStateBloc>(),
        );
  }

  // void showOverlay(BuildContext context) {
  //   RenderBox box = (widget.key as GlobalKey).currentContext!.findRenderObject()
  //       as RenderBox;
  //   Offset position = box.localToGlobal(Offset.zero); //this is global position
  //   double x = position.dx;
  //   double y = position.dy;

  //   final gameState = context.read<GameStateBloc>();

  //   gameState.gameStateStream.listen((l) {
  //     removeOverlay();
  //   });

  //   entry = OverlayEntry(builder: (c) {
  //     return Positioned(
  //       left: x - 20,
  //       top: y - 20,
  //       child: TapRegion(
  //         onTapOutside: (event) {
  //           removeOverlay();
  //         },
  //         child: Container(
  //           height: 100,
  //           width: 100,
  //           child: FittedBox(
  //             fit: BoxFit.contain,
  //             child: GestureDetector(
  //                 onTap: () {
  //                   pass(context);
  //                   removeOverlay();
  //                 },
  //                 child: Card(
  //                   child: Center(
  //                     child: Text("Confirm"),
  //                   ),
  //                 )),
  //           ),
  //         ),
  //       ),
  //     );
  //   });

  //   Overlay.of(context).insert(entry!);
  // }

  // void removeOverlay() {
  //   entry?.remove();
  //   entry = null;
  // }

  // @override
  // void dispose() {
  //   removeOverlay();
  //   super.dispose();
  // }
}

class AnalysisPass extends StatelessWidget {
  const AnalysisPass({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(() {
      context.read<AnalysisBloc>().addAlternative(null);
    }, ActionType.pass);
  }
}

class Accept extends StatelessWidget {
  const Accept({super.key});

  @override
  Widget build(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    return ActionButtonWidget(twoStep: true, () {
      gameStateBloc.acceptScores();
    }, ActionType.accept);
  }
}

class ContinueGame extends StatelessWidget {
  const ContinueGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(twoStep: true, () async {
      await context.read<GameStateBloc>().continueGame();
    }, ActionType.continueGame);
  }
}

class Resign extends StatelessWidget {
  const Resign({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(twoStep: true, () {
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
