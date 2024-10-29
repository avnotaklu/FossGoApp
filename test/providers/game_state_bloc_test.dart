import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/api_error.dart';
import 'package:go/core/system_utilities.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/playfield/board_utilities.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/app_user.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/new_move_result.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockApi extends Mock implements Api {}

class MockAuth extends Mock implements AuthProvider {}

class MockSignalR extends Mock implements SignalRProvider {}

class MockSystemUtilities extends Mock implements SystemUtilities {}

// class FakeMovePosition extends Mock implements MovePosition {
//   @override
//   final int? x;
//   @override
//   final int? y;
//   FakeMovePosition({
//     required this.x,
//     required this.y,
//   });
// }

void main() {
  late MockApi api;
  late List<GameMove> moves;
  final a1 = MovePosition(x: 0, y: 0);
  final a2 = MovePosition(x: 1, y: 0);

  // setUpAll(() {
  registerFallbackValue(a1);
  registerFallbackValue(a2);
  // registerFallbackValue(MovePosition(x: 1, y: 0));
  // });

  // User 1 things
  late MockAuth auth;
  late MockSignalR signalR;
  late GameStateBloc bloc;
  late StreamController<SignalRMessage> signalRController1;
  late DateTime currentTime;
  late MockSystemUtilities utils;

  // User 2 things
  late MockAuth auth2;
  late MockSignalR signalR2;
  late GameStateBloc bloc2;
  late StreamController<SignalRMessage> signalRController2;
  late DateTime currentTime2;
  late MockSystemUtilities utils2;

  // Don't setup, these are required to be consistent for all tests
  currentTime = _1980Jan1_1_30PM;
  currentTime2 = _1980Jan1_1_30PM;
  moves = [];

  // setUp(() {
  // User 1
  auth = MockAuth();
  signalR = MockSignalR();
  signalRController1 = StreamController<SignalRMessage>.broadcast();
  utils = MockSystemUtilities();

  // User 2
  auth2 = MockAuth();
  signalR2 = MockSignalR();
  signalRController2 = StreamController<SignalRMessage>.broadcast();
  utils2 = MockSystemUtilities();

  // Global
  api = MockApi();

  // User 1
  when(() => auth.currentUserRaw).thenReturn(
    AppUser(id: "1", email: "1@1.com"),
  );

  when(() => auth.token).thenReturn(
    "token1",
  );

  when(() => signalR.gameMessageStream).thenAnswer(
    (_) => signalRController1.stream,
  );
  when(() => utils.currentTime).thenAnswer((inv) => currentTime);

  // User 2
  when(() => auth2.currentUserRaw).thenReturn(
    AppUser(id: "2", email: "2@2.com"),
  );

  when(() => auth2.token).thenReturn(
    "token2",
  );

  when(() => signalR2.gameMessageStream).thenAnswer(
    (_) => signalRController2.stream,
  );
  when(() => utils2.currentTime).thenAnswer((inv) => currentTime2);

  when(() => api.makeMove(any(), any(), any())).thenAnswer((inv) async {
    var token = inv.positionalArguments[1] as String;

    var newMove = GameMove(
      time: (token == 'token1') ? currentTime : currentTime2,
      x: (inv.positionalArguments[0] as MovePosition).x,
      y: (inv.positionalArguments[0] as MovePosition).y,
      // y: 0,
    );
    moves = [...moves, newMove];

    var gameResult = gameConstructor(
        getBoardForMoveCount()[moves.length](), _1980Jan1_1_30PM, moves);

    // Api takees 1 second to send the signalR message
    if (token == 'token1') {
      currentTime2 = currentTime.add(const Duration(seconds: 1));
      // currentTime2 = currentTime2
      signalRController2.add(SignalRMessage(
        type: SignalRMessageTypes.newMove,
        data: NewMoveMessage(gameResult),
      ));
    }

    if (token == 'token2') {
      currentTime = currentTime2.add(const Duration(seconds: 1));
      signalRController1.add(SignalRMessage(
        type: SignalRMessageTypes.newMove,
        data: NewMoveMessage(gameResult),
      ));
    }

    return right<ApiError, NewMoveResult>(
        NewMoveResult(game: gameResult, result: true));
  });
  // });

  final sGame = gameConstructor(simpleBoard(), _1980Jan1_1_30PM);
  const curStage = StageType.Gameplay;

  // joins game on client1 when constructing gameStateBloc
  bloc = GameStateBloc(api, signalR, auth, sGame, utils, curStage, null);

  // Join Message recieved from server

  final joinMessage = GameJoinMessage(
    // The time server says the user joined at
    time: currentTime,
    players: [player1(), player2()],
    game: sGame,
  );

  // 1 second lag between server and client
  currentTime = currentTime.add(const Duration(seconds: 1));

  signalRController1.add(SignalRMessage(
    type: SignalRMessageTypes.newMove,
    data: joinMessage,
  ));

  // joins game on client2 when constructing gameStateBloc
  bloc2 =
      GameStateBloc(api, signalR2, auth2, sGame, utils2, curStage, joinMessage);

  group("GameStateBloc", () {
    // test("30 minutes passed in mock", () {
    //   currentTime = currentTime.add(const Duration(minutes: 30));
    //   expect(
    //       _1980Jan1_1_30PM.add(const Duration(minutes: 30)), utils.currentTime);
    // });

    test("Join delay should be player 1: 1 second, player 2: 0 seconds",
        () async {
      await pumpEventQueue();

      expect(bloc2.times[0].value.inSeconds, 300);
      expect(bloc2.times[1].value.inSeconds, 300);

      // After bloc 1 has recieved the join message, we need to incorporate server lag
      expect(bloc.times[0].value.inSeconds, 299);
      expect(bloc.times[1].value.inSeconds, 300);
    });

    test(
        "Player 1 time should be 3 seconds less than what he started at i.e. 299",
        () async {
      // 3 seconds spent playing first move
      currentTime = currentTime.add(const Duration(seconds: 3));

      await bloc.playMove(a1);

      expect(bloc.times[0].value.inSeconds, 296);
      expect(bloc.times[1].value.inSeconds, 300);
    });

    test("Player 2 should have accurate time considering 1 second A1",
        () async {
      // 3 seconds spent playing first move
      // currentTime = currentTime.add(const Duration(seconds: 3));

      // await bloc.playMove(a1);

      // expect(bloc.times[1].value.inSeconds, 299);
      await pumpEventQueue();
      expect(bloc2.times[0].value.inSeconds, 296);
      expect(bloc2.times[1].value.inSeconds, 299);
    });

    test("Player 2 played his move after 5 seconds", () async {
      // 3 seconds spent playing first move
      // currentTime = currentTime.add(const Duration(seconds: 3));

      // player 2 uses 5 seconds to play his move
      currentTime2 = currentTime2.add(const Duration(seconds: 5));

      await bloc2.playMove(a2);

      expect(bloc2.times[0].value.inSeconds, 296);
      expect(bloc2.times[1].value.inSeconds, 294);
    });

    test("Player 1 should have accurate time considering 1 second lag of A2",
        () async {
      // 3 seconds spent playing first move
      // currentTime = currentTime.add(const Duration(seconds: 3));

      // await bloc.playMove(a1);

      // expect(bloc.times[1].value.inSeconds, 299);
      await pumpEventQueue();
      expect(bloc.times[0].value.inSeconds, 295);
      expect(bloc.times[1].value.inSeconds, 294);
    });
  });
}

