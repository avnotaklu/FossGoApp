import 'package:go/models/player_rating.dart';

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

  String get toKey => '${this.index}';

  String get toDisplayString => switch (this) {
        BoardSize.nine => '9x9',
        BoardSize.thirteen => '13x13',
        BoardSize.nineteen => '19x19',
        BoardSize.other => 'Other',
      };

  String get paddedToLargestDisplay => switch (this) {
        BoardSize.nine => '9x9  ',
        BoardSize.thirteen => '13x13',
        BoardSize.nineteen => '19x19',
        BoardSize.other => 'Other',
      };
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

  String get toKey => '${this.index}';
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

  VariantType.b(this.boardSize) : timeStandard = null;
  VariantType.t(this.timeStandard) : boardSize = null;

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
      boardSize = BoardSize.values[int.parse(parts[0])];
    }

    if (parts.length > 1 && parts[1].isNotEmpty) {
      timeStandard = TimeStandard.values[int.parse(parts[1])];
    }

    return VariantType(boardSize, timeStandard);
  }

  @override
  String toString() => 'BoardSize: $boardSize, TimeStandard: $timeStandard';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VariantType &&
        other.boardSize == boardSize &&
        other.timeStandard == timeStandard;
  }

  @override
  int get hashCode => boardSize.hashCode ^ timeStandard.hashCode;
}
