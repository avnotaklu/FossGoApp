import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'stone.dart';
import '../utils/position.dart';

class Cell extends StatefulWidget {
  Position position;
  // Map<Position?,Stone?> playgroundMap;
  // final VoidCallback cellChanged;
  Cell(this.position);

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  Stone? tmp;

  // We were doing this to update cell state every second does this even make sense? Everything seems to work with this part
  // String? _now;
  // Timer? _everySecond;

  // @override
  // void initState() {
  //   super.initState();

  //   // sets first value
  //   _now = DateTime.now().second.toString();

  //   // defines a timer
  //   _everySecond = Timer.periodic(Duration(microseconds: 100), (Timer t) {
  //     setState(() {
  //       _now = DateTime.now().second.toString();
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final Stream<Stone?> _bids = (() async* {
      // await Future<void>.delayed(const Duration(seconds: 0));
      yield StoneLogic.of(context)?.stoneAt(widget.position);
    })();

    return ValueListenableBuilder<Stone?>(
      valueListenable: StoneLogic.of(context)!.stoneNotifierAt(widget.position),
      builder: (BuildContext context, dyn, wid) {
        return GestureDetector(
          onTap: () {
            setState(() {
              GameData.of(context)!.cur_stage.onClickCell(widget.position, context);
              // MultiplayerData.of(context)
              //     ?.move_ref
              //     .set({'pos': widget.position.toString()});
              // if ((StoneLogic.of(context)?.stoneAt(widget.position) == null) &&
              //     (GameData.of(context)?.match.uid[GameData.of(context)?.turn % 2]) == MultiplayerData.of(context)?.curUser!.uid) {
              //   // If position is null and this is users turn, place stone
              //   if (StoneLogic.of(context)?.handleStoneUpdate(widget.position, context) ??
              //       true) // TODO revisit this and make sure it does the right thing
              //   {
              //     debugPrint("toggling");
              //     // MultiplayerData.of(context)?.database.child('game').child('')
              //     NTP.now().then((value) {
              //       GameData.of(context)?.newMovePlayed(context, value, widget.position);
              //       GameData.of(context)?.toggleTurn(context);
              //       var mapRef = MultiplayerData.of(context)?.database.child('game').child(GameData.of(context)!.match.id).child('playgroundMap');
              //       mapRef!.update(playgroundMapToString(
              //           Map<Position?, Stone?>.from(StoneLogic.of(context)!.playground_Map.map((key, value) => MapEntry(key, value.value)))));
              //     });
              //   }
              // }
            });
          },
          //child: GameData.of(context)!.curStage.drawCell(widget.position,dyn),
          child: GameData.of(context)!.cur_stage.drawCell(widget.position, dyn),
        );
      },
    );
  }
}
