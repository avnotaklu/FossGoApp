// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/services/time_control_dto.dart';
import 'package:go/services/find_match_dto.dart';
import 'package:go/constants/constants.dart' as constants;

// enum BoardSize {
//   nine,
//   thirteen,
//   nineteen,
//   other,
// }

class MatchmakingProvider extends ChangeNotifier {
  final SignalRProvider signalRProvider;

  MatchmakingProvider(this.signalRProvider) {
    // TODO: this should also maybe have some notification to the user

    signalRProvider.userMessagesStream.listen((event) {
      if (event.data case GameJoinMessage res) {
        debugPrint("Got matchmaking update");
        onMatchmakingUpdated.add(res);
      }
    });
  }

  StreamController<GameJoinMessage> onMatchmakingUpdated =
      StreamController<GameJoinMessage>.broadcast();

  List<MatchableBoardSizes> selectedBoardSizes = [MatchableBoardSizes.nine];

  List<MatchableBoardSizes> allBoardSizes = [...MatchableBoardSizes.values];

  List<TimeControlDto> selectedTimeControls = [
    constants.timeControlsForMatch[0]
  ];

  List<TimeControlDto> allTimeControls = [...constants.timeControlsForMatch];

  void modifyBoardSize(MatchableBoardSizes size, bool isAdded) {
    if (isAdded) {
      selectedBoardSizes.add(size);
    } else {
      if (selectedBoardSizes.length > 1) {
        selectedBoardSizes.remove(size);
      }
    }

    notifyListeners();
  }

  void modifyTimeControl(TimeControlDto control, bool isAdded) {
    if (isAdded) {
      selectedTimeControls.add(control);
    } else {
      if (selectedTimeControls.length > 1) {
        selectedTimeControls.remove(control);
      }
    }

    notifyListeners();
  }

  void findMatch() async {
    await signalRProvider.findMatch(
      FindMatchDto(
          boardSizes: selectedBoardSizes.map((a) => a).toList(),
          timeStandards: selectedTimeControls.map((a) => a).toList()),
    );
  }
}
