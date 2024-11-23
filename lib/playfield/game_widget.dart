import 'dart:async';
import 'dart:collection';
import 'dart:math';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/stone_representation.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/game_board_bloc.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/game.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'dart:core';

import '../utils/player.dart';
import 'board.dart';
import 'package:go/constants/constants.dart' as Constants;

class GameWidget extends StatelessWidget {
  final bool enteredAsGameCreator;

  const GameWidget(this.enteredAsGameCreator, {super.key}); // Board
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Consumer<GameStateBloc>(
        builder: (context, gameStateBloc, child) {
          final game = gameStateBloc.game;
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (context) => GameBoardBloc(context.read()))
            ],
            builder: (context, child) {
              context.read<GameBoardBloc>().setupGame(game);
              return Provider(
                create: (context) => StoneLogic(
                  rows: game.rows,
                  cols: game.columns,
                  gameStateBloc: context.read<GameStateBloc>(),
                  gameBoardBloc: context.read<GameBoardBloc>(),
                ),
                builder: (context, child) => ChangeNotifierProvider(
                  create: (context) {
                    return ScoreCalculationBloc(
                      api: context.read<AuthProvider>().api,
                      authBloc: context.read<AuthProvider>(),
                      gameStateBloc: context.read<GameStateBloc>(),
                      gameBoardBloc: context.read<GameBoardBloc>(),
                    );
                  },
                  builder: (context, child) =>
                      ValueListenableBuilder<StageType>(
                    valueListenable:
                        context.read<GameStateBloc>()!.curStageTypeNotifier,
                    builder: (context, stageType, idk) {
                      var stage = stageType.stageConstructor(
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class WrapperGame extends StatefulWidget {
  final Game game;

  WrapperGame(this.game);

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
    return Stack(
      children: [
        Container(
          //color: Colors.black,
          decoration: BoxDecoration(
            color: Constants.defaultTheme.backgroundColor,
            //image: DecorationImage(image: AssetImage(Constants.assets['table']!), fit: BoxFit.fitHeight, repeat: ImageRepeat.repeatY),
          ),
        ),
        Stack(
          children: [
            Column(children: [
              Spacer(
                flex: 6,
              ),
              Expanded(
                flex: 18,
                child: Board(
                  widget.game.rows,
                  widget.game.columns,
                  widget.game.playgroundMap,
                ),
              ),
              Spacer(
                flex: 6,
              ),
            ]),
            GameUi(),
          ],
        ),
      ],
    );
  }
}
