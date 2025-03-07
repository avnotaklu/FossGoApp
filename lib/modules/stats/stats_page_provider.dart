import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/api.dart';
import 'package:go/models/game_and_opponent.dart';
import 'package:go/models/player_rating.dart';
import 'package:go/models/user_stats.dart';

extension BoardSizeFilteringExt on BoardSize? {
  FilteredBoardSize get statFiltered {
    switch (this) {
      case BoardSize.nine:
        return FilteredBoardSize.nine;
      case BoardSize.thirteen:
        return FilteredBoardSize.thirteen;
      case BoardSize.nineteen:
        return FilteredBoardSize.nineteen;
      case null:
        return FilteredBoardSize.all;
      case BoardSize.other:
        throw Exception("BoardSize.other is not supported");
    }
  }
}

extension FilteredBoardSizeExt on FilteredBoardSize {
  BoardSize? get actBoardSize => switch (this) {
        FilteredBoardSize.all => null,
        final size => BoardSize.values[size.index - 1],
      };

  String get stringRepr => switch (this) {
        FilteredBoardSize.all => "All",
        final size => BoardSize.values[size.index - 1].toDisplayString,
      };
}

enum FilteredBoardSize { all, nine, thirteen, nineteen }

extension TimeStandardFilteringExt on TimeStandard? {
  FilteredTimeStandard get statFiltered {
    switch (this) {
      case TimeStandard.blitz:
        return FilteredTimeStandard.blitz;
      case TimeStandard.rapid:
        return FilteredTimeStandard.rapid;
      case TimeStandard.classical:
        return FilteredTimeStandard.classical;
      case TimeStandard.correspondence:
        return FilteredTimeStandard.correspondence;
      case null:
        return FilteredTimeStandard.all;
    }
  }
}

extension FilteredTimeStandardExt on FilteredTimeStandard {
  TimeStandard? get actTimeStandard => switch (this) {
        FilteredTimeStandard.all => null,
        final size => TimeStandard.values[size.index - 1],
      };

  String get stringRepr => switch (this) {
        FilteredTimeStandard.all => "All",
        final size => TimeStandard.values[size.index - 1].standardName,
      };
}

enum FilteredTimeStandard { all, blitz, rapid, classical, correspondence }

extension VariantTypeStatViewExt on VariantType {
  FilterableVariantType get statView =>
      FilterableVariantType(boardSize.statFiltered, timeStandard.statFiltered);
}

extension FilterableVariantTypeExt on FilterableVariantType {
  FilterableVariantType modify(
          FilteredBoardSize? boardSize, FilteredTimeStandard? timeStandard) =>
      FilterableVariantType(
          boardSize ?? this.boardSize, timeStandard ?? this.timeStandard);
}

class FilterableVariantType {
  final FilteredBoardSize boardSize;
  final FilteredTimeStandard timeStandard;

  FilterableVariantType(this.boardSize, this.timeStandard);

  VariantType get variantType => VariantType(
        boardSize?.actBoardSize,
        timeStandard?.actTimeStandard,
      );

  FilterableVariantType.fromVariant(VariantType variant)
      : assert(variant.boardSize != BoardSize.other),
        boardSize = variant.boardSize?.statFiltered ?? FilteredBoardSize.all,
        timeStandard =
            variant.timeStandard?.statFiltered ?? FilteredTimeStandard.all;
}

class StatsPageProvider extends ChangeNotifier {
  // VariantType _filteredVariant;
  FilterableVariantType _filteredVariant;

  FilteredBoardSize get boardSize => _filteredVariant.boardSize;

  FilteredTimeStandard get timeStandard => _filteredVariant.timeStandard;

  final AuthProvider authPro;
  final Api api;

  UserStatForVariant? get _statsForVariant =>
      _stats.stats[_filteredVariant.variantType];

  PlayerRatingData? get _ratingForVariant =>
      _rating.ratings[_filteredVariant.variantType]!;

  final UserStat _stats;
  final PlayerRating _rating;

  StatsPageProvider(this.authPro, this.api, VariantType? filteredVariant,
      this._stats, this._rating)
      : assert(filteredVariant?.boardSize != BoardSize.other),
        _filteredVariant = filteredVariant?.statView ??
            FilterableVariantType(
                FilteredBoardSize.all, FilteredTimeStandard.all);

  PlayerRatingData getRating() {
    return _ratingForVariant!;
  }

  Either<AppError, UserStatForVariant> getStats() {
    return _statsForVariant == null
        ? left(AppError(message: "Data not available"))
        : right(_statsForVariant!);
  }

  Either<AppError, GameStatCounts> getCounts(UserStatForVariant data) {
    return right(_statsForVariant!.statCounts);
    // ? left(AppError(message: "Stat not available"))
    // : right(_statsForVariant!.statCounts);
  }

  Duration timePlayed(UserStatForVariant data) {
    return Duration(seconds: data.playTimeSeconds.toInt());
  }

  double? highestRating(UserStatForVariant data) {
    return data.highestRating;
  }

  double? lowestRating(UserStatForVariant data) {
    return data.lowestRating;
  }

  List<GameResultStat>? getGreatestWins(UserStatForVariant data) {
    return data.greatestWins;
  }

  // Either<String, PlayerRatingData> unavailabiltyReasonOrRating() {
  //   if (_filteredVariant.boardSize != FilteredBoardSize.all &&
  //       _filteredVariant.timeStandard == FilteredTimeStandard.all) {
  //     return left("not available without specific time control");
  //   }wwwaaaaaaaa

  //   return right(_ratingForVariant!);
  // }

  Either<AppError, ResultStreakData> unavailabiltyReasonOrStreakData(
      UserStatForVariant data) {
    // return left(AppError(message: "Testing the error"));
    if (_filteredVariant.boardSize == FilteredBoardSize.all) {
      return left(AppError(message: "select a specific board size"));
    }
    if (_filteredVariant.timeStandard == FilteredTimeStandard.all) {
      return left(AppError(message: "select a specific time control"));
    }
    if (_statsForVariant == null) {
      return left(AppError(message: "Data not available"));
    }
    return right(_statsForVariant!.resultStreakData!);
  }

  // Either<String, ResultStreakData> unavailabiltyReasonOrStreakData() {
  //   if (_filteredVariant.boardSize == FilteredBoardSize.all) {
  //     return left("select a specific board size");
  //   }
  //   if (_filteredVariant.timeStandard == FilteredTimeStandard.all) {
  //     return left("select a specific time control");
  //   }
  //   return right(_stats.resultStreakData!);
  // }

  void changeVariant(FilteredBoardSize? b, FilteredTimeStandard? t) {
    _filteredVariant = _filteredVariant.modify(b, t);
    notifyListeners();
  }

  Future<Either<AppError, GameAndOpponent>> loadGame(String gameId) {
    return api.getGameAndOpponent(gameId);
  }
}
