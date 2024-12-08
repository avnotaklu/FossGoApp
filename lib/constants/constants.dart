// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:go/models/position.dart';
import 'package:go/models/time_control.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/services/time_control_dto.dart';

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

ThemeData get lightTheme {
  var tc = defaultTheme.mainLightTextColor;
  return ThemeData.light().copyWith(
    cardColor: defaultTheme.lightCardColor,
    indicatorColor: defaultTheme.enabledColor,
    disabledColor: defaultTheme.darkCardColor,
    shadowColor: defaultTheme.lightShadow,
    // elevatedButtonTheme: ElevatedButtonThemeData(
    //   style: ButtonStyle(
    //     backgroundColor:
    //         WidgetStateProperty.all<Color>(defaultTheme.focusColor),
    //   ),
    // ),
    textTheme: buildTextTheme(tc),
  );
}

ThemeData get darkTheme {
  var tc = defaultTheme.mainDarkTextColor;

  return ThemeData.dark().copyWith(
    cardColor: defaultTheme.darkCardColor,
    indicatorColor: defaultTheme.enabledColor,
    disabledColor: defaultTheme.lightCardColor,

    // elevatedButtonTheme: ElevatedButtonThemeData(
    //   style: ButtonStyle(
    //     backgroundColor:
    //         WidgetStateProperty.all<Color>(defaultTheme.focusColor),
    //   ),
    // ),
    // shadow color is default

    textTheme: buildTextTheme(tc),
  );
}

TextTheme buildTextTheme(Color tc) {
  return TextTheme(
    headlineSmall: headingS(tc),
    titleLarge: titleL(tc),
    bodyLarge: bodyL(tc),
    bodySmall: bodyS(tc),
    labelLarge: lableL(tc),
    labelSmall: lableS(tc),
  );
}

TextStyle headingS(Color col) {
  return TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle titleL(Color col) {
  return TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle bodyL(Color col) {
  return TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle bodyS(Color col) {
  return TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle lableL(Color col) {
  return TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle lableS(Color col) {
  return TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

VisualTheme defaultTheme = VisualTheme(
  backgroundColor: Colors.grey.shade800,
  mainHighlightColor: Colors.blueGrey,
  // disabledColor: Colors.grey.shade400,
  // enabledColor: Colors.amber,

// #003049, #d62828, #f77f00, #fcbf49, #eae2b7
  // color1: const Color(0xFF003049),
  // color2: const Color(0xFFd62828),
  // color3: const Color(0xFFf77f00),
  // color4: const Color(0xFFfcbf49),
  // color5: const Color(0xFFeae2b7),

// #D3CAE2 #E6C17A, #F6EDE3, #404041
  // color1: const Color(0xFFD3CAE2),
  // color2: const Color(0xFFE6C17A),
  // color3: const Color(0xFFF6EDE3),
  // color4: const Color(0xFF404041),
  // color5: const Color(0xFFf77f00),

// #cfdbd5, #e8eddf, #f5cb5c, #242423, #333533
  // color1: const Color(0xFFcfdbd5),
  // color2: const Color(0xFFe8eddf),
  // color3: const Color(0xFFf5cb5c),
  // color4: const Color(0xFF242423),
  // color5: const Color(0xFF333533),

  // #eae8ff, #adacb5, #f5cb5c, #2d3142, #071013

  color1: const Color(0xFFeae8ff),
  color2: const Color(0xFFadacb5),
  color3: const Color(0xFFf5cb5c),
  color4: const Color(0xFF2d3142),
  color5: const Color(0xFF071013),

  // #dce1e9, #fef7ff, #f5cf66, #0a0212, #141414

  // color1: const Color(0xFFFCF8F5),
  // color2: const Color(0xFFfef7ff),
  // color3: const Color(0xFFf5cf66),
  // color4: const Color(0xFF0A0A0A),
  // color5: const Color(0xFF141414),
);

class VisualTheme {
  final Color backgroundColor;
  final Color mainHighlightColor;

  // Color get disabledColor => color2;
  // Color get enabledColor => color3;

  // Color get darkCardColor => color5;
  // Color get lightCardColor => color2;
  Color get focusColor => color3;

  Color get disabledColor => color1;
  Color get enabledColor => color3;

  // Color get darkCardColor => color4;
  Color get darkCardColor => Color(0xFF1C1C22);
  // Color get darkCardColor => Color(0xFF363636);
  Color get lightCardColor => color1;

  // Color get mainTextColor => color5;
  // Color get secondaryTextColor => color5;

  Color get mainDarkTextColor => Colors.white;
  Color get mainLightTextColor => Colors.grey.shade800;

  Color invertedTextColor(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? mainLightTextColor
        : mainDarkTextColor;
  }

  // Color get secDarkTextColor => color5;
  // Color get secLightTextColor => color5;

  // Color get darkShadow => Colors.grey.shade600.withOpacity(0.2);
  Color get lightShadow => Colors.blueGrey.shade100;

  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final Color color5;

  VisualTheme({
    required this.backgroundColor,
    required this.mainHighlightColor,
    // required this.disabledColor,
    // required this.enabledColor,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.color4,
    required this.color5,
  });
}

class Validations {
  static String? validateEmail(String email) {
    final RegExp emailRegex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return !emailRegex.hasMatch(email) ? "Email is not valid" : null;
  }

  static String? validateUsernameCharacters(String username) {
    final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return !usernameRegex.hasMatch(username)
        ? "Please enter letters, numbers or underscores only for username"
        : null;
  }

  static String? validateUsernameFirst(String username) {
    final RegExp usernameRegex = RegExp(r'^[a-zA-Z].*$');
    return !usernameRegex.hasMatch(username)
        ? "Username must start with a letter"
        : null;
  }

  static bool validatePassword(String password) {
    return password.length >= 6;
  }
}


// Some theme ideas
// 