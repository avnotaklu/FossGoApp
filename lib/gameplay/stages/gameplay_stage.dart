import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/cell.dart';
import 'package:go/playfield/game.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/database_strings.dart';
import 'package:go/utils/position.dart';
import 'package:ntp/ntp.dart';

class GameplayStage extends Stage {
  const GameplayStage();

  @override
  Widget drawCell(Position position, Stone? stone) {
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
}
