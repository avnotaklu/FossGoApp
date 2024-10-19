import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/gameplay/create/request_recieve.dart';
import 'package:go/gameplay/create/request_send.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/playfield/game.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/models/game_match.dart';
import 'package:go/utils/position.dart';
import 'package:go/utils/widgets/buttons.dart';
import 'package:provider/provider.dart';

class CreateGame extends StatelessWidget {
  static const title = 'Grid List';
  GameMatch? match;

  // ignore: use_key_in_widget_constructors
  CreateGame(this.match);

  // ignore: use_key_in_widget_constructors
  @override
  Widget build(BuildContext context) {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    var newPlace;
    if (match != null) {
      try {
        MultiplayerData.of(context)!.createGameDatabaseRefs(match!.id);
        newPlace = MultiplayerData.of(context)?.curGameReferences!.game;
      } catch (Exception) {
        throw "couldn't start game";
      }
    } else {
      newPlace = MultiplayerData.of(context)?.game_ref.push();
    }

    if ((match?.bothPlayers.contains(null) ?? true) == false) {
      // BOTH players have entered game in database
      assert(match != null);
      if (match?.uid.containsValue(MultiplayerData.of(context)?.curUser!.email.toString()) ?? false) {
        if (match!.runStatus == true) {
          return Game(match as GameMatch, false, GameplayStage.fromScratch());
        } else {
          return Game(match as GameMatch, false, GameEndStage.fromScratch(context));
          //return Game(match as GameMatch, false, GameplayStage());
        }
      }
      return Container(
        child: const Text("Game has already been created and two players have already entered"),
      );
    }

    if ((match?.bothPlayers.any((element) => element != null) ?? false) && match?.bothPlayers.contains(null)) {
      // One Player, Sender has entered game in database
      return RequestRecieve(
        match: match as GameMatch,
        newPlace: newPlace,
      );
    }

    var curBoardSize = Constants.boardsizes[0];
    int mRows = 9; // TODO find a way to do this without these defaults
    int mCols = 9;
    Map<int, String?> mUid = {};
    int mTime = 300;
    return BackgroundScreenWithDialog(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      const Expanded(
        flex: 2,
        child: Text(
          "Choose color of your stone",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      Expanded(
          flex: 1,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            IconButton(
                onPressed: () => {
                      mUid.clear(),
                      mUid[0] = MultiplayerData.of(context)?.curUser!.email.toString(),
                    },
                icon: Expanded(child: Stone(Colors.black, Position(0, 0)))),
            IconButton(
                onPressed: () => {mUid.clear(), mUid[1] = MultiplayerData.of(context)?.curUser!.email.toString()},
                icon: Expanded(child: Stone(Colors.white, Position(0, 0)))),
          ])),
      StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Expanded(
                flex: 5,
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: DropdownButton(
                          value: curBoardSize,
                          hint: Text(
                            "Board Size",
                            style: TextStyle(color: Constants.defaultTheme.mainTextColor, fontSize: 15),
                          ),
                          items: Constants.boardsizes.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(
                                items,
                                style: TextStyle(color: Constants.defaultTheme.mainTextColor, fontSize: 15),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            curBoardSize = newValue ?? "null";
                            mRows = int.parse(newValue!.split("x")[0]);
                            mCols = int.parse(newValue.split("x")[1]);
                            setState(() => curBoardSize = newValue);
                          },
                        )),
                    Expanded(
                        flex: 1,
                        child: Row(children: [
                          Expanded(
                            flex: 2,
                            child: BadukButton(
                              child: Text(
                                "Time",
                                style: TextStyle(color: defaultTheme.mainTextColor, fontSize: 15),
                              ),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => Center(
                                  child: FractionallySizedBox(
                                    heightFactor: 0.8,
                                    widthFactor: 1.0,
                                    child: Dialog(
                                      child: CupertinoTimerPicker(
                                          mode: CupertinoTimerPickerMode.hms,
                                          onTimerDurationChanged: (value) {
                                            mTime = value.inSeconds;
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
      // EnterGameButton(match, newPlace),
      BadukButton(
        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute<void>(builder: (BuildContext context) {
          match = GameMatch(id: newPlace.key.toString(), rows: mRows, cols: mCols, time: mTime, uid: mUid);
          newPlace.set(match?.toJson());
          return RequestSend(match!);
        })),
        child: Text("Create"),
      ),
    ]));
  }
}
