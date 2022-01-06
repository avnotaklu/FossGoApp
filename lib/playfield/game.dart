import 'dart:collection';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/utils/models.dart';
import 'package:go/ui/game_ui.dart';
import 'package:go/utils/position.dart';
import 'package:provider/provider.dart';
import 'dart:core';
import '../gameplay/logic.dart';

import '../utils/player.dart';
import 'board.dart';
import 'package:go/constants/constants.dart' as Constants;

class Game extends StatelessWidget {
  var players = List<Player>.filled(2, Player(Colors.black), growable: false);

  int playerTurn = 0;
  Board board;
  GameMatch match;

  Game(this.playerTurn, this.match) // Board
      : board = Board(match.rows as int, match.cols as int, match.playgroundMap as Map<Position?,Stone?>) {
    print('moves');
    match.moves?.forEach((element) {
      print(element.toString());
    });
    print('moves');
    players[0] = Player(Colors.black);
    players[1] = Player(Colors.white);
  }
  @override
  Widget build(BuildContext context) {
    // return StatefulBuilder(
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: const Text(Constants.title),
          actions: <Widget>[
            TextButton(onPressed: authBloc.logout, child: const Text("logout")),
          ],
        ),
        backgroundColor: Colors.green,
        body: GameData(
          match: match,
          pplayer: players,
          pturn: playerTurn,
          mChild: Column(children: [
            board,
            GameUi(),
          ]),
        ));
  }
}
