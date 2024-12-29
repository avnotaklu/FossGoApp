// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/foundation/duration.dart';

import 'package:go/models/position.dart';
import 'package:go/models/time_control.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/services/time_control_dto.dart';
import 'package:google_fonts/google_fonts.dart';

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
  TimeControlDto(
    mainTimeSeconds: 30,
    incrementSeconds: 3,
    byoYomiTime: null,
  ),
  TimeControlDto(
      mainTimeSeconds: 30,
      incrementSeconds: null,
      byoYomiTime: ByoYomiTime(byoYomis: 5, byoYomiSeconds: 10)),
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

const Map<TimeStandard, (Duration, Duration, Duration)> timeStandardMainTime = {
  TimeStandard.blitz: (
    Duration(seconds: 30),
    Duration(seconds: 5 * 60),
    Duration(seconds: 30)
  ),
  TimeStandard.rapid: (
    Duration(minutes: 5),
    Duration(minutes: 20),
    Duration(minutes: 1)
  ),
  TimeStandard.classical: (
    Duration(minutes: 20),
    Duration(minutes: 120),
    Duration(minutes: 5)
  ),
  TimeStandard.correspondence: (
    Duration(days: 14),
    Duration(days: 28),
    Duration(days: 1)
  ),
};

List<Duration> timeStandardMainTimesCons(TimeStandard s) {
  return List.generate(
    (timeStandardMainTime[s]!.$2 - timeStandardMainTime[s]!.$1)
            .dividedBy(timeStandardMainTime[s]!.$3) +
        1,
    (i) =>
        timeStandardMainTime[s]!.$1 +
        Duration(seconds: i * timeStandardMainTime[s]!.$3.inSeconds),
  );
}

// final Map<TimeStandard, List<Duration>> timeStandardMainTimeAlt = {
//   TimeStandard.blitz: [
//     const Duration(seconds: 180),
//     timeStandardMainTime[TimeStandard.blitz]!,
//   ],
//   TimeStandard.rapid: [
//     timeStandardMainTime[TimeStandard.rapid]!,
//   ],
//   TimeStandard.classical: [
//     timeStandardMainTime[TimeStandard.classical]!,
//   ],
//   TimeStandard.correspondence: [
//     timeStandardMainTime[TimeStandard.correspondence]!,
//   ],
// };

const Map<TimeStandard, (Duration, Duration, Duration)> timeStandardIncrement =
    {
  TimeStandard.blitz: (
    Duration(seconds: 2),
    Duration(seconds: 10),
    Duration(seconds: 2)
  ),
  TimeStandard.rapid: (
    Duration(seconds: 10),
    Duration(seconds: 30),
    Duration(seconds: 5)
  ),
  TimeStandard.classical: (
    Duration(seconds: 30),
    Duration(seconds: 3 * 60),
    Duration(seconds: 30)
  ),
  TimeStandard.correspondence: (
    Duration(days: 1),
    Duration(days: 4),
    Duration(days: 1)
  ),
};

List<Duration> timeStandardIncrementCons(TimeStandard s) {
  return List.generate(
    (timeStandardIncrement[s]!.$2 - timeStandardIncrement[s]!.$1)
            .dividedBy(timeStandardIncrement[s]!.$3) +
        1,
    (i) =>
        timeStandardIncrement[s]!.$1 +
        Duration(seconds: i * timeStandardIncrement[s]!.$3.inSeconds),
  );
}

// final Map<TimeStandard, List<Duration>> timeStandardIncrementAlt = {
//   TimeStandard.blitz: [
//     timeStandardIncrement[TimeStandard.blitz]!,
//   ],
//   TimeStandard.rapid: [
//     timeStandardIncrement[TimeStandard.rapid]!,
//   ],
//   TimeStandard.classical: [
//     timeStandardIncrement[TimeStandard.classical]!,
//   ],
//   TimeStandard.correspondence: [
//     timeStandardIncrement[TimeStandard.correspondence]!,
//   ],
// };

const Map<TimeStandard, (Duration, Duration, Duration)>
    timeStandardByoYomiTime = {
  TimeStandard.blitz: (
    Duration(seconds: 10),
    Duration(seconds: 30),
    Duration(seconds: 5)
  ),
  TimeStandard.rapid: (
    Duration(seconds: 30),
    Duration(seconds: 60),
    Duration(seconds: 10)
  ),
  TimeStandard.classical: (
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 1)
  ),
  TimeStandard.correspondence: (
    Duration(days: 1),
    Duration(days: 4),
    Duration(days: 1)
  ),
};

List<Duration> timeStandardByoYomiTimesCons(TimeStandard s) {
  return List.generate(
    (timeStandardByoYomiTime[s]!.$2 - timeStandardByoYomiTime[s]!.$1)
            .dividedBy(timeStandardByoYomiTime[s]!.$3) +
        1,
    (i) =>
        timeStandardByoYomiTime[s]!.$1 +
        Duration(seconds: i * timeStandardByoYomiTime[s]!.$3.inSeconds),
  );
}

