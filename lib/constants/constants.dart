import 'package:flutter/material.dart';
import 'package:go/models/position.dart';
import 'package:go/playfield/board.dart';

class BoardSize {
  final int rows;
  final int cols;

  const BoardSize(this.rows, this.cols);

  @override
  String toString() {
    return "${rows}x$cols";
  }
}

const String title = "Go";
// const List<String> boardsizes = ["9x9", "13x13", "19x19"];
// const List<(int rows, int cols)> boardsizes = [(9, 9), (13, 13), (19, 19)];

const List<BoardSize> boardSizes = [
  BoardSize(9, 9),
  BoardSize(13, 13),
  BoardSize(19, 19),
];

enum TimeFormat {
  suddenDeath("Sudden Death"),
  fischer("Fischer"),
  byoYomi("Byo-Yomi");

  final String formatName;

  const TimeFormat(this.formatName);
}

// const List<String> timeFormats = [
//   "Byo-Yomi",
//   "Fischer",
//   "Sudden Death",
// ];

enum TimeStandard {
  blitz("Blitz"),
  rapid("Rapid"),
  classical("Classical");

  final String standardName;

  const TimeStandard(this.standardName);
}

const Map<TimeStandard, int> timeStandardMainTime = {
  TimeStandard.blitz: 300,
  TimeStandard.rapid: 1200,
  TimeStandard.classical: 3600,
};

final Map<TimeStandard, List<int>> timeStandardMainTimeAlt = {
  TimeStandard.blitz: [
    timeStandardMainTime[TimeStandard.blitz]!,
  ],
  TimeStandard.rapid: [
    timeStandardMainTime[TimeStandard.rapid]!,
  ],
  TimeStandard.classical: [
    timeStandardMainTime[TimeStandard.classical]!,
  ],
};

const Map<TimeStandard, int> timeStandardIncrement = {
  TimeStandard.blitz: 2,
  TimeStandard.rapid: 5,
  TimeStandard.classical: 10,
};

final Map<TimeStandard, List<int>> timeStandardIncrementAlt = {
  TimeStandard.blitz: [
    timeStandardIncrement[TimeStandard.blitz]!,
  ],
  TimeStandard.rapid: [
    timeStandardIncrement[TimeStandard.rapid]!,
  ],
  TimeStandard.classical: [
    timeStandardIncrement[TimeStandard.classical]!,
  ],
};

const Map<TimeStandard, int> timeStandardByoYomiTime = {
  TimeStandard.blitz: 10,
  TimeStandard.rapid: 30,
  TimeStandard.classical: 60,
};

final Map<TimeStandard, List<int>> timeStandardByoYomiTimeAlt = {
  TimeStandard.blitz: [
    timeStandardByoYomiTime[TimeStandard.blitz]!,
  ],
  TimeStandard.rapid: [
    timeStandardByoYomiTime[TimeStandard.rapid]!,
  ],
  TimeStandard.classical: [
    timeStandardByoYomiTime[TimeStandard.classical]!,
  ],
};

const List<Color> playerColors = [(Colors.black), (Colors.white)];

const Map<String, String> assets = {
  "board": "assets/images/board_light_free.jpg", //
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

VisualTheme defaultTheme = VisualTheme(
  backgroundColor: Colors.grey.shade800,
  mainTextColor: Colors.white60,
  secondaryTextColor: Colors.white,
  mainHighlightColor: Colors.blueGrey,
  disabledColor: Colors.grey.shade400,
  enabledColor: Colors.amber,
);

class VisualTheme {
  final Color backgroundColor;
  final Color mainTextColor;
  final Color secondaryTextColor;
  final Color mainHighlightColor;
  final Color disabledColor;
  final Color enabledColor;

  const VisualTheme(
      {required this.backgroundColor,
      required this.mainTextColor,
      required this.secondaryTextColor,
      required this.mainHighlightColor,
      required this.disabledColor,
      required this.enabledColor});
}
