import 'package:flutter/material.dart';
import 'package:go/models/variant_type.dart';

class ProfilePageProvider extends ChangeNotifier {
  StatFilter statFilter = StatFilter.byTime;

  void setStatFilter(StatFilter filter) {
    statFilter = filter;
    notifyListeners();
  }
}

enum StatFilter {
  byTime("By time"),
  byBoardSize("By board size");

  final String realName;

  const StatFilter(this.realName);
}

extension DisplayForVariant on VariantType {
  String get title {
    assert(boardSize == null || timeStandard == null,
        "Currently only supports one of the two");

    if (boardSize != null) {
      return boardSize!.toDisplayString;
    } else {
      return timeStandard!.standardName;
    }
  }
}
