import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/gameplay/middleware/score_calculator.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/middleware/time_calculator.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/services/move_position.dart';

class LocalGameplayServer {
  final TimeCalculator timeCalculator;

  BoardStateUtilities get boardUtils => BoardStateUtilities(_rows, _columns);

  SystemUtilities systemUtilities;
  DateTime get now => systemUtilities.currentTime;
  late Timer _timer;

  // TODO: This stream only streams the game end, and timer updates
  // This should within the theme of the app be a stream of the whole game

  final StreamController<GameUpdate> gameUpdateC = StreamController.broadcast();
  Stream<GameUpdate> get gameUpdate => gameUpdateC.stream;

  int _rows;
  int _columns;
  TimeControl _timeControl;
  late List<int> _prisoners;
  late Map<Position, StoneType> _playgroundMap;
  late List<GameMove> _moves;
  late List<PlayerTimeSnapshot> _playerTimeSnapshots;
  late List<String> _players;
  late DateTime _startTime;
  Position? _koPositionInLastMove;
  late GameState _gameState;
  late Map<Position, DeadStoneState> _stoneStates;

  List<Position> get deadStones => _stoneStates.entries
      .where((e) => e.value == DeadStoneState.Dead)
      .map((e) => e.key)
      .toList();

  GameResult? _result;
  late double _komi;
  GameOverMethod? _gameOverMethod;
  late List<int> _finalScores;
  DateTime? _endTime;

  int get turn => _moves.length;
  int get turnPlayer => turn % 2;

  final List<StoneType> _scoresAcceptedBy = [];

  LocalGameplayServer(this._rows, this._columns, this._timeControl)
      : systemUtilities = systemUtils,
        timeCalculator = TimeCalculator() {
    initializeFields();
    _timer = Timer(
        Duration(
          milliseconds: _playerTimeSnapshots[turnPlayer].mainTimeMilliseconds,
        ),
        _timeoutTimer);
  }

  void initializeFields() {
    _startTime = now;

    _prisoners = [0, 0];
    _playgroundMap = {};
    _moves = [];
    _playerTimeSnapshots = [
      _timeControl.getStartingSnapshot(_startTime, true),
      _timeControl.getStartingSnapshot(_startTime, false),
    ];
    _players = ["bottom", "top"];
    _koPositionInLastMove = null;
    _gameState = GameState.playing;
    _stoneStates = {};
    _result = null;
    _komi = 6.5;
    _gameOverMethod = null;
    _finalScores = [];
    _endTime = null;
  }

  Game getGame() {
    return Game(
      gameId: "LocalGame",
      rows: _rows,
      columns: _columns,
      timeControl: _timeControl,
      playgroundMap: _playgroundMap,
      moves: _moves,
      players: _players,
      prisoners: _prisoners,
      startTime: _startTime,
      koPositionInLastMove: _koPositionInLastMove,
      gameState: _gameState,
      deadStones: deadStones,
      result: _result,
      komi: _komi,
      finalScore: _finalScores,
      endTime: _endTime,
      gameOverMethod: _gameOverMethod,
      playerTimeSnapshots: _playerTimeSnapshots,
      gameCreator: null,
      stoneSelectionType: StoneSelectionType.auto,
      playersRatingsAfter: [],
      playersRatingsDiff: [],
      gameType: GameType.anonymous,
      creationTime: _startTime,
      usernames: ["Player 1", "Player 2"],
    );
  }

  log(String m) {
    debugPrint(m);
  }

  Either<AppError, Game> makeMove(MovePosition move, StoneType stone) {
    assert(turnPlayer == stone.index, "It's not this player's turn");
    final stoneLogic = StoneLogic(getGame());
    try {
      if (!move.isPass()) {
        var res =
            stoneLogic.handleStoneUpdate(Position(move.x!, move.y!), stone);
        if (res.result) {
          _playgroundMap =
              res.board.playgroundMap.toHighLevelBoardRepresentation();
          _prisoners = res.board.prisoners
              .zip(_prisoners)
              .map((a) => a.$1 + a.$2)
              .toList();
        } else {
          log("Couldn't play at position");
          return left(AppError(message: "Couldn't play at position"));
        }
      }

      var moveTime = now;

      _moves.add(
        GameMove(
            secondsAfterStart: _startTime.difference(moveTime).inSeconds,
            x: move.x,
            y: move.y),
      );

      log("Move played ${_moves.last.toJson()}");

      if (hasPassedTwice()) {
        log("Setting score calc");
        _setScoreCalculationStage();
      } else {
        _setTimes(moveTime);
      }

      return right(getGame());
    } on Exception catch (e) {
      return left(AppError(message: e.toString()));
    }
  }

