// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
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
  bool findingMatch = false;

  final SignalRProvider signalRProvider;

  MatchmakingProvider(this.signalRProvider) {
    // TODO: this should also maybe have some notification to the user

    signalRProvider.userMessagesStream.listen((event) {
      if (event.type == SignalRMessageTypes.matchFound) {
        debugPrint("Got matchmaking update");
        onMatchmakingUpdated.add(event.data as GameJoinMessage);
        findingMatch = false;
        notifyListeners();
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

  Future<Either<AppError, Null>> findMatch() async {
    final res = await signalRProvider.findMatch(
      FindMatchDto(
          boardSizes: selectedBoardSizes.map((a) => a).toList(),
          timeStandards: selectedTimeControls.map((a) => a).toList()),
    );

    return res.fold((l) {
      return left(l);
    }, (r) {
      findingMatch = true;
      notifyListeners();
      return right(null);
    });
  }

  Future<Either<AppError, Null>> cancelFind() async {
    final res = await signalRProvider.cancelFind();

    return res.fold((l) {
      return left(l);
    }, (r) {
      findingMatch = false;
      notifyListeners();
      return right(null);
    });
  }
}
