// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/utils/hive/mapper.dart';
import 'package:go/models/game.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/services/stat_update_message.dart';
import 'package:hive/hive.dart';

import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/api.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/user_stats.dart';

abstract interface class IStatsRepository {
  Future<Either<AppError, (UserStat, PlayerRating)>> getStats();
}

class StatsRepository extends IStatsRepository {
  final Api _api;
  final AuthProvider _auth;
  final SignalRProvider _signalRProvider;

  final Duration _invalidationLimit = const Duration(hours: 6);

  DateTime? _lastUpdated;

  StatsRepository(this._api, this._auth, this._signalRProvider) {
    _signalRProvider.userMessagesStream.listen((message) {
      if (message.type == SignalRMessageTypes.statUpdate) {
        final mes = message.data as StatUpdateMessage;
        _updateStatsOnChange(mes.stat, mes.rating, mes.variant);
      }
    });
  }

  final hiveBox = Hive.box<String>('stats');

  @override
  Future<Either<AppError, (UserStat, PlayerRating)>> getStats() async {
    if (_auth.myType != PlayerType.normal) {
      return left(AppError(message: "Stats not available for this user"));
    }

    final oldStats = hiveBox.get('stats') != null
        ? HiveUserStats.fromJson(hiveBox.get('stats')!)
        : null;

    if (_lastUpdated != null &&
        _lastUpdated!.difference(DateTime.now()) < _invalidationLimit &&
        oldStats != null) {
      return right((oldStats.stats, oldStats.rating));
    } else {
      return _updateStats();
    }
  }

  PlayerRating _padRatingWithDefaults(PlayerRating rating) {
    _rateableVariants().forEach((v) {
      if (rating.ratings[v] == null) {
        rating.ratings[v] = _defaultRatingData();
      }
    });

    var res = PlayerRating(playerId: rating.playerId, ratings: rating.ratings);
    return res;
  }

  UserStat _fillCombinedStats(UserStat stat) {
    final allBoards = BoardSize.values.where((a) => a.statAllowed);
    final allTimes = TimeStandard.values.where((a) => a.statAllowed);

    for (var board in allBoards) {
      var boardVariant = VariantType(board, null);
      var s = _statForCombinedVariant(
        board,
        allTimes.toList(),
        (a) => VariantType(a, null),
        (a, b) => VariantType(a, b),
        stat,
      );

      if(s != null) {
        stat.stats[boardVariant] = s;
      }
    }

    for (var time in allTimes) {
      var timeVariant = VariantType(null, time);
      var s  = _statForCombinedVariant(
        time,
        allBoards.toList(),
        (a) => VariantType(null, a),
        (a, b) => VariantType(b, a),
        stat,
      );

      if(s != null) {
        stat.stats[timeVariant] = s;
      }
    }

    var overall = VariantType(null, null);
    var s = _statForCombinedVariant<BoardSize?, TimeStandard>(
      null,
      allTimes.toList(),
      (a) => VariantType(null, null),
      (a, b) => VariantType(a, b),
      stat,
    );

    if(s != null) {
      stat.stats[overall] = s;
    }

    return stat;
  }

  UserStatForVariant? _statForCombinedVariant<A, B>(
      A master,
      List<B> subs,
      VariantType Function(A) masterCons,
      VariantType Function(A, B) subCons,
      UserStat stat) {
    var validStats = subs
        .map((sub) => stat.stats[subCons(master, sub)])
        .where((a) => a != null)
        .map((a) => a!)
        .toList();

    if (validStats.isEmpty) return null;

    var masterStat = UserStatForVariant(
      highestRating: validStats
          .map((a) => a.highestRating)
          .reduce((a, b) => (a ?? 0) > (b ?? 0) ? a : b),
      lowestRating: validStats.map((a) => a.lowestRating).reduce(
          (a, b) => (a ?? double.infinity) < (b ?? double.infinity) ? a : b),
      playTimeSeconds:
          validStats.map((a) => a.playTimeSeconds).reduce((a, b) => a + b),
      statCounts: validStats.map((a) => a.statCounts).reduce((a, b) => a + b),
      greatestWins: validStats
          .map((a) => a.greatestWins)
          .reduce((a, b) => (a ?? []).combine(b ?? [])),
    );

    return masterStat;
  }

  PlayerRating _fillCumulativeVariants(PlayerRating rating) {
    final allBoards = BoardSize.values.where((a) => a.ratingAllowed);
    final allTimes = TimeStandard.values.where((a) => a.ratingAllowed);

    for (var board in allBoards) {
      var boardVariant = VariantType(board, null);
      rating.ratings[boardVariant] = _ratingForCumulativeVariant(
        board,
        allTimes.toList(),
        (a) => VariantType(a, null),
        (a, b) => VariantType(a, b),
        rating,
      );
    }

    for (var time in allTimes) {
      var timeVariant = VariantType(null, time);
      rating.ratings[timeVariant] = _ratingForCumulativeVariant(
        time,
        allBoards.toList(),
        (a) => VariantType(null, a),
        (a, b) => VariantType(b, a),
        rating,
      );
    }

    var overall = VariantType(null, null);
    rating.ratings[overall] =
        _ratingForCumulativeVariant<BoardSize?, TimeStandard>(
      null,
      allTimes.toList(),
      (a) => VariantType(null, null),
      (a, b) => VariantType(a, b),
      rating,
    );

    return rating;
  }

