// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/modules/gameplay/middleware/local_gameplay_server.dart';
import 'package:go/modules/gameplay/middleware/score_calculator.dart';
import 'package:go/modules/gameplay/middleware/time_calculator.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/game_and_opponent.dart';
import 'package:go/services/user_account.dart';
import 'package:signalr_netcore/errors.dart';

import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/services/player_rating.dart';

// HACK: `GameUpdate` object is a hack as signalR messages don't always give the full game state
extension GameExt on Game {
  GameUpdate toGameUpdate() {
    return GameUpdate(
      game: this,
      curPlayerTimeSnapshot: didStart()
          ? playerTimeSnapshots[
              getStoneFromPlayerId(getPlayerIdWithTurn()!)!.index]
          : null,
      playerWithTurn:
          didStart() ? getStoneFromPlayerId(getPlayerIdWithTurn()!) : null,
    );
  }
}

extension GameUpdateExt on GameUpdate {
  Game makeCopyFromOldGame(Game game) {
    // REVIEW: this works for now,
    // but it might have some nullability issues down the line.
    // e.g. if the new game updated some value to a null value, it would be ignored by `??` operator.
    // In this case the update won't be communicated.
    var newGame = Game(
      gameId: this.game?.gameId ?? game.gameId,
      rows: this.game?.rows ?? game.rows,
      columns: this.game?.columns ?? game.columns,
      timeControl: this.game?.timeControl ?? game.timeControl,
      playgroundMap: this.game?.playgroundMap ?? game.playgroundMap,
      moves: this.game?.moves ?? game.moves,
      players: this.game?.players ?? game.players,
      prisoners: this.game?.prisoners ?? game.prisoners,
      startTime: this.game?.startTime ?? game.startTime,
      koPositionInLastMove:
          this.game?.koPositionInLastMove ?? game.koPositionInLastMove,
      gameState: this.game?.gameState ?? game.gameState,
      deadStones: this.game?.deadStones ?? game.deadStones,
      result: this.game?.result ?? game.result,
      komi: this.game?.komi ?? game.komi,
      finalTerritoryScores:
          this.game?.finalTerritoryScores ?? game.finalTerritoryScores,
      gameOverMethod: this.game?.gameOverMethod ?? game.gameOverMethod,
      endTime: this.game?.endTime ?? game.endTime,
      stoneSelectionType:
          this.game?.stoneSelectionType ?? game.stoneSelectionType,
      gameCreator: this.game?.gameCreator ?? game.gameCreator,
      playerTimeSnapshots:
          this.game?.playerTimeSnapshots ?? game.playerTimeSnapshots,
      playersRatingsAfter:
          this.game?.playersRatingsAfter ?? game.playersRatingsAfter,
      playersRatingsDiff:
          this.game?.playersRatingsDiff ?? game.playersRatingsDiff,
      gameType: GameType.anonymous,
      creationTime: this.game?.creationTime ?? game.creationTime,
      usernames: this.game?.usernames ?? game.usernames,
    );

    var tmpTimes = [...newGame.playerTimeSnapshots];

    if (playerWithTurn != null && curPlayerTimeSnapshot != null) {
      var idx = playerWithTurn!.index;
      tmpTimes[idx] = curPlayerTimeSnapshot!;
    }

    return newGame.copyWith(playerTimeSnapshots: tmpTimes);
  }
}

class GameUpdate {
  final Game? game;
  final PlayerTimeSnapshot? curPlayerTimeSnapshot;
  final StoneType? playerWithTurn;
  final Position? deadStonePosition;
  final DeadStoneState? deadStoneState;

  GameUpdate({
    this.game,
    this.curPlayerTimeSnapshot,
    this.playerWithTurn,
    this.deadStonePosition,
    this.deadStoneState,
  });

  get state => null;
}

abstract class GameStateOracle {
  final StreamController<GameUpdate> gameUpdateC = StreamController.broadcast();
  Stream<GameUpdate> get gameUpdate => gameUpdateC.stream;

  DisplayablePlayerData myPlayerData(Game game);
  DisplayablePlayerData? otherPlayerData(Game game);

  Future<Either<AppError, Game>> resignGame(Game game);
  Future<Either<AppError, Game>> acceptScores(Game game);
  Future<Either<AppError, Game>> continueGame(Game game);
  Future<Either<AppError, Game>> playMove(Game game, MovePosition move);
  Future<Either<AppError, Game>> editDeadStoneCluster(
      Game game, Position pos, DeadStoneState state);

  bool isThisAccountsTurn(Game game);
  StoneType thisAccountStone(Game game);
}

class LiveGameOracle extends GameStateOracle {
  final Api api;
  final AuthProvider authBloc;
  final SignalRProvider signalRbloc;
  final PlayerRating? ratings;

