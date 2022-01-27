import 'package:flutter/material.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/playfield/game.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/models/game_match.dart';
import 'package:go/utils/position.dart';
import 'create_game.dart';
import 'package:go/constants/constants.dart' as Constants;

class RequestRecieve extends StatelessWidget {
  GameMatch match;
  final newPlace;
  RequestRecieve({required this.match, required this.newPlace});
  @override
  Widget build(BuildContext context) {
    int recieversTurn = (() {
      if (match.uid[0] == null)
        return 0;
      else
        return 1;
    }).call();

    // assert(match.uid[recieversTurn] == null);

    match.uid[recieversTurn] =
        MultiplayerData.of(context)?.curUser.uid.toString();

    return BackgroundScreenWithDialog(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Expanded(
        flex: 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("You are playing"),
            Expanded(
              child: Stone(
                  Constants.playerColors[recieversTurn], Position(0, 0)),
            ),
          ],
        ),
      ),
      Expanded(flex: 4, child: Container()),
      Expanded(flex: 3, child: EnterGameButton(match, newPlace)),
    ]));
  }
}


class EnterGameButton extends StatelessWidget {
  final match;
  final newPlace;
  EnterGameButton(this.match, this.newPlace);
  @override
  Widget build(BuildContext context) {

    return Expanded(
      flex: 2,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white)),
        onPressed: () {
          newPlace.set(match.toJson());
          if (match.isComplete()) {
            MultiplayerData.of(context)
                ?.getCurGameRef(match.id)
                .child('uid')
                .onValue
                .listen((event) {
              print(event.snapshot.value.toString());
              match.uid = Map<int?, String?>.from(event.snapshot.value
                  .asMap()
                  .map((i, element) => MapEntry(i as int, element.toString())));
              if (match.bothPlayers.contains(null) == false) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => Game(0, match, false),
                    ));
              }
            });
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    const Text("Match wasn't created"),
              ),
            );
          }
        },
        child: Container(),
      ),
    );
  }
}
