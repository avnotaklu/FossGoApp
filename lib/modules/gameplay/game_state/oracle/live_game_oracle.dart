
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/modules/gameplay/game_state/game_entrance_data.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
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

class LiveGameOracle extends GameStateOracle {
  final Api api;
  final AuthProvider authBloc;
  final SignalRProvider signalRbloc;
  final PlayerRating? ratings;

  late final List<StreamSubscription> subscriptions;
  late final Stream<GameJoinMessage> listenFromGameJoin;
  late final Stream<GameStartMessage> listenFromGameStart;
  late final Stream<EditDeadStoneMessage> listenFromEditDeadStone;
  late final Stream<NewMoveMessage> listenFromMove;
  late final Stream<GameOverMessage> listenFromGameOver;
  late final Stream<GameTimerUpdateMessage> listenFromGameTimerUpdate;
  late final Stream<Null> listenFromAcceptScores;
  late final Stream<ContinueGameMessage> listenFromContinueGame;
  late final Stream<ConnectionStrength> listenFromOpponentConnection;

  DateTime? playersJoinTime;

  @override
  Stream<ConnectionStrength>? get opponentConnection =>
      listenFromOpponentConnection;

  void setupStreams() {
    var gameMessageStream = signalRbloc.gameMessageStream;
    var userMessageStream = signalRbloc.userMessagesStream;

    listenFromGameJoin = userMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.gameJoin) {
        yield message.data as GameJoinMessage;
      }
    });

    listenFromGameStart = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.gameStart) {
        yield message.data as GameStartMessage;
      }
    });

    listenFromEditDeadStone = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.editDeadStone) {
        yield message.data as EditDeadStoneMessage;
      }
    });

    listenFromMove = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.newMove) {
        final moveMessage = message.data as NewMoveMessage;
        moveUpdateC.add(moveMessage.game.moves.last);
        yield moveMessage;
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
        final gameOverMessage = message.data as GameOverMessage;
        gameEndC.add(null);
        yield gameOverMessage;
      }
    });

    listenFromGameTimerUpdate = gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.gameTimerUpdate) {
        yield message.data as GameTimerUpdateMessage;
      }
    });

    listenFromOpponentConnection =
        gameMessageStream.asyncExpand((message) async* {
      if (message.type == SignalRMessageTypes.opponentConnection) {
        yield message.data as ConnectionStrength;
      }
    });
  }

  LiveGameOracle({
    required this.api,
    required this.authBloc,
    required this.signalRbloc,
    required this.ratings,
    required this.systemUtilities,
    GameEntranceData? joiningData,
  }) {
    if (joiningData != null) {
      playersJoinTime = joiningData.joinTime;
      otherPlayerInfo = joiningData.otherPlayerData;
    }

    setupStreams();

    subscriptions = [
      listenForGameJoin(),
      listenForGameStart(),
      listenForMove(),
      listenForContinueGame(),
      listenForAcceptScore(),
      listenForGameOver(),
      listenForGameTimerUpdate(),
      listenForOpponentConnection(),
      listenForEditDeadStone()
    ];
  }

  StreamSubscription listenForGameJoin() {
    return listenFromGameJoin.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.gameJoin}::\n\t\t${message.toMap()}");
      otherPlayerInfo = message.otherPlayerData;
      playersJoinTime = message.joinTime;
      gameUpdateC.add(message.game.toGameUpdate());
    });
  }

  StreamSubscription listenForGameStart() {
    return listenFromGameStart.listen((message) {
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

  StreamSubscription listenForOpponentConnection() {
    return listenFromOpponentConnection.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.opponentConnection}::\n\t\t${message.toMap()}");
    });
  }

  StreamSubscription listenForEditDeadStone() {
    return listenFromEditDeadStone.listen((message) {
      debugPrint(
          "Signal R said, ::${SignalRMessageTypes.editDeadStone}::\n\t\t${message.toMap()}");
      gameUpdateC.add(GameUpdate(
        deadStonePosition: message.position,
        deadStoneState: message.state,
      ));
    });
  }

  PublicUserInfo? otherPlayerInfo;

  AbstractUserAccount get myPlayerUserInfo => authBloc.currentUserAccount;

  final SystemUtilities systemUtilities;

  @override
  Duration get headsUpTime =>
      const Duration(seconds: 10) -
      systemUtilities.currentTime.difference(playersJoinTime!);

  @override
  DisplayablePlayerData myPlayerData(Game game) {
    var publicInfo = myPlayerUserInfo.getPublicUserInfo(ratings);
    var rating = publicInfo.rating?.getRatingForGame(game);
    StoneType? stone;

    if (game.bothPlayersIn()) {
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
      ratingDiffOnEnd: stone?.getValueFromPlayerList(game.playersRatingsDiff),
      komi: stone?.komi(game),
      prisoners: stone?.prisoners(game),
      score: stone?.score(game),
    );
  }

  @override
  DisplayablePlayerData? otherPlayerData(Game game) {
    var publicInfo = otherPlayerInfo;
    var rating = publicInfo?.rating?.getRatingForGame(game);
    StoneType? stone;

    if (game.bothPlayersIn()) {
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
      ratingDiffOnEnd: stone?.getValueFromPlayerList(game.playersRatingsDiff),
      komi: stone?.komi(game),
      prisoners: stone?.prisoners(game),
      score: stone?.score(game),
    );
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
    return (await api.makeMove(move, authBloc.token!, game.gameId))
        .map((a) => a.game);
  }

  @override
  Future<Either<AppError, Game>> editDeadStoneCluster(
      Game game, Position pos, DeadStoneState state) async {
    final res = await api.editDeadStoneCluster(
      EditDeadStoneClusterDto(position: pos, state: state),
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

  @override
  GamePlatform getPlatform() {
    return GamePlatform.online;
  }
}