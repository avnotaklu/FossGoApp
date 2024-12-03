import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart' as constants;

import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/modules/gameplay/game_state/game_board_bloc.dart';
import 'package:provider/provider.dart';
import 'stone_widget.dart';
import '../../../models/position.dart';

class Cell extends StatefulWidget {
  Position position;
  // Map<Position?,Stone?> playgroundMap;
  // final VoidCallback cellChanged;
  Cell(this.position, {super.key});

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  // StoneWidget? tmp;
  @override
  Widget build(BuildContext context) {
    // final Stream<StoneWidget?> _bids = (() async* {
    //   yield StoneLogic.of(context)?.stoneAt(widget.position);
    // })();

    // return ValueListenableBuilder<StoneWidget?>(
    //   valueListenable: StoneLogic.of(context)!.stoneNotifierAt(widget.position),
    //   builder: (BuildContext context, dyn, wid) {

    GameBoardBloc gameBoard = context.read();
    final stone = gameBoard.stoneAt(widget.position);
    final stage = context.read<Stage>();
    return GestureDetector(
      onTap: () {
        setState(() {
          stage.onClickCell(widget.position, context);
        });
      },
      child:
          //  StoneWidget(
          //   constants.playerColors[stone!.player],
          //   stone.position,
          // ),
          // //  stone == null
          // //     ?  Container(
          // //         height: 20,
          // //         width: 20,
          // //         color: Colors.red,
          // //       )
          stage.drawCell(
              widget.position,
              StoneWidget(
                stone == null ? null : constants.playerColors[stone.player],
                widget.position,
              ),
              context),
    );
    //   },
    // );
  }
}
