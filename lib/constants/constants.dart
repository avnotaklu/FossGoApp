import 'package:flutter/material.dart';
import 'package:go/models/position.dart';
import 'package:go/models/time_control.dart';
import 'package:go/services/time_control_dto.dart';
import 'package:go/services/user_rating.dart';

class BoardSizeData {
  final int rows;
  final int cols;

  BoardSize get boardSize {
    if (rows == 9 && cols == 9) {
      return BoardSize.nine;
    } else if (rows == 13 && cols == 13) {
      return BoardSize.thirteen;
    } else if (rows == 19 && cols == 19) {
      return BoardSize.nineteen;
    } else {
      return BoardSize.other;
    }
  }

  const BoardSizeData(this.rows, this.cols);

  @override
  String toString() {
    return "${rows}x$cols";
  }
}

const String title = "Go";
// const List<String> boardsizes = ["9x9", "13x13", "19x19"];
// const List<(int rows, int cols)> boardsizes = [(9, 9), (13, 13), (19, 19)];

extension BoardSizeDataExt on BoardSize {
  RateableBoardSize? get rateable => switch (this) {
        BoardSize.nine => RateableBoardSize.nine,
        BoardSize.thirteen => RateableBoardSize.thirteen,
        BoardSize.nineteen => RateableBoardSize.nineteen,
        BoardSize.other => null
      };
}

enum BoardSize {
  nine,
  thirteen,
  nineteen,
  other,
}

const List<BoardSizeData> boardSizes = [
  BoardSizeData(9, 9),
  BoardSizeData(13, 13),
  BoardSizeData(19, 19),
];

enum TimeFormat {
  suddenDeath("Sudden Death"),
  fischer("Fischer"),
  byoYomi("Byo-Yomi");

  final String formatName;

  const TimeFormat(this.formatName);
}

final List<TimeControlDto> timeControlsForMatch = [
  // TimeStandard.blitz
  TimeControlDto(
    mainTimeSeconds: 30,
    incrementSeconds: 3,
    byoYomiTime: null,
  ),
  TimeControlDto(
      mainTimeSeconds: 30,
      incrementSeconds: null,
      byoYomiTime: ByoYomiTime(byoYomis: 5, byoYomiSeconds: 10)),
  // TimeStandard.rapid
  TimeControlDto(
    mainTimeSeconds: 5 * 60,
    incrementSeconds: 5,
    byoYomiTime: null,
  ),
  TimeControlDto(
      mainTimeSeconds: 5 * 60,
      incrementSeconds: null,
      byoYomiTime: ByoYomiTime(byoYomis: 5, byoYomiSeconds: 30)),

  TimeControlDto(
    mainTimeSeconds: 10 * 60,
    incrementSeconds: 10,
    byoYomiTime: null,
  ),
  TimeControlDto(
      mainTimeSeconds: 20 * 60,
      incrementSeconds: null,
      byoYomiTime: ByoYomiTime(byoYomis: 5, byoYomiSeconds: 30)),
];

const Map<TimeStandard, Duration> timeStandardMainTime = {
  TimeStandard.blitz: Duration(seconds: 300),
  TimeStandard.rapid: Duration(seconds: 1200),
  TimeStandard.classical: Duration(seconds: 3600),
  TimeStandard.correspondence: Duration(days: 1),
};

final Map<TimeStandard, List<Duration>> timeStandardMainTimeAlt = {
  TimeStandard.blitz: [
    const Duration(seconds: 180),
    timeStandardMainTime[TimeStandard.blitz]!,
  ],
  TimeStandard.rapid: [
    timeStandardMainTime[TimeStandard.rapid]!,
  ],
  TimeStandard.classical: [
    timeStandardMainTime[TimeStandard.classical]!,
  ],
  TimeStandard.correspondence: [
    timeStandardMainTime[TimeStandard.correspondence]!,
  ],
};

const Map<TimeStandard, Duration> timeStandardIncrement = {
  TimeStandard.blitz: Duration(seconds: 2),
  TimeStandard.rapid: Duration(seconds: 5),
  TimeStandard.classical: Duration(seconds: 10),
  TimeStandard.correspondence: Duration(hours: 1)
};

final Map<TimeStandard, List<Duration>> timeStandardIncrementAlt = {
  TimeStandard.blitz: [
    timeStandardIncrement[TimeStandard.blitz]!,
  ],
  TimeStandard.rapid: [
    timeStandardIncrement[TimeStandard.rapid]!,
  ],
  TimeStandard.classical: [
    timeStandardIncrement[TimeStandard.classical]!,
  ],
  TimeStandard.correspondence: [
    timeStandardIncrement[TimeStandard.correspondence]!,
  ],
};

const Map<TimeStandard, Duration> timeStandardByoYomiTime = {
  TimeStandard.blitz: Duration(seconds: 10),
  TimeStandard.rapid: Duration(seconds: 30),
  TimeStandard.classical: Duration(seconds: 60),
  TimeStandard.correspondence: Duration(minutes: 5)
};

final Map<TimeStandard, List<Duration>> timeStandardByoYomiTimeAlt = {
  TimeStandard.blitz: [
    timeStandardByoYomiTime[TimeStandard.blitz]!,
  ],
  TimeStandard.rapid: [
    timeStandardByoYomiTime[TimeStandard.rapid]!,
  ],
  TimeStandard.classical: [
    timeStandardByoYomiTime[TimeStandard.classical]!,
  ],
  TimeStandard.correspondence: [
    timeStandardByoYomiTime[TimeStandard.correspondence]!,
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
