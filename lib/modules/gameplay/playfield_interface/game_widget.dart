// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/foundation/provider.dart';
import 'package:go/core/foundation/string.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/middleware/score_calculation.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/compact_ui.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/desktop_game_ui.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_over_card.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/auth/auth_provider.dart';

import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:go/widgets/my_app_drawer.dart';
import 'package:provider/provider.dart';
import 'dart:core';

import 'board.dart';
import 'package:go/constants/constants.dart' as Constants;

class GameWidget extends StatefulWidget {
  final Game game;
  final GameStateOracle gameOracle;

  const GameWidget({
    required this.game,
    required this.gameOracle,
    super.key,
  });
  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final key = GlobalKey<ScaffoldState>();
  Stage? prevStage;

  String? byoYomiTime(TimeControl time) {
    return time.byoYomiTime != null
        ? "${time.byoYomiTime!.byoYomis} x ${time.byoYomiTime!.byoYomiSeconds}s"
        : null;
  }

  String? mainTime(TimeControl time) {
    return Duration(seconds: time.mainTimeSeconds).smallRepr();
  }

  String? incrementTime(TimeControl time) {
    if (time.incrementSeconds == null) return null;
    return Duration(seconds: time.incrementSeconds!).smallRepr();
  }

  String gameTitle(Game game) {
    return game.title;
  }

  StageType getStageType() => switch (widget.game.gameState) {
        GameState.waitingForStart => StageType.beforeStart,
        GameState.playing => StageType.gameplay,
        GameState.scoreCalculation => StageType.scoreCalculation,
        GameState.ended => StageType.gameEnd,
        GameState.paused => StageType.beforeStart,
      };

  // Board
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => GameStateBloc(widget.game, widget.gameOracle,
            systemUtils, context.read<SettingsProvider>()),
        builder: (context, child) {
          return Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) => Scaffold(
              key: key,
              drawer: MyAppDrawer(
                gameWidgetDrawer: true,
                navigationItems: [],
              ),
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Consumer<GameStateBloc>(
                  builder: (context, gameStateBloc, child) =>
                      settingsProvider.compactGameUISetting.isCompact(
                                  context.read<GameStateBloc>().curStageType) &&
                              !context.isTabletOrDesktop
                          ? SizedBox.shrink()
                          : MyAppBar(
                              gameTitle(context.read<GameStateBloc>().game),
                              leading: IconButton(
                                onPressed: () {
                                  if (key.currentState!.isDrawerOpen) {
                                    key.currentState!.closeDrawer();
                                  } else {
                                    key.currentState!.openDrawer();
                                  }
                                },
                                icon: const Icon(Icons.menu),
                              ),
                            ),
                ),
              ),
              body: Consumer<GameStateBloc>(
                builder: (context, gameStateBloc, child) {
                  final game = gameStateBloc.game;
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                        create: (context) => BoardStateBloc(gameStateBloc,
                            game), // This may contain virtual intermediate positions
                      ),
                      ChangeNotifierProvider(
                        create: (context) => AnalysisBloc(
                          gameStateBloc,
                          const SystemUtilities(),
                          context.read<SettingsProvider>(),
                        ),
                      ),
                    ],
                    builder: (context, child) {
                      context.read<BoardStateBloc>().setupGame(game);
                      return ChangeNotifierProvider(
                        create: (context) {
                          return ScoreCalculationBloc(
                            api: context.read<AuthProvider>().api,
                            authBloc: context.read<AuthProvider>(),
                            gameStateBloc: context.read<GameStateBloc>(),
                            gameBoardBloc: context.read<BoardStateBloc>(),
                          );
                        },
                        builder: (context, child) {
                          var stage = context
                              .read<GameStateBloc>()
                              .curStageType
                              .stageConstructor(
                                context.read<GameStateBloc>(),
                                context.read<BoardStateBloc>(),
                                context.read<AnalysisBloc>(),
                              );

                          if (prevStage.runtimeType != stage.runtimeType) {
                            prevStage?.dispose();
                          }
                          prevStage = stage;

                          return ChangeNotifierProvider<Stage>.value(
                            value: stage,
                            builder: (context, child) {
                              return Consumer<ScoreCalculationBloc>(
                                builder: (context, dyn, child) => WrapperGame(
                                  game,
                                  compact_ui: settingsProvider
                                      .compactGameUISetting
                                      .isCompact(context
                                          .read<GameStateBloc>()
                                          .curStageType),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        });
  }
}

class WrapperGame extends StatefulWidget {
  final bool compact_ui;
  final Game game;

  const WrapperGame(this.game, {required this.compact_ui, super.key});

  @override
  State<WrapperGame> createState() => _WrapperGameState();
}

class _WrapperGameState extends State<WrapperGame> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<GameStateBloc>().gameEndStream.listen((event) {
        final c = context;
        if (c.mounted) {
          showDialog(
            context: c,
            builder: (context) => GameOverCard(
              gameStat: c.read<GameStateBloc>(),
              oldContext: c,
            ),
          );
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      context.read<Stage>().initializeWhenAllMiddlewareAvailable(context);
    });

    final board =
        Board(widget.game.rows, widget.game.columns, widget.game.playgroundMap);

    if (context.isDesktop) {
      return DesktopGameUi(boardWidget: board);
    }

    if (widget.compact_ui) {
      return CompactGameUi(boardWidget: board);
    }

    return GameUi(
      boardWidget: board,
    );
  }
}
