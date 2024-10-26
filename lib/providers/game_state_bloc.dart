import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go/gameplay/stages/score_calculation_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/game_move_dto.dart';
import 'package:go/services/join_message.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/utils/player.dart';
import 'package:ntp/ntp.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:timer_count_down/timer_controller.dart';

class GameStateBloc extends ChangeNotifier {
  final List<Player> _players = [];
  List<Player> get players => List.unmodifiable(_players);
  Api api = Api();
  int get turn => game.moves.length;
  final AuthProvider authBloc;
  final SignalRProvider signalRbloc;

  int get gametime => game.timeInSeconds;

  Player get getPlayerWithTurn => _players[turn % 2];
  Player get getPlayerWithoutTurn => _players[turn % 2 == 0 ? 1 : 0];

  // Join Data
  DateTime? _startTime;
  Game game;
  PublicUserInfo myPlayerInfo;
  PublicUserInfo? otherPlayerInfo;

  Set<Position> finalRemovedCluster = {};

  final List<CountdownController> _controller = [
    CountdownController(autoStart: false),
    CountdownController(autoStart: false)
  ];

  List<CountdownController> get timerController => _controller;

  ValueNotifier<StageType> curStageTypeNotifier;
  StageType get cur_stage_type => curStageTypeNotifier.value;
  set cur_stage_type(StageType stage) {
    // cur_stage.disposeStage();
    curStageTypeNotifier.value = stage;
  }

  Stage curStage;

  GameStateBloc(this.signalRbloc, this.authBloc, this.game, this.curStage)
      : curStageTypeNotifier = ValueNotifier(curStage.getType),
        myPlayerInfo = PublicUserInfo(
            authBloc.currentUserRaw!.email, authBloc.currentUserRaw!.id) {
    _players.add(Player(0));
    _players.add(Player(1));

    listenFromGameJoin();
    moveListener();
    setupStreams();
  }

  // Stream<bool> listenForGameEndRequest() {
  //   return signalRbloc.gameMessageController.stream
  //       .where((message) => message.placeholder is bool)
  //       .cast();
  // }

  late final Stream<bool> listenFromOpponentConfirmation;
  late final Stream<(bool, Position)> listenFromRemovedCluster;
  late final Stream<GameMove> listenFromMove;

  void setupStreams() {
    listenFromOpponentConfirmation = signalRbloc.gameMessageController.stream
        .where((message) => message.placeholder is bool)
        .cast();
    listenFromRemovedCluster = signalRbloc.gameMessageController.stream
        .where((message) => message.placeholder is (bool, Position))
        .cast();
    listenFromMove = signalRbloc.gameMessageController.stream
        .where((message) => message.placeholder is GameMove)
        .cast();
  }

  void listenFromGameJoin() {
    signalRbloc.hubConnection.on('gameUpdate',
        (SignalRMessageListRaw? messagesRaw) {
      assert(messagesRaw != null, "Game Join data can't be null");
      var messageList = messagesRaw!.signalRMessageList;
      if (messageList.length != 1) {
        throw "messages count ${messageList.length}, WHAT TO DO?";
      }
      var message = messageList.first;
      if (message.type == "GameJoin") {
        debugPrint("Joining game BAHAHA");
        final joinMessage = (message.data as GameJoinMessage);
        joinGame(joinMessage);
        debugPrint("Joined game BAHAHA");
        notifyListeners();
      }
    });
  }

  void joinGame(GameJoinMessage joinMessage) {
    _startTime = DateTime.parse((joinMessage.time));
    game = joinMessage.game;

    var myPlayerInfoIndex = joinMessage.players
        .indexWhere((element) => element.id == authBloc.currentUserRaw!.id);

    myPlayerInfo = joinMessage.players[myPlayerInfoIndex];
    otherPlayerInfo = joinMessage.players[myPlayerInfoIndex == 0 ? 1 : 0];

    startPausedTimerOfActivePlayer();
    cur_stage_type = StageType.Gameplay;
  }

  StreamSubscription moveListener() {
    return signalRbloc.gameMessageController.stream.listen((data) {
      // assert(data != null, "Game move data can't be null");
      final move = GameMove.fromJson(data.placeholder as String);
      applyMove(move);
    });
    // signalRbloc.hubConnection.on('gameMove', (data) {});
  }

  Future<GameMove> playMove(GameMoveDto moveDto) async {
    final time = await NTP.now();
    // TODO: Call api here

    final move = GameMove(
        playerId: moveDto.playerId, playedAt: time, x: moveDto.x, y: moveDto.y);

    applyMove(move);

    return move;
  }

  void applyMove(GameMove move) {
    game.moves.add(move);
    toggleTurn();

    if (hasPassedTwice()) {
      cur_stage_type = StageType.ScoreCalculation;
      // ScoreCalculationStage(context);
    }

    notifyListeners();
  }

  void toggleTurn() {
    int turn = this.turn;
    timerController[turn % 2].pause();
    turn += 1;
    timerController[turn % 2].pause();
  }

  void endGame() {
    // TODO: call api here
  }

  bool isMyTurn() {
    return game.players[turn % 2] == authBloc.currentUserRaw!.id;
  }

  bool hasPassedTwice() {
    var prev;
    bool hasPassedTwice = false;
    for (var i in (game.moves).reversed) {
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

  void unsetFinalRemovedCluster() {
    finalRemovedCluster = {};

    // TODO: call api to reset final removed cluster??
    // MultiplayerData.of(context)?.curGameReferences?.gameEndData.remove();
  }

  void continueGame() {
    // TODO: call api to continue game
  }

  void confirmGameEnd() {
    // TODO: call api to end game
  }

  void startPausedTimerOfActivePlayer() {
    timerController[getPlayerWithTurn.turn].start();
  }

  void removeClusterFromRemovedClusters(Cluster cluster) {
    // TODO: call api
  }

  void addClusterToRemovedClusters(Cluster cluster) {
    // TODO: call api
  }

  Set<Cluster> getRemovedClusters() {
    return {};
    // TODO: call api
  }

  int getRemotePlayerIndex() {
    final index = game.players[(authBloc.currentUserRaw)!.id];
    // game.players.indexWhere((k) => k != (authBloc.currentUserRaw)!.id);
    if (index == null) {
      throw ("remote player not found");
    }
    return 1 - index;
  }

  int getClientPlayerIndex() {
    final index = game.players[(authBloc.currentUserRaw)!.id];
    // final index =
    //     game.players.indexWhere((k) => k == (authBloc.currentUserRaw)!.id);
    if (index == null) {
      throw ("client player not found");
    }
    return 1 - index;
  }
}
