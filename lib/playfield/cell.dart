import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:ntp/ntp.dart';
import '../utils/player.dart';
import '../gameplay/logic.dart';
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
      yield StoneLogic.of(context)?.playground_Map[widget.position] as Stone?;
    })();

    return StreamBuilder(
      stream: _bids,
      builder: (BuildContext context, AsyncSnapshot<Stone?> snapshot) {
        return GestureDetector(
          onTap: () {
            // MultiplayerData.of(context)
            //     ?.move_ref
            //     .set({'pos': widget.position.toString()});
            if ((StoneLogic.of(context)?.playground_Map[widget.position] ==
                    null) &&
                (GameData.of(context)
                        ?.match
                        .uid[GameData.of(context)?.turn % 2]) ==
                    MultiplayerData.of(context)?.curUser.uid) {
              // If position is null and this is users turn, place stone
              setState(() {
                if (StoneLogic.of(context)
                        ?.handleStoneUpdate(widget.position, context) ??
                    true) // TODO revisit this and make sure it does the right thing
                {
                  debugPrint("toggling");
                  // MultiplayerData.of(context)?.database.child('game').child('')
                  NTP.now().then((value) {
                    GameData.of(context)?.newMovePlayed(context, value);
                    GameData.of(context)?.toggleTurn(context, widget.position);
                  });
                }
              }); // changeColor();
            }
          },
          child: Stack(
            children: [
              snapshot.data ??
                  Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
            ],
          ),
        );
      },
    );
  }
}
