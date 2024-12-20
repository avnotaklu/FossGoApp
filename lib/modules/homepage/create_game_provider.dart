import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';
import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game_creation_dto.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:go/services/time_control_dto.dart';
import 'package:go/models/variant_type.dart';

typedef GameCreationParams = ({
  StoneSelectionType stone,
  TimeControlDto time,
  Constants.BoardSizeData board
});

class CreateGameProvider extends ChangeNotifier {
  // final Future<Either<AppError, Game>> Function(
  //         StoneSelectionType stone, TimeControlDto time, BoardSizeData board)
  //     onCreate;
  final Completer<GameCreationParams> paramsCompleter;

  var api = Api();

  // static const title = 'Grid List';
  Constants.BoardSizeData _boardSize = Constants.boardSizes[0];
  Constants.BoardSizeData get boardSize => _boardSize;

  StoneSelectionType _mStoneType = StoneSelectionType.auto;
  StoneSelectionType get mStoneType => _mStoneType;

  // Time
  Constants.TimeFormat _timeFormat = Constants.TimeFormat.suddenDeath;
  Constants.TimeFormat get timeFormat => _timeFormat;

  TimeStandard _timeStandard = TimeStandard.blitz;
  TimeStandard get timeStandard => _timeStandard;

  Duration _mainTime = Constants.timeStandardMainTime[TimeStandard.blitz]!;
  Duration get mainTimeSeconds => _mainTime;

  Duration _increment = Constants.timeStandardIncrement[TimeStandard.blitz]!;
  Duration get incrementSeconds => _increment;

  Duration _byoYomi = Constants.timeStandardByoYomiTime[TimeStandard.blitz]!;
  Duration get byoYomiSeconds => _byoYomi;

  final byoYomiCountController = TextEditingController();

  CreateGameProvider(this.paramsCompleter);

  void init() async {
    _mStoneType = StoneSelectionType.black;
    byoYomiCountController.text = "3";
  }

  void changeBoardSize(Constants.BoardSizeData size) {
    _boardSize = size;
    notifyListeners();
  }

  void changeStoneType(StoneSelectionType type) {
    _mStoneType = type;
    notifyListeners();
  }

  void changeTimeFormat(Constants.TimeFormat format) {
    _timeFormat = format;
    notifyListeners();
  }

  void changeTimeStandard(TimeStandard standard) {
    _timeStandard = standard;

    _mainTime = Constants.timeStandardMainTime[standard]!;
    _increment = Constants.timeStandardIncrement[standard]!;
    _byoYomi = Constants.timeStandardByoYomiTime[standard]!;

    notifyListeners();
  }

  void changeMainTimeSeconds(Duration d) {
    _mainTime = d;
    notifyListeners();
  }

  void changeIncrementSeconds(Duration d) {
    _increment = d;
    notifyListeners();
  }

  void changeByoYomiSeconds(Duration d) {
    _byoYomi = d;
    notifyListeners();
  }

  int get byoYomiCount => int.parse(byoYomiCountController.text);

  @override
  void dispose() {
    super.dispose();
    byoYomiCountController.dispose();
  }

  // Future<Either<AppError, Game>>
  void createGame(String token) async {
    var timeControl = TimeControlDto(
      mainTimeSeconds: _mainTime.inSeconds,
      incrementSeconds: _timeFormat == Constants.TimeFormat.fischer
          ? _increment.inSeconds
          : null,
      byoYomiTime: _timeFormat == Constants.TimeFormat.byoYomi
          ? ByoYomiTime(
              byoYomis: byoYomiCount,
              byoYomiSeconds: _byoYomi.inSeconds,
            )
          : null,
    );
    paramsCompleter.complete((
      stone: _mStoneType,
      time: timeControl,
      board: boardSize,
    ));
  }
}
