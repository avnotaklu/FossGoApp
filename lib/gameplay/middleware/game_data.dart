import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go/constants/constants.dart';
import 'package:go/gameplay/create/create_game.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/game_move.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/services/game_move_dto.dart';
import 'package:go/ui/gameui/time_watch.dart';
import 'package:go/utils/player.dart';
import 'package:go/models/position.dart';
import 'package:go/utils/time_and_duration.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';

// class GameData extends InheritedWidget {
//   // Call only once after the game has started which is checked by checkGameEnterable
//   bool hasGameStarted = false;
//   onGameStart(BuildContext context) {
//     // Stage changes from before start to gameplay
//     context.read<GameStateBloc>().curStageTypeNotifier.value =
//         GameplayStage.fromScratch();

//     if (!GameData.of(context)!.hasGameStarted) {
//       hasGameStarted = true;
//       // StoneLogic.of(context)?.fetchNewStoneFromDB(context);
//     }
//   }

//   final List<Player> _players;
//   final Widget mChild;
//   StreamController<List<TimeAndDuration>> updateController =
//       StreamController<List<TimeAndDuration>>.broadcast();

//   GameData({
//     super.key,
//     required List<Player> pplayer,
//     required this.mChild,
//     required this.authBloc,
//     required this.game,
//     required Stage curStage,
//   })  : _players = pplayer,
//         // curStageNotifier = ValueNotifier(curStage),
//         // _turnNotifier = ValueNotifier(game.moves.length),
//         super(child: mChild) {
//     // if (match.lastTimeAndDate.isNotEmpty) {
//     //   updateController.add(match.lastTimeAndDate as List<TimeAndDuration>);
//     // }
//   }

//   final Game game;
//   // final GameMatch match;

//   // GETTERS
//   // final ValueNotifier<int> _turnNotifier;
//   // ValueNotifier<int> get turnNotifier => _turnNotifier;

//   // ValueNotifier<Stage> curStageNotifier;
//   // Stage get cur_stage => curStageNotifier.value;
//   // set cur_stage(Stage stage) {
//   //   cur_stage.disposeStage();
//   //   curStageNotifier.value = stage;
//   // }

//   // Turn player timer needs to be corrected because the player with last turn has sent correct time
//   // from database but current player has some lag that needs to be corrected
//   correctTurnPlayerTimeAndAddToUpdateController(
//       int turn, context, lastMoveDateTime) {
//     NTP.now().then((value) {
//       print("player with turn" + turn.toString());
//       Duration durationAfterTimeElapsedCorrection =
//           calculateCorrectTimeFromNow(lastMoveDateTime, turn, value, context);

//       lastMoveDateTime[turn] = (TimeAndDuration(
//           lastMoveDateTime[turn]?.datetime,
//           durationAfterTimeElapsedCorrection));

//       updateController.add(List<TimeAndDuration>.from(lastMoveDateTime));
//     });
//   }

//   // bool movePlayed = false;
//   void newMovePlayed(BuildContext context, GameMoveDto moveDto) async {
//     // movePlayed = true;
//     var move = await context.read<GameStateBloc>().playMove(moveDto);

//     // List<TimeAndDuration?> lastMoveDateTime = [...match.lastTimeAndDate];

//     // lastMoveDateTime[getClientPlayerIndex(context)!] = TimeAndDuration(
//     //     timeOfPlay, lastMoveDateTime[getClientPlayerIndex(context)!]!.duration);
//     // Duration updatedTime = calculateCorrectTime(
//     //     lastMoveDateTime, getClientPlayerIndex(context), null, context);
//     // lastMoveDateTime[getClientPlayerIndex(context)!] =
//     //     (TimeAndDuration(timeOfPlay, updatedTime));

//     // updateTimeAndDurationInDatabase(
//     //     context,
//     //     lastMoveDateTime[getClientPlayerIndex(context)!] as TimeAndDuration,
//     //     getClientPlayerIndex(context)!);
//     // updateMoveIntoDatabase(context, playPosition);

//     // for (var element in lastMoveDateTime) {
//     //   print(element.toString());
//     // }

//     // turn hasn't been updated here so without turn is actually the player with turn
//     // correctTurnPlayerTimeAndAddToUpdateController(
//     //     GameData.of(context)!.getPlayerWithoutTurn.turn,
//     //     context,
//     //     lastMoveDateTime);
//     // match.lastTimeAndDate = [...lastMoveDateTime];
//     // match.moves.add(playPosition);
//     //}
//     // });
//   }

//   // updateMoveIntoDatabase(BuildContext context, Position? position) {
//   //   var thisGame =
//   //       MultiplayerData.of(context)?.database.child('game').child(match.id);
//   //   thisGame
//   //       ?.child('moves')
//   //       .update({(match.turn).toString(): position.toString()});
//   //   thisGame?.update({'turn': (turn + 1).toString()});
//   // }

//   // DatabaseReference? getMatch(BuildContext context) {
//   //   return MultiplayerData.of(context)?.database.child('game').child(match.id);
//   // }

//   @override
//   bool updateShouldNotify(GameData oldWidget) {
//     return false;
//   }

//   static GameData? of(BuildContext context) =>
//       context.dependOnInheritedWidgetOfExactType<GameData>();
// }
