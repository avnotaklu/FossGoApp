// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/player_rating.dart';

class MinimalRating {
  final int rating;
  final bool provisional;

  MinimalRating(this.rating, this.provisional);

  String stringify() {
    return provisional ? '$rating?' : rating.toString();
  }

  static MinimalRating fromRatingData(GlickoRating data) {
    return MinimalRating(
      data.rating.toInt(),
      data.deviation > 110,
    );
  }

  static MinimalRating? fromString(String? rating) {
    if (rating == null) {
      return null;
    }

    if (rating.contains('?')) {
      return MinimalRating(
          int.parse(rating.substring(0, rating.length - 1)), true);
    }

    return MinimalRating(int.parse(rating), false);
  }
}
