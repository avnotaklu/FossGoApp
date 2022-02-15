import 'package:flutter/material.dart';
import 'package:go/utils/player.dart';
import 'package:go/utils/position.dart';

import '';

const String title = "Go";
const List<String> boardsizes = ["9x9", "13x13", "19x19"];
const List<Color> playerColors = [(Colors.black), (Colors.white)];

const Map<String, String> assets = {
  "board": "assets/images/board.jpg", //
  "table": "assets/images/table.jpg" //
};

const Map<String, List<Position>> boardCircleDecoration = {
  "9x9": [
    //
    Position(2, 2), Position(2, 4), Position(2, 6), //
    Position(4, 2), Position(4, 4), Position(4, 6), //
    Position(6, 2), Position(6, 4), Position(6, 6), //
  ],
  "13x13": [
    //
    Position(3, 3), Position(3, 6), Position(3, 9), //
    Position(6, 3), Position(6, 6), Position(6, 9), //
    Position(9, 3), Position(9, 6), Position(9, 9), //
  ],
  "19x19": [
    //
    Position(3, 3), Position(3, 9), Position(3, 15), //
    Position(9, 3), Position(9, 9), Position(9, 15), //
    Position(15, 3), Position(15, 9), Position(15, 15), //
  ]
};

// class BoardCircleDecorations {
//   static const val;
//   const BoardCircleDecorations{
//     return const ;
//     // return Map<String, List<Position>>.fromIterable(boardsizes.map((element) {
//     //   return MapEntry(element, Position(0, 0));
//     // }));
//   }
// }
