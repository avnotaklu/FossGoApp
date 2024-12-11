import 'dart:convert';

import 'package:go/constants/constants.dart';
import 'package:go/models/game.dart';
import 'package:go/models/minimal_rating.dart';
import 'package:go/models/time_control.dart';
import 'package:go/models/variant_type.dart';

enum RateableBoardSize { nine, thirteen, nineteen }

enum RateableTimeStandard { blitz, rapid, classical, correspondence }

extension UserRatingsExt on PlayerRating {
  PlayerRatingData? getRatingForGame(Game game) {
    var v = game.getTopLevelVariant();
    if (!v.ratingAllowed) {
      return null;
    }

    return ratings[v];
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PlayerRating {
  final String playerId;
  final Map<VariantType, PlayerRatingData> ratings;
  PlayerRating({
    required this.playerId,
    required this.ratings,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'playerId': playerId,
      'ratings':
          ratings.map((key, value) => MapEntry(key.toKey, value.toMap())),
    };
  }

  factory PlayerRating.fromMap(Map<String, dynamic> map) {
    return PlayerRating(
      playerId: map['playerId'] as String,
      ratings: Map<String, Map<String, dynamic>>.from((map['ratings'])).map(
        (key, value) => MapEntry(
          VariantType.fromKey(key),
          PlayerRatingData.fromMap(value),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerRating.fromJson(String source) =>
      PlayerRating.fromMap(json.decode(source) as Map<String, dynamic>);
}

class PlayerRatingData {
  final GlickoRating glicko;
  final int nb;
  final List<int> recent;
  final DateTime? latest;

  PlayerRatingData({
    required this.glicko,
    required this.nb,
    required this.recent,
    this.latest,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'glicko': glicko.toMap(),
      'nb': nb,
      'recent': recent,
      'latest': latest?.millisecondsSinceEpoch,
    };
  }

  factory PlayerRatingData.fromMap(Map<String, dynamic> map) {
    return PlayerRatingData(
      glicko: GlickoRating.fromMap(map['glicko'] as Map<String, dynamic>),
      nb: map['nb'] as int,
      recent: List<int>.from(
        (map['recent'] as List),
      ),
      latest: map['latest'] != null
          ? DateTime.parse(map['latest'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerRatingData.fromJson(String source) =>
      PlayerRatingData.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension GlickoRatingExt on GlickoRating {
  MinimalRating get minimal => MinimalRating.fromRatingData(this);
}

class GlickoRating {
  final double rating;
  final double deviation;
  final double volatility;
  GlickoRating({
    required this.rating,
    required this.deviation,
    required this.volatility,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rating': rating,
      'deviation': deviation,
      'volatility': volatility,
    };
  }

  factory GlickoRating.fromMap(Map<String, dynamic> map) {
    return GlickoRating(
      rating: (map['rating'] as num).toDouble(),
      deviation: (map['deviation'] as num).toDouble(),
      volatility: (map['volatility'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory GlickoRating.fromJson(String source) =>
      GlickoRating.fromMap(json.decode(source) as Map<String, dynamic>);
}