PublicUserInfo player1() {
  return PublicUserInfo("1@1.com", "1");
}

PublicUserInfo player2() {
  return PublicUserInfo("2@2.com", "2");
}

List<List<List<int>> Function()> getBoardForMoveCount() {
  return [
    simpleBoard,
    simpleBoardA1,
    simpleBoardA2,
  ];
}

List<List<int>> simpleBoardA2() {
  return [
    /* 
     a  b  c  d  e */
    [1, 0, 0, 0, 0], // 1
    [1, 0, 0, 0, 0], // 2
    [0, 0, 0, 0, 0], // 3
    [0, 0, 0, 0, 0], // 4
    [0, 0, 0, 0, 0], // 5
  ];
}

List<List<int>> simpleBoardA1() {
  return [
    /* 
     a  b  c  d  e */
    [1, 0, 0, 0, 0], // 1
    [0, 0, 0, 0, 0], // 2
    [0, 0, 0, 0, 0], // 3
    [0, 0, 0, 0, 0], // 4
    [0, 0, 0, 0, 0], // 5
  ];
}

List<List<int>> simpleBoard() {
  return [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
  ];
}

// Game simpleGameConstructor(List<List<int>> board) {
// }

Game gameConstructor(
  List<List<int>> board,
  DateTime startTime, [
  List<GameMove> moves = const [],
  List<int> scores = const [0, 0],
  int timeInSeconds = 300,
]) {
  var rows = board.length;
  var cols = board[0].length;
  var boardState = BoardStateUtilities(rows, cols);
  Position? koPosition;
  return Game(
    gameId: "Test",
    rows: rows,
    columns: cols,
    timeInSeconds: timeInSeconds, // 5 minutes
    playgroundMap: boardState.MakeHighLevelBoardRepresentationFromBoardState(
        boardState.BoardStateFromSimpleRepr(
      board,
      koPosition,
    )),
    moves: moves,
    players: {"1": StoneType.black, "2": StoneType.white},
    playerScores: {"1": scores[0], "2": scores[1]},
    startTime: startTime,
    koPositionInLastMove: koPosition,
    gameState: GameState.playing,
  );
}

final _1980Jan1_1_30PM = DateTime(1980, 1, 1, 13, 30);
