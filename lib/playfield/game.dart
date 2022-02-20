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
        StreamController<bool>.broadcast(); // TODO improve this so that stream controller and stream itself are one part not seperate like this
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
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
            var checkGameStateStream = checkGameEnterable(context, match, controller).listen((event) {
              if (event == true) {
                if (enteredAsGameCreator) {
                  // this sets time so only should be called by one player
                  var lastTimeAndDate;
                  NTP.now().then((value) => {
                        match.startTime = value,
                        match.lastTimeAndDate.clear(),
                        match.lastTimeAndDate.add(TimeAndDuration(match.startTime as DateTime, Duration(seconds: match.time))),
                        match.lastTimeAndDate.add(TimeAndDuration(match.startTime as DateTime, Duration(seconds: match.time))),
                        match.runStatus = true,

                        MultiplayerData.of(context)!
                            .curGameReferences!
                            .game
                            .set(match.toJson()), // TODO Instead of writing entire match again write only changed values
                        GameData.of(context)!.onGameStart(context),
                        setState(() => match = match),
                      });
                }

                // if game enterable start timer of black

                if (GameData.of(context)!.match.startTime == null) {
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
            return Stack(
              children: [
                Container(
                  //color: Colors.black,
                  decoration: BoxDecoration(
                    color: Constants.defaultTheme.backgroundColor,
                    //image: DecorationImage(image: AssetImage(Constants.assets['table']!), fit: BoxFit.fitHeight, repeat: ImageRepeat.repeatY),
                  ),
                ),
                Column(children: [
                  Expanded(flex: 18, child: Board(match.rows, match.cols, match.playgroundMap)),
                  Spacer(),
                  Expanded(flex: 12, child: GameUi()),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}
