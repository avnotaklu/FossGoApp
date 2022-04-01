import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/models/game_match.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/utils/position.dart';
import 'package:go/utils/time_and_duration.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'dart:core';

import '../utils/player.dart';
import 'board.dart';
import 'package:go/constants/constants.dart' as Constants;

class Game extends StatelessWidget {
  var players = List<Player>.filled(2, Player(0, Colors.black), growable: false); // TODO this is early idk why i did this

  Stage curStage;
  Board board;
  GameMatch match;
  bool enteredAsGameCreator;

  Game(this.match, this.enteredAsGameCreator, this.curStage) // Board
      : board = Board(match.rows, match.cols, match.playgroundMap) {
    for (var element in match.moves) {
      print(element.toString());
    }
    players[0] = Player(0, Colors.black);
    players[1] = Player(1, Colors.white);
  }
  @override
  Widget build(BuildContext context) {
    // return StatefulBuilder(
    StreamController<bool> controller =
        StreamController<bool>.broadcast(); // TODO: improve this so that stream controller and stream itself are one part not seperate like this
    var authBloc = Provider.of<AuthBloc>(context, listen: false);

    Map<Position?, Stone?> finalPlaygroundMap = {};

    // TODO: this part was done in board but now because ui needs some info this is done here see `TODO: inherited_widget_restructure`
    for (var i = 0; i < match.rows; i++) {
      for (var j = 0; j < match.cols; j++) {
        // playgroundMap[Position(i, j)] = Player(Colors.black);
        var tmpPos = Position(i, j);
        if (match.playgroundMap.keys.contains(tmpPos)) {
          finalPlaygroundMap[Position(i, j)] = match.playgroundMap[tmpPos];
        } else {
          finalPlaygroundMap[Position(i, j)] = null;
        }
      }
    }

    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: kToolbarHeight / 2,
      //   actions: <Widget>[
      //     TextButton(onPressed: authBloc.logout, child: const Text("logout")),
      //   ],
      // ),
      backgroundColor: Colors.green,
      body: GameData(
        curStage: curStage,
        match: match,
        pplayer: players,
        mChild: StatefulBuilder(
          builder: (context, setState) {
            // TODO: make this so that below check isn't done and all of this functionality is in stages in this case gameplay_stage and game_end stage
            if (match.runStatus == true) {
              var checkGameStateStream = checkGameEnterable(context, match, controller).listen((event) {
                if (event == true) {
                  if (enteredAsGameCreator) {
                    // this sets time so only should be called by one player
                    var lastTimeAndDate;
                    NTP.now().then((value) {
                      match.startTime = value;
                      match.lastTimeAndDate.clear();
                      match.lastTimeAndDate.add(TimeAndDuration(match.startTime as DateTime, Duration(seconds: match.time)));
                      match.lastTimeAndDate.add(TimeAndDuration(match.startTime as DateTime, Duration(seconds: match.time)));
                      match.runStatus = true;

                      MultiplayerData.of(context)!
                          .curGameReferences!
                          .game
                          .set(match.toJson()); // TODO Instead of writing entire match again write only changed values
                      GameData.of(context)!.onGameStart(context);
                      setState(() => match = match);
                    });
                  } else {
                    // if game enterable start timer of black

                    MultiplayerData.of(context)?.curGameReferences?.startTime.onValue.listen((snaphot) {
                      match.startTime = DateTime.parse(snaphot.snapshot.value as String);
                      match.lastTimeAndDate.clear();
                      match.lastTimeAndDate.add(TimeAndDuration(match.startTime as DateTime, Duration(seconds: match.time)));
                      match.lastTimeAndDate.add(TimeAndDuration(match.startTime as DateTime, Duration(seconds: match.time)));
                      match.runStatus = true;

                      GameData.of(context)!.onGameStart(context);

                      setState(() => match = match);
                    });
                  }

                  // close controller once game is enterable
                  controller.close();
                }
              });
            } else if (match.runStatus == false) {
              GameData.of(context)?.timerController[0].pause();
              GameData.of(context)?.timerController[1].pause();
            }

            // TODO: inherited_widget_restructure :: both stonelogic and score calculation should not be this up in widget tree find a way to construct them in board and still access in game ui maybe with streams or something
            return StoneLogic(
              playgroundMap: finalPlaygroundMap,
              rows: match.rows,
              cols: match.cols,
              mChild: ScoreCalculation(
                match.rows,
                match.cols,
                mChild: ValueListenableBuilder<Stage>(
                  valueListenable: GameData.of(context)!.curStageNotifier,
                  builder: (context, stage, idk) => WrapperGame(match, finalPlaygroundMap),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class WrapperGame extends StatefulWidget {
  final match;
  final finalPlaygroundMap;

  WrapperGame(this.match, this.finalPlaygroundMap);

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
    GameData.of(context)!.cur_stage.initializeWhenAllMiddlewareAvailable(context);
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
              Expanded(flex: 18, child: Board(widget.match.rows, widget.match.cols, widget.finalPlaygroundMap)),
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
