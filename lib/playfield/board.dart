import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go/playfield/game.dart';
import 'stone.dart';
import '../utils/position.dart';
import '../utils/player.dart';
import 'cell.dart';
import '../gameplay/logic.dart';

class Board extends StatefulWidget {
  late int rows, cols;
  Map<Position?, Stone?> playgroundMap = {};

  Board(this.rows, this.cols, Map<Position?, Stone?> stonePos) {
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        // playgroundMap[Position(i, j)] = Player(Colors.black);
        var tmpPos = Position(i, j);
        if (stonePos.keys.contains(tmpPos)) {
          playgroundMap[Position(i, j)] = stonePos[tmpPos];
        } else
          playgroundMap[Position(i, j)] = null;
      }
    }
  }

  @override
  State<Board> createState() => _BoardState();
}

GlobalKey _boardKey = GlobalKey();

class _BoardState extends State<Board> {
  @override
  Widget build(BuildContext context) {
    double stoneInset = 20;
    double stoneSpacing = 2; // Don't make spacing so large that to get that spacing Stones start to move out of position

    //double boardInset = stoneInsetstoneSpacing;
    return Center(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return StoneLogic(
            playgroundMap: widget.playgroundMap,
            rows: widget.rows,
            cols: widget.cols,
            mChild: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Stack(
                  children: [
                    BorderGrid(GridInfo(constraints, stoneSpacing, widget.rows, widget.cols, stoneInset)),
                    StoneLayoutGrid(
                      GridInfo(constraints, stoneSpacing, widget.rows, widget.cols, stoneInset),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class GridInfo {
  BoxConstraints constraints;
  double stoneSpacing;
  double stoneInset;
  int rows;
  int cols;
  GridInfo(this.constraints, this.stoneSpacing, this.rows, this.cols, this.stoneInset);
}

class BorderGrid extends StatelessWidget {
  GridInfo info;
  BorderGrid(this.info);

  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(info.stoneInset + (((info.constraints.maxWidth / info.rows) / 2) - info.stoneSpacing)),
      itemCount: (info.rows - 1) * (info.cols - 1),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: (info.rows - 1), childAspectRatio: 1, crossAxisSpacing: 0, mainAxisSpacing: 0),
      itemBuilder: (context, index) => Container(
        height: 10,
        width: 10,
        decoration: BoxDecoration(border: Border.all(color: Colors.brown)),
      ),
    );
  }
}

class StoneLayoutGrid extends StatefulWidget {
  GridInfo info;
  // Map<Position?, ValueNotifier<Stone>?> playgroundMap = {null: null}; // TODO whats this {null : null} assigned probably changeable

  StoneLayoutGrid(this.info /*, this.playgroundMap*/);
  @override
  State<StoneLayoutGrid> createState() => _StoneLayoutGridState();
}

class _StoneLayoutGridState extends State<StoneLayoutGrid> {
  void fetchNewStoneFromDB() {
    // TODO put this function in a better place, it has no relation to board
    print('hello');

    MultiplayerData.of(context)?.database.child('game').child(GameData.of(context)!.match.id as String).child('moves').onValue.listen((event) {
      final data = event.snapshot.value as List;
      if (data.last != null && data.last != "null") {
        final pos = Position(int.parse(data.last!.split(' ')[0]), int.parse(data.last!.split(' ')[1]));
        if (StoneLogic.of(context)!.stoneAt(pos)  == null) {
          if (StoneLogic.of(context)!.handleStoneUpdate(pos, context)) {
            print("illegel");
            GameData.of(context)?.toggleTurn(context); // FIXME pos was passed to toggleTurn idk if that broke anything
            setState(() {});
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchNewStoneFromDB();
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(widget.info.stoneInset),
      itemCount: (widget.info.rows) * (widget.info.cols),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (widget.info.rows),
        childAspectRatio: 1,
        crossAxisSpacing: widget.info.stoneSpacing,
        mainAxisSpacing: widget.info.stoneSpacing,
      ),
      itemBuilder: (context, index) => Container(
        height: 10,
        width: 10,
        child: Stack(
          children: [
            Cell(Position(((index) ~/ widget.info.cols), ((index) % widget.info.rows).toInt())),
          ],
        ),
      ),
    );
  }
}
