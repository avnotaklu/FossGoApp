import 'package:go/services/user_rating.dart';

extension BoardSizeDataExt on BoardSize {
  RateableBoardSize? get rateable => switch (this) {
        BoardSize.nine => RateableBoardSize.nine,
        BoardSize.thirteen => RateableBoardSize.thirteen,
        BoardSize.nineteen => RateableBoardSize.nineteen,
        BoardSize.other => null
      };

  bool get ratingAllowed => switch (this) {
        BoardSize.nine => true,
        BoardSize.thirteen => true,
        BoardSize.nineteen => true,
        BoardSize.other => false,
      };

  bool get statAllowed {
    // Always true in this case.
    return true;
  }

  String get toKey => 'B${this.index}';
}

enum BoardSize {
  nine,
  thirteen,
  nineteen,
  other,
}

extension TimeStandardExt on TimeStandard {
  RateableTimeStandard? get rateable => switch (this) {
        TimeStandard.blitz => RateableTimeStandard.blitz,
        TimeStandard.rapid => RateableTimeStandard.rapid,
        TimeStandard.classical => RateableTimeStandard.classical,
        TimeStandard.correspondence => RateableTimeStandard.correspondence,
      };

  bool get ratingAllowed => switch (this) {
        TimeStandard.blitz => true,
        TimeStandard.rapid => true,
        TimeStandard.classical => true,
        TimeStandard.correspondence => true,
      };

  bool get statAllowed {
    // Always true in this case.
    return true;
  }

  String get toKey => 'S${this.index}';
}

enum TimeStandard {
  blitz("Blitz"),
  rapid("Rapid"),
  classical("Classical"),
  correspondence("Correspondence");

  final String standardName;

  const TimeStandard(this.standardName);
}

class VariantType {
  final BoardSize? boardSize;
  final TimeStandard? timeStandard;

  VariantType(this.boardSize, this.timeStandard);

  bool get ratingAllowed {
    if (timeStandard == null) return false;
    if (boardSize == null) return timeStandard!.ratingAllowed;
    return boardSize!.ratingAllowed && timeStandard!.ratingAllowed;
  }

  bool get statAllowed {
    if (timeStandard == null) return true;
    if (boardSize == null) return true;
    return boardSize!.statAllowed && timeStandard!.statAllowed;
  }

  String get toKey {
    final bsKey = boardSize?.toKey;
    final tsKey = timeStandard?.toKey;

    if (bsKey == null && tsKey == null) return 'o';
    if (bsKey == null) return '_$tsKey';
    if (tsKey == null) return '${bsKey}_';
    return '${bsKey}_$tsKey';
  }

  static VariantType fromKey(String key) {
    if (key == 'o') return VariantType(null, null);

    final parts = key.split('_');

    BoardSize? boardSize;
    TimeStandard? timeStandard;

    if (parts[0].isNotEmpty) {
      boardSize = BoardSize.values[int.parse(parts[0].substring(1))];
    }

    if (parts.length > 1 && parts[1].isNotEmpty) {
      timeStandard = TimeStandard.values[int.parse(parts[1].substring(1))];
    }

    return VariantType(boardSize, timeStandard);
  }

  @override
  String toString() => 'BoardSize: $boardSize, TimeStandard: $timeStandard';
}
