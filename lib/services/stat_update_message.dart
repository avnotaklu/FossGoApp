// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/variant_type.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/services/user_stats.dart';

class StatUpdateMessage extends SignalRMessageType {
  final UserStatForVariant stat;
  final PlayerRatingData rating;
  final VariantType variant;
  StatUpdateMessage({
    required this.stat,
    required this.rating,
    required this.variant,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'stat': stat.toMap(),
      'rating': rating.toMap(),
      'variant': variant.toKey,
    };
  }

  factory StatUpdateMessage.fromMap(Map<String, dynamic> map) {
    return StatUpdateMessage(
      stat: UserStatForVariant.fromMap(map['stat'] as Map<String, dynamic>),
      rating: PlayerRatingData.fromMap(map['rating'] as Map<String, dynamic>),
      variant: VariantType.fromKey(map['variant'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory StatUpdateMessage.fromJson(String source) =>
      StatUpdateMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}