// final Map<TimeStandard, List<Duration>> timeStandardByoYomiTimeAlt = {
//   TimeStandard.blitz: [
//     timeStandardByoYomiTime[TimeStandard.blitz]!,
//   ],
//   TimeStandard.rapid: [
//     timeStandardByoYomiTime[TimeStandard.rapid]!,
//   ],
//   TimeStandard.classical: [
//     timeStandardByoYomiTime[TimeStandard.classical]!,
//   ],
//   TimeStandard.correspondence: [
//     timeStandardByoYomiTime[TimeStandard.correspondence]!,
//   ],
// };

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

ThemeData get oldLightTheme {
  var tc = defaultTheme.mainLightTextColor;
  return ThemeData.light().copyWith(
    cardColor: defaultTheme.lightCardColor,
    indicatorColor: defaultTheme.enabledColor,
    disabledColor: defaultTheme.darkCardColor,
    hintColor: defaultTheme.darkCardColor,
    shadowColor: defaultTheme.lightShadow,
    dialogBackgroundColor: defaultTheme.lightDialogColor,
    textTheme: buildTextTheme(tc),
  );
}

ThemeData buildTheme({
  required Color tc,
  required Color tci,
  required Color bg,
  required Color card,
  required Color cardi,
  required Color shadow,
  required Color dialog,
  required Color dialogi,
  required Color highlight,
  required Brightness b,
}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
        brightness: b,
        primary: card,
        onPrimary: cardi,
        secondary: highlight,
        onSecondary: Colors.black,
        secondaryContainer: highlight,
        onSecondaryContainer: Colors.black,
        tertiary: cardi,
        onTertiary: card,
        surfaceContainerHigh: dialog, // Users: Dialog
        surfaceContainer: dialog, // Users: Navigation bar
        surfaceContainerLow: card, // Users: Card, Button

        onSurfaceVariant: cardi,
        surfaceContainerHighest: highlight,
        surfaceVariant: cardi, // REVIEW: M3 Spec defines it, so i'm using it

        error: Colors.red,
        onError: Colors.white,
        outlineVariant: dialogi,
        surface: bg,
        onSurface: tc,
        onInverseSurface: tci,
        shadow: shadow),
    cardTheme: null,
    textTheme: buildTextTheme(tc),
  );
}

final Color magnolia = Color(0xffF8F1F6);
final Color lavender = Color(0xFFeae8ff);

ThemeData get darkTheme => buildTheme(
      tc: defaultTheme.mainDarkTextColor,
      tci: defaultTheme.mainLightTextColor,
      bg: Color(0xff111118),
      card: defaultTheme.darkCardColor,
      cardi: defaultTheme.lightCardColor,
      shadow: defaultTheme.darkShadow,
      dialog: defaultTheme.darkDialogColor,
      dialogi: defaultTheme.lightDialogColor,
      highlight: defaultTheme.mainHighlightColor,
      b: Brightness.dark,
    );

ThemeData get lightTheme => buildTheme(
      tc: defaultTheme.mainLightTextColor,
      tci: defaultTheme.mainDarkTextColor,
      bg: Colors.white,
      card: defaultTheme.lightCardColor,
      cardi: defaultTheme.darkCardColor,
      shadow: defaultTheme.lightShadow,
      dialog: defaultTheme.lightDialogColor,
      dialogi: defaultTheme.darkDialogColor,
      highlight: defaultTheme.mainHighlightColor,
      b: Brightness.light,
    );

ThemeData get oldDarkTheme {
  var tc = defaultTheme.mainDarkTextColor;

  var bg = Color(0xff111118);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,

      primary: defaultTheme.darkCardColor,
      onPrimary: defaultTheme.lightCardColor,

      secondary: defaultTheme.mainHighlightColor,
      onSecondary: tc,

      tertiary: defaultTheme.lightCardColor,
      onTertiary: defaultTheme.darkCardColor,

      surfaceContainerHigh: defaultTheme.darkDialogColor,
      surfaceContainer: defaultTheme.darkDialogColor,
      surfaceContainerLow: defaultTheme.darkCardColor,

      onSurfaceVariant: defaultTheme.lightCardColor,
      surfaceContainerHighest: defaultTheme.mainHighlightColor,
      // ignore: deprecated_member_use // REVIEW: M3 Spec defines it, so i'm using it
      surfaceVariant: defaultTheme.lightCardColor,

      error: Colors.red,
      onError: Colors.white,

      surface: bg,

      onSurface: defaultTheme.mainDarkTextColor,
      onInverseSurface: defaultTheme.mainLightTextColor,
    ),
    cardTheme: null,
    textTheme: buildTextTheme(tc),
  );
}

const otherColors = OtherColors(
  win: Colors.green,
  loss: Colors.red,
);

class OtherColors {
  final Color win;
  final Color loss;

  const OtherColors({
    required this.win,
    required this.loss,
  });
}

