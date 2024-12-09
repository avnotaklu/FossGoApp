// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/variant_type.dart';

class UserStat {
  final String userId;
  final Map<VariantType, UserStatForVariant> stats;
  UserStat({
    required this.userId,
    required this.stats,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'stats': stats,
    };
  }

  factory UserStat.fromMap(Map<String, dynamic> map) {
    return UserStat(
      userId: map['userId'] as String,
      stats: Map<String, Map<String, dynamic>>.from((map['stats'])).map(
        (key, value) => MapEntry(
          VariantType.fromKey(key),
          UserStatForVariant.fromMap(value),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserStat.fromJson(String source) =>
      UserStat.fromMap(json.decode(source) as Map<String, dynamic>);
}

class UserStatForVariant {
  final double? highestRating;
  final double? lowestRating;
  final ResultStreakData? resultStreakData;
  final double playTimeSeconds;
  final List<GameResultStat>? greatestWins;
  final GameStatCounts statCounts;
  UserStatForVariant({
    this.highestRating,
    this.lowestRating,
    this.resultStreakData,
    required this.playTimeSeconds,
    this.greatestWins,
    required this.statCounts,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'highestRating': highestRating,
      'lowestRating': lowestRating,
      'resultStreakData': resultStreakData?.toMap(),
      'playTimeSeconds': playTimeSeconds,
      'greatestWins': greatestWins?.map((x) => x.toMap()).toList(),
      'statCounts': statCounts.toMap(),
    };
  }

  factory UserStatForVariant.fromMap(Map<String, dynamic> map) {
    return UserStatForVariant(
      highestRating:
          map['highestRating'] != null ? (map['highestRating'] as num).toDouble() : null,
      lowestRating:
          map['lowestRating'] != null ? (map['lowestRating'] as num).toDouble() : null,
      resultStreakData: map['resultStreakData'] != null
          ? ResultStreakData.fromMap(
              map['resultStreakData'] as Map<String, dynamic>)
          : null,
      playTimeSeconds: (map['playTimeSeconds'] as num).toDouble(),
      greatestWins: map['greatestWins'] != null
          ? List<GameResultStat>.from(
              (map['greatestWins'] as List).map<GameResultStat?>(
                (x) => GameResultStat.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      statCounts:
          GameStatCounts.fromMap(map['statCounts'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserStatForVariant.fromJson(String source) =>
      UserStatForVariant.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ResultStreakData {
  final StreakData? winningStreaks;
  final StreakData? losingStreaks;
  ResultStreakData({
    this.winningStreaks,
    this.losingStreaks,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'winningStreaks': winningStreaks?.toMap(),
      'losingStreaks': losingStreaks?.toMap(),
    };
  }

  factory ResultStreakData.fromMap(Map<String, dynamic> map) {
    return ResultStreakData(
      winningStreaks: map['winningStreaks'] != null
          ? StreakData.fromMap(map['winningStreaks'] as Map<String, dynamic>)
          : null,
      losingStreaks: map['losingStreaks'] != null
          ? StreakData.fromMap(map['losingStreaks'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ResultStreakData.fromJson(String source) =>
      ResultStreakData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class StreakData {
  final Streak? greatestStreak;
  final Streak? currentStreak;
  StreakData({
    this.greatestStreak,
    this.currentStreak,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'greatestStreak': greatestStreak?.toMap(),
      'currentStreak': currentStreak?.toMap(),
    };
  }

  factory StreakData.fromMap(Map<String, dynamic> map) {
    return StreakData(
      greatestStreak: map['greatestStreak'] != null
          ? Streak.fromMap(map['greatestStreak'] as Map<String, dynamic>)
          : null,
      currentStreak: map['currentStreak'] != null
          ? Streak.fromMap(map['currentStreak'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StreakData.fromJson(String source) =>
      StreakData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Streak {
  final int streakLength;
  final DateTime streakFrom;
  final String startingGameId;
  final String endingGameId;
  final DateTime streakTo;
  Streak({
    required this.streakLength,
    required this.streakFrom,
    required this.startingGameId,
    required this.endingGameId,
    required this.streakTo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'streakLength': streakLength,
      'streakFrom': streakFrom.millisecondsSinceEpoch,
      'startingGameId': startingGameId,
      'endingGameId': endingGameId,
      'streakTo': streakTo.millisecondsSinceEpoch,
    };
  }

  factory Streak.fromMap(Map<String, dynamic> map) {
    return Streak(
      streakLength: map['streakLength'] as int,
      streakFrom: DateTime.parse(map['streakFrom'] as String),
      startingGameId: map['startingGameId'] as String,
      endingGameId: map['endingGameId'] as String,
      streakTo: DateTime.parse(map['streakTo'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Streak.fromJson(String source) =>
      Streak.fromMap(json.decode(source) as Map<String, dynamic>);
}

class GameStatCounts {
  final int total;
  final int wins;
  final int losses;
  final int disconnects;
  final int draws;
  GameStatCounts({
    required this.total,
    required this.wins,
    required this.losses,
    required this.disconnects,
    required this.draws,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total': total,
      'wins': wins,
      'losses': losses,
      'disconnects': disconnects,
      'draws': draws,
    };
  }

  factory GameStatCounts.fromMap(Map<String, dynamic> map) {
    return GameStatCounts(
      total: map['total'] as int,
      wins: map['wins'] as int,
      losses: map['losses'] as int,
      disconnects: map['disconnects'] as int,
      draws: map['draws'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameStatCounts.fromJson(String source) =>
      GameStatCounts.fromMap(json.decode(source) as Map<String, dynamic>);
}

class GameResultStat {
  final int opponentRating;
  final String opponentId;
  final DateTime resultAt;
  final String gameId;
  GameResultStat({
    required this.opponentRating,
    required this.opponentId,
    required this.resultAt,
    required this.gameId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'opponentRating': opponentRating,
      'opponentId': opponentId,
      'resultAt': resultAt.millisecondsSinceEpoch,
      'gameId': gameId,
    };
  }

  factory GameResultStat.fromMap(Map<String, dynamic> map) {
    return GameResultStat(
      opponentRating: map['opponentRating'] as int,
      opponentId: map['opponentId'] as String,
      resultAt: DateTime.parse(map['resultAt'] as String),
      gameId: map['gameId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameResultStat.fromJson(String source) =>
      GameResultStat.fromMap(json.decode(source) as Map<String, dynamic>);
}
