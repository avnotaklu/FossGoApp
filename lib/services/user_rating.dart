import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserRating {
  final String userId;
  final Map<String, PlayerRatingData> ratings;
  UserRating({
    required this.userId,
    required this.ratings,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'ratings': ratings,
    };
  }

  factory UserRating.fromMap(Map<String, dynamic> map) {
    return UserRating(
      userId: map['userId'] as String,
      ratings: Map<String, PlayerRatingData>.from(
        (map['ratings'] as Map<String, PlayerRatingData>),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRating.fromJson(String source) =>
      UserRating.fromMap(json.decode(source) as Map<String, dynamic>);
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
        (map['recent'] as List<int>),
      ),
      latest: map['latest'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['latest'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerRatingData.fromJson(String source) =>
      PlayerRatingData.fromMap(json.decode(source) as Map<String, dynamic>);
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
      rating: map['rating'] as double,
      deviation: map['deviation'] as double,
      volatility: map['volatility'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory GlickoRating.fromJson(String source) => GlickoRating.fromMap(json.decode(source) as Map<String, dynamic>);
}