TextTheme buildTextTheme(Color tc) {
  return TextTheme(
    headlineLarge:
        headingL(tc).copyWith(fontFamily: GoogleFonts.poppins().fontFamily),
    headlineSmall:
        headingS(tc).copyWith(fontFamily: GoogleFonts.poppins().fontFamily),
    titleLarge:
        titleL(tc).copyWith(fontFamily: GoogleFonts.poppins().fontFamily),
    bodyLarge: bodyL(tc).copyWith(fontFamily: GoogleFonts.poppins().fontFamily),
    bodySmall: bodyS(tc).copyWith(fontFamily: GoogleFonts.poppins().fontFamily),
    labelLarge:
        lableL(tc).copyWith(fontFamily: GoogleFonts.poppins().fontFamily),
    labelSmall:
        lableS(tc).copyWith(fontFamily: GoogleFonts.poppins().fontFamily),
  );
}

TextStyle headingL(Color col) {
  return TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle headingS(Color col) {
  return TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle titleL(Color col) {
  return TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle bodyL(Color col) {
  return TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle bodyS(Color col) {
  return TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle lableL(Color col) {
  return TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

TextStyle lableS(Color col) {
  return TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: col,
  );
}

VisualTheme defaultTheme = VisualTheme(
  // backgroundColor: Colors.grey.shade800,
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

  // magnolia =>
  color1: const Color(0xFFeae8ff),
  // color1: magnolia,
  color2: const Color(0xFFDAD6FF),
  // color2: const Color(0xFFEDEBFF),

  color3: const Color(0xFFf5cb5c),
  // color4: const Color(0xFF2d3142),
  // color5: const Color(0xFF071013),

  // #dce1e9, #fef7ff, #f5cf66, #0a0212, #141414

  // color1: const Color(0xFFFCF8F5),
  // color2: const Color(0xFFfef7ff),
  // color3: const Color(0xFFf5cf66),
  // color4: const Color(0xFF0A0A0A),
  // color5: const Color(0xFF141414),

  // color5: Color(0xFF2E2E38), // color4: Color(0xFF282739),

  color5: Color(0xFF424261),
  // color5: Color(0xFF1C1C22),
  color4: Color(0xFF282739),
  // #
);

class VisualTheme {
  // final Color backgroundColor;
  Color get mainHighlightColor => color3;

  // Color get disabledColor => color2;
  // Color get enabledColor => color3;

  // Color get darkCardColor => color5;
  // Color get lightCardColor => color2;

  Color get darkBackground => Color(0xff111118);

  Color get seedColor => color2;
  Color get focusColor => color3;

  Color get disabledColor => color1;
  Color get enabledColor => color3;

  Color get darkCardColor => color5;
  // Color get darkCardColor => Color(0xFF1C1C22);
  // Color get darkCardColor => Color(0xFF363636);
  Color get lightCardColor => color1;

  Color get darkDialogColor => color4;
  // Color get darkCardColor => Color(0xFF1C1C22);
  // Color get darkCardColor => Color(0xFF363636);
  Color get lightDialogColor => color2;

  // Color get mainTextColor => color5;
  // Color get secondaryTextColor => color5;

  Color get mainDarkTextColor => Colors.white.withOpacity(0.9);
  Color get mainLightTextColor => Colors.grey.shade800;

  Color invertedTextColor(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? mainLightTextColor
        : mainDarkTextColor;
  }

  // Color get secDarkTextColor => color5;
  // Color get secLightTextColor => color5;

  Color get darkShadow => Colors.grey.shade700.withOpacity(0.9);
  Color get lightShadow => Colors.grey.shade700.withOpacity(0.3);
  // Color get darkShadow => Colors.blueGrey.shade100;
  // Color get lightShadow => Colors.blueGrey.shade700.withOpacity(0.3);
  // Color get lightShadow => Colors.blueGrey.shade100;

  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final Color color5;

  VisualTheme({
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

  static String? validatePassword(String password) {
    return password.length < 6
        ? "Password must be not be smaller than 6 characters"
        : null;
  }

  static String? validateFullName(String fullName) {
    final RegExp fullNameRegex = RegExp(
      r"^[\p{Letter}\p{Mark} .'-]+$",
      unicode: true,
    );
    // final RegExp fullNameRegex = RegExp(r"\p{Letter}");

    return !fullNameRegex.hasMatch(fullName)
        ? "Please enter a valid name"
        : null;
  }

  static String? validateBio(String bio) {
    return bio.length > 100 || bio.length < 10
        ? "Please enter a valid bio"
        : null;
  }

  static String? validateNationalityLength(String nat) {
    return nat.length != 2 ? "Nationality must be 2 characters long" : null;
  }

  static String? validateNationalityFormat(String nat) {
    final RegExp reg = RegExp(
      r"^[A-Z][A-Z]$",
    );
    // final RegExp fullNameRegex = RegExp(r"\p{Letter}");

    return !reg.hasMatch(nat) ? "Please enter a valid nationality" : null;
  }
}
