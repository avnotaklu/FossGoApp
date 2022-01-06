import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/create/request_recieve.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/playfield/game.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/utils/models.dart';
import 'package:go/utils/position.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class CreateGame extends StatelessWidget {
  static const title = 'Grid List';
  GameMatch match;

  // ignore: use_key_in_widget_constructors
  CreateGame(this.match);

  // ignore: use_key_in_widget_constructors
  @override
  Widget build(BuildContext context) {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    var newPlace = MultiplayerData.of(context)?.getCurGameRef(match.id);
    // if (match != null) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute<void>(
    //         builder: (BuildContext context) => GameRecieve(match: match as GameMatch,)),
    //   );
    // }
    match.uid = {0: null, 1: null};
    newPlace.set(match.toJson());
//     authBloc.currentUser.listen((user) {
//       if (match == null) {
//         print("hurray");
//         var newPlace = MultiplayerData.of(context)?.game_ref.push();
//         // match = GameMatch(9, 9, 5 * 60, newPlace.key,
//         //     {0: user?.uid, 1: null}); // Don't delete default values 0 or 1
//         // // Json parser depends on it.
//         // newPlace.set(match.toJson());
//         // game = Game(0, match as GameMatch);
//       } else {
//         if (match.uid?[1] == null) {
//           match.uid?[1] = user?.uid;
//           MultiplayerData.of(context)
//               ?.gameRef
//               .child(match.id.toString())
//               .child('uid')
//               .update({1.toString(): user?.uid.toString()});
//         }
//       }
//     });

    MultiplayerData.of(context)
        ?.database
        .child('game')
        .child(match.id as String)
        .child('uid')
        .onValue
        .listen((event) {
      print("hello");
    });

    var curBoardSize = Constants.boardsizes[0];
    return Positioned.fill(
        child: Container(
      child: FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.6,
          child: Dialog(
              backgroundColor: Colors.blue,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        "Choose color of your stone",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                  onPressed: () => {
                                        match.uid[0] =
                                            MultiplayerData.of(context)
                                                ?.curUser
                                                .uid
                                                .toString(),
                                      },
                                  icon: Expanded(
                                      child:
                                          Stone(Colors.black, Position(0, 0)))),
                              IconButton(
                                  onPressed: () => {
                                        match.uid[1] =
                                            MultiplayerData.of(context)
                                                ?.curUser
                                                .uid
                                                .toString()
                                      },
                                  icon: Expanded(
                                      child:
                                          Stone(Colors.white, Position(0, 0)))),
                            ])),
                    StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) =>
                            Expanded(
                              flex: 5,
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: DropdownButton(
                                        value: curBoardSize,
                                        hint: Text("Board Size"),
                                        items: Constants.boardsizes
                                            .map((String items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          curBoardSize = newValue ?? "null";
                                          match.rows = int.parse(
                                              newValue!.split("x")[0]);
                                          match.cols =
                                              int.parse(newValue.split("x")[1]);
                                        },
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Row(children: [
                                        Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            child:
                                                Container(child: Text("Time")),
                                            onPressed: () => showDialog(
                                              context: context,
                                              builder: (context) => Center(
                                                child: FractionallySizedBox(
                                                  heightFactor: 0.8,
                                                  widthFactor: 1.0,
                                                  child: Dialog(
                                                    child: CupertinoTimerPicker(
                                                        mode:
                                                            CupertinoTimerPickerMode
                                                                .hms,
                                                        onTimerDurationChanged:
                                                            (value) {
                                                          debugPrint("hello");
                                                          match.time =
                                                              value.inSeconds;
                                                        }),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ])),
                                ],
                              ),
                            )),
                    Expanded(
                      flex: 2,
                      child: Row(children: [
                        ElevatedButton(
                          onPressed: () => Share.share(match.id),
                          child: Container(
                            child: Text("Share"),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white)),
                          onPressed: () {
                            newPlace.set(match.toJson());
                            if (match.isComplete()) {
                              MultiplayerData.of(context)
                                  ?.getCurGameRef(match.id)
                                  .child('uid')
                                  .onValue
                                  .listen((event) {
                                print(event.snapshot.value.toString());
                                match.uid =
                               Map<int?,String?>.from(event.snapshot.value.asMap().map((i,element) => MapEntry(i as int,element.toString())));
                                if (match.bothPlayers.contains(null) == false) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            Game(0, match),
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
                      ]),
                    ),
                  ]))),
      decoration: BoxDecoration(color: Colors.green),
    ));
  }
}
