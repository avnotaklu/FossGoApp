import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/services/user_stats.dart';

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

  UserStatForVariant get _statsForVariant =>
      _stats.stats[_filteredVariant.variantType]!;

  PlayerRatingData? get _ratingForVariant =>
      _rating.ratings[_filteredVariant.variantType]!;

  final UserStat _stats;
  final PlayerRating _rating;

  StatsPageProvider(
      this.authPro, VariantType? filteredVariant, this._stats, this._rating)
      : assert(filteredVariant?.boardSize != BoardSize.other),
        _filteredVariant = filteredVariant?.statView ??
            FilterableVariantType(
                FilteredBoardSize.all, FilteredTimeStandard.all);

  PlayerRatingData getRating() {
    return _ratingForVariant!;
  }

  GameStatCounts getCounts() {
    return _statsForVariant.statCounts;
  }

  // Either<String, PlayerRatingData> unavailabiltyReasonOrRating() {
  //   if (_filteredVariant.boardSize != FilteredBoardSize.all &&
  //       _filteredVariant.timeStandard == FilteredTimeStandard.all) {
  //     return left("not available without specific time control");
  //   }

  //   return right(_ratingForVariant!);
  // }

  Either<String, ResultStreakData> unavailabiltyReasonOrStreakData() {
    if (_filteredVariant.boardSize == FilteredBoardSize.all) {
      return left("select a specific board size");
    }
    if (_filteredVariant.timeStandard == FilteredTimeStandard.all) {
      return left("select a specific time control");
    }
    return right(_statsForVariant.resultStreakData!);
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
}