  late final List<StreamSubscription> subscriptions;
  late final Stream<GameJoinMessage> listenForGameJoin;
  late final Stream<GameStartMessage> listenForGameStart;
  late final Stream<EditDeadStoneMessage> listenForEditDeadStone;
  late final Stream<NewMoveMessage> listenFromMove;
  late final Stream<GameOverMessage> listenFromGameOver;
  late final Stream<GameTimerUpdateMessage> listenFromGameTimerUpdate;
  late final Stream<Null> listenFromAcceptScores;
  late final Stream<ContinueGameMessage> listenFromContinueGame;

  void setupStreams() {
    var gameMessageStream = signalRbloc.gameMessageStream;
    var userMessageStream = signalRbloc.userMessagesStream;

    listenForGameJoin = userMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.gameJoin) {
        yield message.data as GameJoinMessage;
      }
    });

    listenForGameStart = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.gameStart) {
        yield message.data as GameStartMessage;
      }
    });

    listenForEditDeadStone = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.editDeadStone) {
        yield message.data as EditDeadStoneMessage;
      }
    });

    listenFromMove = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.newMove) {
        yield message.data as NewMoveMessage;
      }
    });

    listenFromContinueGame = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.continueGame) {
        yield message.data as ContinueGameMessage;
      }
    });

    listenFromAcceptScores = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.acceptedScores) {
        yield message.data as Null;
      }
    });

    listenFromGameOver = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.gameOver) {
        yield message.data as GameOverMessage;
      }
    });

    listenFromGameTimerUpdate = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.gameTimerUpdate) {
        yield message.data as GameTimerUpdateMessage;
      }
    });
  }

  LiveGameOracle({
    required this.api,
    required this.authBloc,
    required this.signalRbloc,
    required this.ratings,
    GameAndOpponent? joiningData,
  }) {
    if (joiningData != null) {
      otherPlayerInfo = joiningData.opponent;
    }
    setupStreams();

    subscriptions = [
      listenFromGameJoin(),
      listenFromGameStart(),
      listenForMove(),
      listenForContinueGame(),
      listenForAcceptScore(),
      listenForGameOver(),
      listenForGameTimerUpdate()
    ];
  }

  StreamSubscription listenFromGameJoin() {
    return listenForGameJoin.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.gameJoin}::\n\t\t${message.toMap()}");
      otherPlayerInfo = message.otherPlayerData;
      gameUpdateC.add(message.game.toGameUpdate());
    });
  }

  StreamSubscription listenFromGameStart() {
    return listenForGameStart.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.gameStart}::\n\t\t${message.toMap()}");
      gameUpdateC.add(message.game.toGameUpdate());
    });
  }


  StreamSubscription listenForContinueGame() {
    return listenFromContinueGame.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.continueGame}::\n\t\t${message.toMap()}");
      gameUpdateC.add(message.game.toGameUpdate());
    });
    // signalRbloc.hubConnection.on('gameMove', (data) {});
  }

  StreamSubscription listenForMove() {
    return listenFromMove.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.newMove}::\n\t\t${message.toMap()}");
      // assert(data != null, "Game move data can't be null");
      gameUpdateC.add(message.game.toGameUpdate());
    });
    // signalRbloc.hubConnection.on('gameMove', (data) {});
  }

  StreamSubscription listenForAcceptScore() {
    return listenFromAcceptScores.listen((message) {
      debugPrint("Signal R said, ::${SignalRMessageTypes.acceptedScores}::");
      // TODO: this event isn't transferred over to game state bloc as that does nothing with it
    });
  }

  StreamSubscription listenForGameOver() {
    return listenFromGameOver.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.gameOver}::\n\t\t${message.toMap()}");
      gameUpdateC.add(message.game.toGameUpdate());
    });
  }

  StreamSubscription listenForGameTimerUpdate() {
    return listenFromGameTimerUpdate.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.gameTimerUpdate}::\n\t\t${message.toMap()}");

      gameUpdateC.add(GameUpdate(
        curPlayerTimeSnapshot: message.currentPlayerTime,
        playerWithTurn: message.player,
      ));
    });
  }

  // TODO: listenForGameJoin + update otherPlayerInfo there

  PublicUserInfo? otherPlayerInfo;

  AbstractUserAccount get myPlayerUserInfo => authBloc.currentUserAccount;

  @override
  DisplayablePlayerData myPlayerData(Game game) {
    var publicInfo = myPlayerUserInfo.getPublicUserInfo(ratings);
    var rating = publicInfo.rating?.getRatingForGame(game);
    StoneType? stone;

    if (game.didStart()) {
      stone = game.getStoneFromPlayerId(publicInfo.id);
    } else if (game.gameCreator == publicInfo.id) {
      stone = game.stoneSelectionType.type;
    }

    return DisplayablePlayerData(
        displayName: publicInfo.username ?? "Anonymous",
        stoneType: stone,
        rating: game.didEnd()
            ? stone?.getValueFromPlayerList(game.ratingsBefore())
            : rating?.glicko.minimal,
        ratingDiffOnEnd:
            stone?.getValueFromPlayerList(game.playersRatingsDiff));
  }

  @override
  DisplayablePlayerData? otherPlayerData(Game game) {
    var publicInfo = otherPlayerInfo;
    var rating = publicInfo?.rating?.getRatingForGame(game);
    StoneType? stone;

    if (game.didStart()) {
      stone = game.getStoneFromPlayerId(publicInfo!.id);
    } else if (game.gameCreator == publicInfo?.id) {
      stone = game.stoneSelectionType.type;
    }

    if (publicInfo == null) {
      return null;
    }

    return DisplayablePlayerData(
        displayName: publicInfo.username ?? "Anonymous",
        stoneType: stone,
        rating: game.didEnd()
            ? stone?.getValueFromPlayerList(game.ratingsBefore())
            : rating?.glicko.minimal,
        ratingDiffOnEnd:
            stone?.getValueFromPlayerList(game.playersRatingsDiff));
  }

  @override
  Future<Either<AppError, Game>> resignGame(Game game) async {
    return (await api.resignGame(authBloc.token!, game.gameId));
  }

  @override
  Future<Either<AppError, Game>> acceptScores(Game game) async {
    return (await api.acceptScores(authBloc.token!, game.gameId));
  }

  @override
  Future<Either<AppError, Game>> continueGame(Game game) async {
    return (await api.continueGame(authBloc.token!, game.gameId));
  }

  @override
  Future<Either<AppError, Game>> playMove(Game game, MovePosition move) async {
    // final sl = StoneLogic(game);

    // if (!move.isPass()) {
    //   sl.handleStoneUpdate(Position(move.x!, move.y!), thisAccountStone(game));
    // }

    return (await api.makeMove(move, authBloc.token!, game.gameId))
        .map((a) => a.game);
  }

  @override
  Future<Either<AppError, Game>> editDeadStoneCluster(
      Game game, Position pos, DeadStoneState state) async {
    final res = await api.editDeadStoneCluster(
      EditDeadStoneClusterDto(position: pos, state: DeadStoneState.Alive),
      authBloc.token!,
      game.gameId,
    );
    return res;
  }

  @override
  bool isThisAccountsTurn(Game game) {
    return game.getPlayerIdWithTurn() == authBloc.myId;
  }

  @override
  StoneType thisAccountStone(Game game) {
    return game.getStoneFromPlayerId(authBloc.myId)!;
  }
}

