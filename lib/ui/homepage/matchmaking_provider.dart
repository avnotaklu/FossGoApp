// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go/models/time_control.dart';

class MatchmakingProvider extends ChangeNotifier {
  List<(int, int)> selectedBoardSizes = [];

  List<(int, int)> allBoardSizes = [
    (9, 9),
    (13, 13),
    (19, 19),
  ];

  List<TimeControl> selectedTimeControls = [];

  List<(String name, TimeControl control)> allTimeControls = [
    ('Blitz', blitz),
    ('Rapid', rapid),
    ('Classical', classical),
  ];

  void modifyBoardSize((int, int) size, bool isAdded) {
    if (isAdded) {
      selectedBoardSizes.add(size);
    } else {
      selectedBoardSizes.remove(size);
    }

    notifyListeners();
  }

  void modifyTimeControl(TimeControl control, bool isAdded) {
    if (isAdded) {
      selectedTimeControls.add(control);
    } else {
      selectedTimeControls.remove(control);
    }

    notifyListeners();
  }
}