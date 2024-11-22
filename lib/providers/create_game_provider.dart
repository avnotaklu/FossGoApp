import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/gameplay/create/stone_selection_widget.dart';
import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game_creation_dto.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:provider/provider.dart';

class CreateGameProvider extends ChangeNotifier {
  // final SignalRProvider signalRBloc;
  final SignalRProvider signalRBloc;
  var api = Api();

  // static const title = 'Grid List';
  Constants.BoardSize _boardSize = Constants.boardSizes[0];
  Constants.BoardSize get boardSize => _boardSize;

  StoneSelectionType _mStoneType = StoneSelectionType.auto;
  StoneSelectionType get mStoneType => _mStoneType;

  // Time
  Constants.TimeFormat _timeFormat = Constants.TimeFormat.suddenDeath;
  Constants.TimeFormat get timeFormat => _timeFormat;

  Constants.TimeStandard _timeStandard = Constants.TimeStandard.blitz;
  Constants.TimeStandard get timeStandard => _timeStandard;

  int _mainTimeSeconds =
      Constants.timeStandardMainTime[Constants.TimeStandard.blitz]!;
  int get mainTimeSeconds => _mainTimeSeconds;

  int _incrementSeconds =
      Constants.timeStandardIncrement[Constants.TimeStandard.blitz]!;
  int get incrementSeconds => _incrementSeconds;

  int _byoYomiSeconds =
      Constants.timeStandardByoYomiTime[Constants.TimeStandard.blitz]!;
  int get byoYomiSeconds => _byoYomiSeconds;

  final byoYomiCountController = TextEditingController();

  CreateGameProvider(this.signalRBloc);

  void init() async {
    _mStoneType = StoneSelectionType.black;
    byoYomiCountController.text = "3";
  }

  void changeBoardSize(Constants.BoardSize size) {
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

  void changeTimeStandard(Constants.TimeStandard standard) {
    _timeStandard = standard;

    _mainTimeSeconds = Constants.timeStandardMainTime[standard]!;
    _incrementSeconds = Constants.timeStandardIncrement[standard]!;
    _byoYomiSeconds = Constants.timeStandardByoYomiTime[standard]!;

    notifyListeners();
  }

  void changeMainTimeSeconds(int seconds) {
    _mainTimeSeconds = seconds;
    notifyListeners();
  }

  void changeIncrementSeconds(int seconds) {
    _incrementSeconds = seconds;
    notifyListeners();
  }

  void changeByoYomiSeconds(int seconds) {
    _byoYomiSeconds = seconds;
    notifyListeners();
  }

  int get byoYomiCount => int.parse(byoYomiCountController.text);

  @override
  void dispose() {
    super.dispose();
    byoYomiCountController.dispose();
  }

  Future<Either<AppError, Game>> createGame(String token) async {
    var timeControl = TimeControl(
      mainTimeSeconds: _mainTimeSeconds,
      incrementSeconds:
          _timeFormat == Constants.TimeFormat.fischer ? _incrementSeconds : 0,
      byoYomiTime: _timeFormat == Constants.TimeFormat.byoYomi
          ? ByoYomiTime(
              byoYomis: byoYomiCount,
              byoYomiSeconds: _byoYomiSeconds,
            )
          : null,
    );
    var game = await api.createGame(
        GameCreationDto(rows: boardSize.rows, columns: boardSize.cols, timeControl: timeControl, firstPlayerStone: _mStoneType), token);
    return game.mapLeft(AppError.fromApiError);
  }
}
