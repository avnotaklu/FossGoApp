import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/multiplayer/models.dart';
import 'package:go/ui/game_ui.dart';
import 'dart:core';
import 'gameplay.dart';

import 'player.dart';
import 'board.dart';

class Game extends StatelessWidget {
  var players = List<Player>.filled(2, Player(Colors.black), growable: false);

  int playerTurn = 0;
  Board board;
  GameMatch match;
  User curUser;

  Game(this.playerTurn, this.match,this.curUser) // Board
      : board = Board(match.rows,match.cols,match.playgroundMap) {
    print('moves');
    match.moves.forEach((element) {print(element.toString());});
    print('moves');
    players[0] = Player(Colors.black);
    players[1] = Player(Colors.white);
  }
  @override
  Widget build(BuildContext context) {
    // return StatefulBuilder(
    return SizedBox(
        child: GameData(
          curUser: curUser,
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