  void _setScoreCalculationStage() {
    assert(_gameState == GameState.playing, "Game is not in playing state");
    assert(hasPassedTwice(), "Both players haven't passed twice");

    _gameState = GameState.scoreCalculation;
    _timer.cancel();
  }

  void _setTimes(DateTime time) {
    var times = timeCalculator.recalculateTurnPlayerTimeSnapshots(
      StoneType.values[turnPlayer],
      _playerTimeSnapshots,
      _timeControl,
      time,
    );

    _playerTimeSnapshots = times;

    var turnPlayerMS = _playerTimeSnapshots[turnPlayer].mainTimeMilliseconds;
    if (turnPlayerMS != 0) {
      _timer.cancel();
      _timer = Timer(Duration(milliseconds: turnPlayerMS), _timeoutTimer);

      log("Reset clock to ${_playerTimeSnapshots[turnPlayer].mainTimeMilliseconds / 1000} seconds");
    }
  }

  void _timeoutTimer() {
    _setTimes(now);

    if (_playerTimeSnapshots[turnPlayer].mainTimeMilliseconds == 0) {
      _endGame(GameOverMethod.Timeout, StoneType.values[turnPlayer].other);
      _timer.cancel();
    }

    gameUpdateC.add(
      GameUpdate(
        game: getGame(),
        curPlayerTimeSnapshot: _playerTimeSnapshots[turnPlayer],
        playerWithTurn: StoneType.values[turnPlayer],
      ),
    );
  }

  Either<AppError, Game> resignGame(StoneType playerStone) {
    if (_gameState == GameState.ended) {
      return left(AppError(message: "Game is already ended"));
    }

    _endGame(GameOverMethod.Resign, playerStone.other);

    return right(getGame());
  }

  Either<AppError, Game> acceptScores(StoneType stone) {
    if (_gameState != GameState.scoreCalculation) {
      return left(AppError(message: "Game is not in score calculation stage"));
    }

    _scoresAcceptedBy.add(stone);

    if (_scoresAcceptedBy.length == 2) {
      _endGame(GameOverMethod.Score, null);
    }

    return right(getGame());
  }

  Either<AppError, Game> continueGame() {
    _gameState = GameState.playing;
    _stoneStates.clear();
    _scoresAcceptedBy.clear();

    return right(getGame());
  }

  Either<AppError, Game> editDeadStone(
      StoneType stone, Position pos, DeadStoneState state) {
    if (_gameState != GameState.scoreCalculation) {
      throw Exception("Game is not in score calculation stage");
    }

    _scoresAcceptedBy.clear();

    if (_stoneStates[pos] != state) {
      final newBoard = boardUtils.boardStateFromGame(getGame());

      for (var pos in (newBoard.playgroundMap[pos]?.cluster.data ?? {})) {
        _stoneStates[pos] = state;
      }
    }

    return right(getGame());
  }

  void _endGame(
    GameOverMethod method,
    StoneType? winner,
  ) {
    final List<int> scores = [];
    final stoneLogic = StoneLogic(getGame());

    if (method == GameOverMethod.Score) {
      final calc = ScoreCalculator(
        rows: _rows,
        cols: _columns,
        komi: _komi,
        deadStones: deadStones,
        prisoners: _prisoners,
        playground: stoneLogic.board.playgroundMap,
      );

      scores.addAll(calc.score);
      winner = StoneType.values[calc.winner];
    }

    _gameState = GameState.ended;
    _playerTimeSnapshots = [
      _playerTimeSnapshots[0].copyWith(timeActive: false),
      _playerTimeSnapshots[1].copyWith(timeActive: false),
    ];
    _finalScores = scores;
    _result = winner?.resultForIWon;
    _gameOverMethod = method;
    _endTime = now;
    _timer.cancel();

    gameUpdateC.add(
      GameUpdate(
        game: getGame(),
        curPlayerTimeSnapshot: _playerTimeSnapshots[turnPlayer],
        playerWithTurn: StoneType.values[turnPlayer],
      ),
    );
  }

  // Helpers
  bool hasPassedTwice() {
    GameMove? prev;
    bool hasPassedTwice = false;
    for (var i in (_moves).reversed) {
      if (prev == null) {
        prev = i;
        continue;
      }
      if (i.isPass() && prev.isPass()) {
        hasPassedTwice = !hasPassedTwice;
      } else {
        break;
      }
    }
    return hasPassedTwice;
  }
}
