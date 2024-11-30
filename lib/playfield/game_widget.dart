import 'dart:async';
import 'dart:collection';
import 'dart:math';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/utils/string_formatting.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/stone_representation.dart';
import 'package:go/models/time_control.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/game_board_bloc.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/game.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:go/views/my_app_bar.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'dart:core';

import '../utils/player.dart';
import 'board.dart';
import 'package:go/constants/constants.dart' as Constants;

class GameWidget extends StatelessWidget {
  final bool enteredAsGameCreator;

  String? byoYomiTime(TimeControl time) {
    return time.byoYomiTime != null
        ? "${time.byoYomiTime!.byoYomis} x ${time.byoYomiTime!.byoYomiSeconds}s"
        : null;
  }

  String? mainTime(TimeControl time) {
    return Duration(seconds: time.mainTimeSeconds).durationRepr();
  }

  String? incrementTime(TimeControl time) {
    if (time.incrementSeconds == null) return null;
    return Duration(seconds: time.incrementSeconds!).durationRepr();
  }

  String gameTitle(TimeControl time) {
    final mTime = mainTime(time);
    final iTime = incrementTime(time);
    final bTime = byoYomiTime(time);

    return "$mTime${iTime ?? ""}${bTime ?? ""}";
  }

  const GameWidget(this.enteredAsGameCreator, {super.key}); // Board
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        gameTitle(context.read<GameStateBloc>().game.timeControl),
        leading: Icon(Icons.menu),
      ),
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
    return Container(
      //color: Colors.black,
      decoration: BoxDecoration(
        color: Constants.defaultTheme.backgroundColor,
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