// This assumes the game is already started at time of creation
// This assumes the two player's ids are "bottom" and "top"

class FaceToFaceGameOracle extends GameStateOracle {
  final LocalGameplayServer gp;

  FaceToFaceGameOracle(this.gp) {
    gameUpdateC.addStream(gp.gameUpdate);
  }

  String get myPlayerId => "bottom";
  String get otherPlayerId => "top";

  @override
  DisplayablePlayerData myPlayerData(Game game) {
    StoneType stone = game.getStoneFromPlayerId(myPlayerId)!;

    return DisplayablePlayerData(
        displayName: stone.color,
        stoneType: stone,
        rating: null, // No rating for face to face games
        ratingDiffOnEnd: null);
  }

  @override
  DisplayablePlayerData otherPlayerData(Game game) {
    StoneType stone = game.getStoneFromPlayerId(otherPlayerId)!;

    return DisplayablePlayerData(
        displayName: stone.color,
        stoneType: stone,
        rating: null, // No rating for face to face games
        ratingDiffOnEnd: null);
  }

  @override
  Future<Either<AppError, Game>> resignGame(Game game) async {
    return gp.resignGame(thisAccountStone(game));
  }

  @override
  Future<Either<AppError, Game>> acceptScores(Game game) async {
    return gp.acceptScores(thisAccountStone(game));
  }

  @override
  Future<Either<AppError, Game>> continueGame(Game game) async {
    return gp.continueGame();
  }

  @override
  Future<Either<AppError, Game>> playMove(Game game, MovePosition move) async {
    var newGame = gp.makeMove(move, thisAccountStone(game));
    return newGame;
  }

  Future<Either<AppError, Game>> editDeadStoneCluster(
      Game game, Position pos, DeadStoneState state) async {
    return gp.editDeadStone(thisAccountStone(game), pos, state);
  }

  @override
  bool isThisAccountsTurn(Game game) {
    return true;
  }

  @override
  StoneType thisAccountStone(Game game) {
    return game.getStoneFromPlayerId(game.getPlayerIdWithTurn()!)!;
  }
}