  PlayerRatingData _ratingForCumulativeVariant<A, B>(
      A master,
      List<B> subs,
      VariantType Function(A) masterCons,
      VariantType Function(A, B) subCons,
      PlayerRating rating) {
    final masterV = masterCons(master);

    // Collecting the sub-performances
    final validRatings = subs
        .map((sub) => rating.ratings[subCons(master, sub)])
        .where((perf) =>
            perf != null &&
            perf.latest != null &&
            !perf.glicko.minimal.provisional)
        .map((a) => a!)
        .toList();

    // Determining the latest date
    final latestStyle = validRatings
        .where((a) => a.latest != null)
        .fold<PlayerRatingData?>(null, (a, b) {
      if (a == null) return b;
      if (a.latest!.isAfter(b.latest!)) return a;
      return b;
    });

    // Helper function for selecting `nb`
    int nbSelector(PlayerRatingData p) => p.nb;

    // Updating the standard performance
    final cumulatedRatings = (latestStyle?.latest != null)
        ? PlayerRatingData(
            glicko: GlickoRating(
              rating: validRatings
                  .map((s) =>
                      s.glicko.rating *
                      (s.nb /
                          validRatings.map(nbSelector).reduce((a, b) => a + b)))
                  .reduce((a, b) => a + b),
              deviation: validRatings
                  .map((s) =>
                      s.glicko.deviation *
                      (s.nb /
                          validRatings.map(nbSelector).reduce((a, b) => a + b)))
                  .reduce((a, b) => a + b),
              volatility: validRatings
                  .map((s) =>
                      s.glicko.volatility *
                      (s.nb /
                          validRatings.map(nbSelector).reduce((a, b) => a + b)))
                  .reduce((a, b) => a + b),
            ),
            nb: validRatings.map(nbSelector).reduce((a, b) => a + b),
            recent: [],
            latest: latestStyle!.latest,
          )
        : _defaultRatingData();

    // Returning a new PlayerRatingsData instance with the updated Standard
    return cumulatedRatings;
  }

  List<VariantType> _rateableVariants() {
    return BoardSize.values
        .where((a) => a.ratingAllowed)
        .flatMap<VariantType>((board) => TimeStandard.values
            .where((b) => b.ratingAllowed)
            .map((time) => VariantType(board, time)))
        .toList();
  }

  PlayerRatingData _defaultRatingData() {
    return PlayerRatingData(
      glicko: GlickoRating(
        rating: 1500,
        deviation: 200,
        volatility: 0.06,
      ),
      nb: 0,
      recent: [],
    );
  }

  Future<void> _updateStatsOnChange(UserStatForVariant stat,
      PlayerRatingData rating, VariantType variant) async {
    final oldHiveStat = await getStats();
    oldHiveStat.fold((l) {}, (r) {
      final oldStat = r.$1;
      final oldRating = r.$2;

      oldStat.stats[variant] = stat;
      oldRating.ratings[variant] = rating;
      var cumulated = _fillCumulativeVariants(oldRating);

      _saveRatings((oldStat, cumulated));
    });
  }

  Future<Either<AppError, (UserStat, PlayerRating)>> _updateStats() async {
    final token = _auth.token!;
    final userId = _auth.myId;

    final stats = TaskEither(() => _api.getUserStats(userId, token));
    final ratings = TaskEither(() => _api.getUserRating(userId, token));

    final res = await stats
        .flatMap((s) => ratings.map((r) {
              final padded = _padRatingWithDefaults(r);
              final cumulated = _fillCumulativeVariants(padded);

              final combined = _fillCombinedStats(s);

              return (combined, cumulated);
            }))
        .run();

    return res.map((value) {
      _saveRatings(value);
      return value;
    });
  }

  Future<void> _saveRatings((UserStat, PlayerRating) value) async {
    final stats = value.$1;
    final rating = value.$2;

    final time = DateTime.now();

    _lastUpdated = time;

    final hiveStats = HiveUserStats(
      rating: rating,
      stats: stats,
      lastUpdated: time.toIso8601String(),
    );

    await hiveBox.put('stats', hiveStats.toJson());
    debugPrint("Stats updated");
  }
}

class HiveUserStats {
  final UserStat stats;
  final PlayerRating rating;
  final String lastUpdated;

  HiveUserStats({
    required this.stats,
    required this.lastUpdated,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'stats': stats.toMap(),
      'lastUpdated': lastUpdated,
      'rating': rating.toMap(),
    };
  }

  factory HiveUserStats.fromMap(Map<String, dynamic> map) {
    return HiveUserStats(
      stats: UserStat.fromMap(map['stats'] as Map<String, dynamic>),
      lastUpdated: map['lastUpdated'] as String,
      rating: PlayerRating.fromMap(map['rating'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory HiveUserStats.fromJson(String source) =>
      HiveUserStats.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension GameStatCountsCombined on GameStatCounts {
  GameStatCounts operator +(GameStatCounts other) {
    return GameStatCounts(
      total: total + other.total,
      wins: wins + other.wins,
      losses: losses + other.losses,
      disconnects: disconnects + other.disconnects,
      draws: draws + other.draws,
    );
  }
}

extension GameResultStatCombined on List<GameResultStat> {
  List<GameResultStat> combine(List<GameResultStat> other) {
    var newL = [...this, ...other];
    newL.inplaceSortByHighestRating;
    return newL.truncated();
  }
}
