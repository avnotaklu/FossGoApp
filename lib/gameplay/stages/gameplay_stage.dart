import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/score_calculation_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/utils/database_strings.dart';
import 'package:go/utils/position.dart';
import 'package:ntp/ntp.dart';

// class GameplayStage extends Stage<GameplayStage> {
class GameplayStage extends Stage{
  var listenNewStone;

  GameplayStage() {}

  @override
  GameplayStage get stage => this;
  @override
  void initializeWhenAllMiddlewareAvailable(context) {
    listenNewStone = fetchNewStoneFromDB(context);
    ScoreCalculation.of(context)!.calculateScore(context);
  }

  fetchNewStoneFromDB(context) {
    print('hello');
    return MultiplayerData.of(context)?.curGameReferences?.moves.onValue.listen((event) {
      // TODO: unnecessary listen move even when move is played by clientPlayer even though (StoneLogic.of(context)!.stoneAt(pos)  == null) stops it from doing anything stupid
      print(GameData.of(context)!.listenNewMove);
      final data = event.snapshot.value as List?;
      if (data?.last != null) {
        if (data?.last != "null") {
          final pos = Position(int.parse(data!.last!.split(' ')[0]), int.parse(data.last!.split(' ')[1]));
          if (StoneLogic.of(context)!.stoneAt(pos) == null) {
            if (StoneLogic.of(context)!.handleStoneUpdate(pos, context)) {
              print("illegel");
              GameData.of(context)?.toggleTurn(context); // FIXME pos was passed to toggleTurn idk if that broke anything
              // setState(() {});
            }
          }
        } else {
          if (data!.length > GameData.of(context)!.turn) {
            GameData.of(context)?.match.moves.add(null);
            GameData.of(context)?.toggleTurn(context);
          }
        }
        if (data.reversed.elementAt(0) == "null" && data.reversed.elementAt(1) == "null") {
          GameData.of(context)!.cur_stage = ScoreCalculationStage(context);
        }
      }
      GameData.of(context)!.listenNewMove = false;
    });
  }

  @override
  List<Widget> buttons() {
    return [Pass(), CopyId()];
  }

  @override
  Widget drawCell(Position position, Stone? stone, BuildContext context) {
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
    // MultiplayerData.of(context)
    //     ?.move_ref
    //     .set({'pos': widget.position.toString()});
    if (((StoneLogic.of(context)?.stoneAt(position)) == null) &&
        (GameData.of(context)?.match.uid[GameData.of(context)!.turn % 2]) == MultiplayerData.of(context)?.curUser!.uid) {
      // If position is null and this is users turn, place stone
      if (StoneLogic.of(context)?.handleStoneUpdate(position, context) ?? true) // TODO revisit this and make sure it does the right thing
      {
        // MultiplayerData.of(context)?.database.child('game').child('')
        NTP.now().then((value) {
          GameData.of(context)?.newMovePlayed(context, value, position);
          GameData.of(context)?.toggleTurn(context);

          // TODO: remove Unnecessary database write on pass move
          var mapRef = MultiplayerData.of(context)?.database.child('game').child(GameData.of(context)!.match.id).child('playgroundMap');

          // TODO: null check on stone logic shouldn't be necessary as stone logic should be constructed as soon as game has started
          if (StoneLogic.of(context) != null) {
            mapRef!.update(playgroundMapToString(
                Map<Position?, Stone?>.from(StoneLogic.of(context)!.playground_Map.map((key, value) => MapEntry(key, value.value)))));
          }
        });
      }
    }
  }

  @override
  disposeStage() {
    // TODO: implement disposeStage
  }
}
