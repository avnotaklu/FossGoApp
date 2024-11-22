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
  // Board board;
  // Game game;
  bool enteredAsGameCreator;

  GameWidget(this.enteredAsGameCreator); // Board
  // : board = Board(game.rows, game.columns, game.playgroundMap)
  // {
  //   for (var element in game.moves) {
  //     print(element.toString());
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    // return StatefulBuilder(
    // StreamController<bool> controller = StreamController<
    //     bool>.broadcast(); // TODO: improve this so that stream controller and stream itself are one part not seperate like this
    // var authBloc = Provider.of<AuthProvider>(context, listen: false);

    // Map<Position?, StoneWidget?> finalPlaygroundMap = {};

    // TODO: this part was done in board but now because ui needs some info this is done here see `TODO: inherited_widget_restructure`
    // for (var i = 0; i < game.rows; i++) {
    //   for (var j = 0; j < game.columns; j++) {
    //     // playgroundMap[Position(i, j)] = Player(Colors.black);
    //     var tmpPos = Position(i, j);
    //     if (game.playgroundMap.keys.contains(tmpPos)) {
    //       finalPlaygroundMap[Position(i, j)] = game.playgroundMap[tmpPos];
    //     } else {
    //       finalPlaygroundMap[Position(i, j)] = null;
    //     }
    //   }
    // }

    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: kToolbarHeight / 2,
      //   actions: <Widget>[
      //     TextButton(onPressed: authBloc.logout, child: const Text("logout")),
      //   ],
      // ),
      backgroundColor: Colors.green,
      body:
          // GameData(
          //   curStage: curStage,
          //   match: game,
          //   pplayer: players,
          //   mChild:
          // StatefulBuilder(
          //   builder: (context, setState) {
          // TODO: make this so that below check isn't done and all of this functionality is in stages in this case gameplay_stage and game_end stage
          // if (game.runStatus == true) {
          //   var checkGameStateStream =
          //       checkGameEnterable(context, game, controller)
          //           .listen((event) {
          //     if (event == true) {
          //       if (enteredAsGameCreator) {
          //         // this sets time so only should be called by one player
          //         var lastTimeAndDate;
          //         NTP.now().then((value) {
          //           game.startTime = value;
          //           game.lastTimeAndDate.clear();
          //           game.lastTimeAndDate.add(TimeAndDuration(
          //               game.startTime as DateTime,
          //               Duration(seconds: game.time)));
          //           game.lastTimeAndDate.add(TimeAndDuration(
          //               game.startTime as DateTime,
          //               Duration(seconds: game.time)));
          //           game.runStatus = true;

          //           MultiplayerData.of(context)!.curGameReferences!.game.set(game
          //               .toJson()); // TODO Instead of writing entire match again write only changed values
          //           GameData.of(context)!.onGameStart(context);
          //           setState(() => game = game);
          //         });
          //       } else {
          //         // if game enterable start timer of black

          //         MultiplayerData.of(context)
          //             ?.curGameReferences
          //             ?.startTime
          //             .onValue
          //             .listen((snaphot) {
          //           game.startTime =
          //               DateTime.parse(snaphot.snapshot.value as String);
          //           game.lastTimeAndDate.clear();
          //           game.lastTimeAndDate.add(TimeAndDuration(
          //               game.startTime as DateTime,
          //               Duration(seconds: game.time)));
          //           game.lastTimeAndDate.add(TimeAndDuration(
          //               game.startTime as DateTime,
          //               Duration(seconds: game.time)));
          //           game.runStatus = true;

          //           GameData.of(context)!.onGameStart(context);

          //           setState(() => game = game);
          //         });
          //       }

          //       // close controller once game is enterable
          //       controller.close();
          //     }
          //   });
          // } else if (game.runStatus == false) {

          // }

          // GameData.of(context)?.timerController[0].pause();
          // GameData.of(context)?.timerController[1].pause();

          // TODO: inherited_widget_restructure :: both stonelogic and score calculation should not be this up in widget tree find a way to construct them in board and still access in game ui maybe with streams or something

          Consumer<GameStateBloc>(
        builder: (context, gameStateBloc, child) {
          final game = gameStateBloc.game;
          return MultiProvider(
            providers: [
              // ChangeNotifierProvider(
              //     create: (context) => GameStateBloc(
              //           context.read<SignalRBloc>(),
              //           context.read<AuthBloc>(),
              //           game,
              //         )),
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
