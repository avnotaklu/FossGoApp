import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/score_calculation_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/game_move.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/move_position.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';

// class GameplayStage extends Stage<GameplayStage> {
class GameplayStage extends Stage {
  // StreamSubscription? listenNewStone;

  GameplayStage.fromScratch();

  GameplayStage(context);

  @override
  GameplayStage get stage => this;

  @override
  void initializeWhenAllMiddlewareAvailable(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    gameStateBloc.startPausedTimerOfActivePlayer();
    // listenNewStone = gameStateBloc.listenForMove();
    context.read<ScoreCalculationBloc>().calculateScore();
  }

  // fetchNewStoneFromDB(context) {
  //   print('hello');
  //   return MultiplayerData.of(context)
  //       ?.curGameReferences
  //       ?.moves
  //       .onChildAdded
  //       .listen((event) {
  //     // FIXME: this todo is fixme
  //     // TODO: unnecessary listen move even when move is played by clientPlayer even though (StoneLogic.of(context)!.stoneAt(pos)  == null) stops it from doing anything stupid
  //     // final data = event.snapshot.value as List?;
  //     final data = <String>[event.snapshot.value as String];
  //     if (data.last != null) {
  //       if (data.last != "null") {
  //         final pos = Position(int.parse(data.last.split(' ')[0]),
  //             int.parse(data.last.split(' ')[1]));
  //         if (StoneLogic.of(context)!.stoneAt(pos) == null) {
  //           if (StoneLogic.of(context)!.handleStoneUpdate(pos, context)) {
  //             print("illegel");
  //             GameData.of(context)?.toggleTurn(
  //                 context); // FIXME pos was passed to toggleTurn idk if that broke anything
  //             // setState(() {});
  //           }
  //         }
  //       } else {
  //         if (int.parse(event.snapshot.key as String) + 1 >
  //             GameData.of(context)!.turn) {
  //           GameData.of(context)?.match.moves.add(null);
  //           GameData.of(context)?.toggleTurn(context);

  //           MultiplayerData.of(context)
  //               ?.curGameReferences
  //               ?.moves
  //               .get()
  //               .then((event) {
  //             var prev;
  //             bool change_stage = false;
  //             for (var i in (event.value as List).reversed) {
  //               if (prev == null) {
  //                 prev = i;
  //                 continue;
  //               }
  //               if (i == "null" && prev == "null") {
  //                 change_stage = !change_stage;
  //               } else {
  //                 break;
  //               }
  //             }
  //             if (change_stage) {
  //               GameData.of(context)!.cur_stage =
  //                   ScoreCalculationStage(context);
  //             }
  //           });
  //         }
  //       }
  //       // // TODO: reimplement_with_cloud_functions or maybe that'll be overkill idk
  //       // if (data?.last == "null") {
  //       // }
  //     }
  //   });
  // }

  @override
  List<Widget> buttons() {
    return [Pass(), Resign()];
  }

  @override
  Widget drawCell(Position position, StoneWidget? stone, BuildContext context) {
    return Stack(
      children: [
        stone ??
            Container(
              decoration: const BoxDecoration(color: Colors.transparent),
            ),
      ],
    );
  }

  @override
  onClickCell(Position? position, BuildContext context) {
    StoneLogic stoneLogic = context.read();
    context.read<GameStateBloc>().playMove(position, stoneLogic);
  }

  @override
  disposeStage() {
    // TODO: implement disposeStage
    // listenNewStone?.cancel();
  }

  @override
  StageType get getType => StageType.Gameplay;
}
