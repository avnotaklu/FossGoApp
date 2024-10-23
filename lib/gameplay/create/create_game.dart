import 'package:firebase_database/firebase_database.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/gameplay/create/request_recieve.dart';
import 'package:go/gameplay/create/request_send_screen.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/homepage_bloc.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/utils/widgets/buttons.dart';
import 'package:provider/provider.dart';

class CreateGame extends StatefulWidget {
  const CreateGame({super.key});

  @override
  State<CreateGame> createState() => _CreateGameState();
}

class _CreateGameState extends State<CreateGame> {
  // static const title = 'Grid List';
  var curBoardSize = Constants.boardsizes[0];
  int mRows = 9;
  int mCols = 9;
  Map<int, String?> mUid = {};
  int mTime = 300;

  // ignore: use_key_in_widget_constructors
  @override
  Widget build(BuildContext context) {
    // Provider.of<AuthBloc>(context, listen: false);
    // DatabaseReference? newPlace;
    // if (widget.match != null) {
    //   try {
    //     MultiplayerData.of(context)!.createGameDatabaseRefs(widget.match!.id);
    //     newPlace = MultiplayerData.of(context)?.curGameReferences!.game;
    //   } on Exception {
    //     throw "couldn't start game";
    //   }
    // } else {
    //   newPlace = MultiplayerData.of(context)?.game_ref.push();
    // }

    // if ((widget.match?.bothPlayers.contains(null) ?? true) == false) {
    //   // BOTH players have entered game in database
    //   assert(widget.match != null);
    //   if (widget.match?.uid.containsValue(
    //           MultiplayerData.of(context)?.curUser!.email.toString()) ??
    //       false) {
    //     if (widget.match!.runStatus == true) {
    //       return GameWidget(
    //           widget.match as GameMatch, false, GameplayStage.fromScratch());
    //     } else {
    //       return GameWidget(widget.match as GameMatch, false,
    //           GameEndStage.fromScratch(context));
    //       //return Game(match as GameMatch, false, GameplayStage());
    //     }
    //   }
    //   return Container(
    //     child: const Text(
    //         "Game has already been created and two players have already entered"),
    //   );
    // }

    // if ((widget.match?.bothPlayers.any((element) => element != null) ??
    //         false) &&
    //     widget.match?.bothPlayers.contains(null)) {
    //   // One Player, Sender has entered game in database
    //   return RequestRecieve(
    //     match: widget.match as GameMatch,
    //     newPlace: newPlace,
    //   );
    // }

    return BackgroundScreenWithDialog(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      const
      // Expanded(
      //   flex: 2,
      //   child:
      Text(
        "Choose color of your stone",
        style: TextStyle(color: Colors.black, fontSize: 20),
        // ),
      ),
      // Expanded(
      //     flex: 1,
      //     child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        IconButton(
            onPressed: () => {
                  mUid.clear(),
                  mUid[0] = context.read<AuthBloc>().currentUserRaw!.id,
                  // ?.curUser!
                  // .email
                  // .toString(),
                },
            icon:
                // Expanded(child:
                StoneWidget(Colors.black, Position(0, 0))
            // )
            ),
        IconButton(
          onPressed: () => {
            mUid.clear(),
            mUid[1] = context.read<AuthBloc>().currentUserRaw!.id,
            // mUid[1] =
            //     MultiplayerData.of(context)?.curUser!.email.toString()
          },
          icon:
              // Expanded(child:
              StoneWidget(Colors.white, Position(0, 0)
                  // )
                  ),
        ),
      ]),
      // ),
      StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              // Expanded(
              //       flex: 5,
              // child:
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child:
                  DropdownButton(
                    value: curBoardSize,
                    hint: Text(
                      "Board Size",
                      style: TextStyle(
                          color: Constants.defaultTheme.mainTextColor,
                          fontSize: 15),
                    ),
                    items: Constants.boardsizes.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(
                          items,
                          style: TextStyle(
                              color: Constants.defaultTheme.mainTextColor,
                              fontSize: 15),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      curBoardSize = newValue ?? "null";
                      mRows = int.parse(newValue!.split("x")[0]);
                      mCols = int.parse(newValue.split("x")[1]);
                      setState(() => curBoardSize = newValue);
                    },
                    )
                  ),
                  Expanded(
                      flex: 1,
                      child:
                  Row(children: [
                    Expanded(
                      flex: 2,
                      child: BadukButton(
                        child: Text(
                          "Time",
                          style: TextStyle(
                              color: defaultTheme.mainTextColor, fontSize: 15),
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
                  ])
                  ),
                ],
                // ),
              )),
      // EnterGameButton(match, newPlace),
      BadukButton(
        onPressed: () async {
          final signalRBloc = context.read<SignalRBloc>();
          final authBloc = context.read<AuthBloc>();
          final token = context.read<AuthBloc>().token;
          final res = await context.read<HomepageBloc>().createGame(token!);

          res.fold((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
              ),
            );
          }, (game) {
            Navigator.pushReplacement(context,
                MaterialPageRoute<void>(builder: (BuildContext context) {
              var stage = BeforeStartStage();
              return ChangeNotifierProvider(
                  create: (context) =>
                      GameStateBloc(signalRBloc, authBloc, game, stage),
                  builder: (context, child) {
                    return RequestSendScreen(game);
                  });
            }));
          });
        },
        child: Text("Create"),
      ),
    ]));
  }
}
