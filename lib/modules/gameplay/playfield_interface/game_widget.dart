// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/foundation/string.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/modules/gameplay/middleware/score_calculation.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/game_board_bloc.dart';
import 'package:go/modules/gameplay/game_state/game_state_oracle.dart';
import 'package:go/modules/auth/auth_provider.dart';

import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
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
    // final mTime = mainTime(time);
    // final iTime = incrementTime(time);
    // final bTime = byoYomiTime(time);

    // return "$mTime${iTime ?? ""}${bTime ?? ""}";
    return "${game.timeControl.timeStandard.standardName} + ${game.gameType.name.capitalize()}";
  }

  StageType getStageType() => switch (widget.game.gameState) {
        GameState.waitingForStart => StageType.BeforeStart,
        GameState.playing => StageType.Gameplay,
        GameState.scoreCalculation => StageType.ScoreCalculation,
        GameState.ended => StageType.GameEnd,
        GameState.paused => StageType.BeforeStart,
      };

  // Board
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => GameStateBloc(
              widget.game,
              widget.gameOracle,
              systemUtils,
            ),
        builder: (context, child) {
          return Scaffold(
            key: key,
            drawer: const MyAppDrawer(),
            appBar: MyAppBar(
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
            body: Consumer<GameStateBloc>(
              builder: (context, gameStateBloc, child) {
                final game = gameStateBloc.game;
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => GameBoardBloc(game),
                    )
                  ],
                  builder: (context, child) {
                    context.read<GameBoardBloc>().setupGame(game);
                    return Provider(
                      create: (context) => StoneLogic(game),
                      builder: (context, child) => ChangeNotifierProvider(
                        create: (context) {
                          return ScoreCalculationBloc(
                            api: context.read<AuthProvider>().api,
                            authBloc: context.read<AuthProvider>(),
                            gameStateBloc: context.read<GameStateBloc>(),
                            gameBoardBloc: context.read<GameBoardBloc>(),
                          );
                        },
                        builder: (context, child) {
                          // return ValueListenableBuilder<StageType>( valueListenable: context
                          //     .read<GameStateBloc>()!
                          //     .curStageTypeNotifier,
                          // builder: (context, stageType, idk) {
                          var stage = context
                              .read<GameStateBloc>()
                              .curStageType
                              .stageConstructor(
                                context,
                                context.read(),
                              );
                          return ChangeNotifierProvider<Stage>.value(
                            value: stage,
                            builder: (context, child) {
                              return Consumer<ScoreCalculationBloc>(
                                  builder: (context, dyn, child) =>
                                      WrapperGame(game));
                            },
                          );
                        },
                        // );
                        // },
                      ),
                    );
                  },
                );
              },
            ),
          );
        });
  }
}

class WrapperGame extends StatefulWidget {
  final Game game;

  const WrapperGame(this.game, {super.key});

  @override
  State<WrapperGame> createState() => _WrapperGameState();
}

class _WrapperGameState extends State<WrapperGame> {
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    context.read<Stage>().initializeWhenAllMiddlewareAvailable(context);
    return Container(
      //color: Colors.black,
      decoration: BoxDecoration(
          //image: DecorationImage(image: AssetImage(Constants.assets['table']!), fit: BoxFit.fitHeight, repeat: ImageRepeat.repeatY),
          ),
      child: GameUi(
        boardWidget: Board(
          widget.game.rows,
          widget.game.columns,
          widget.game.playgroundMap,
        ),
      ),
    );

    // return Stack(
    //   children: [
    //     Container(
    //       //color: Colors.black,
    //       decoration: BoxDecoration(
    //         color: Constants.defaultTheme.backgroundColor,
    //         //image: DecorationImage(image: AssetImage(Constants.assets['table']!), fit: BoxFit.fitHeight, repeat: ImageRepeat.repeatY),
    //       ),
    //     ),
    //     Stack(
    //       children: [
    //         Column(children: [
    //           Spacer(
    //             flex: 6,
    //           ),
    //           Expanded(
    //             flex: 18,
    //             child: ,
    //           ),
    //           Spacer(
    //             flex: 6,
    //           ),
    //         ]),
    //       ],
    //     ),
    //   ],
    // );
  }
}
