import 'package:firebase_database/firebase_database.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/gameplay/create/request_send_screen.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/create_game_provider.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/homepage_bloc.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/utils/widgets/buttons.dart';
import 'package:provider/provider.dart';

class CreateGameScreen extends StatefulWidget {
  // final SignalRProvider signalRProvider;
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  // static const title = 'Grid List';
  var curBoardSize = Constants.boardsizes[0];
  int mRows = 9;
  int mCols = 9;
  Map<int, String?> mUid = {};
  int mTime = 300;

  @override
  void initState() {
    mUid.clear();
    mUid[0] = context.read<AuthProvider>().currentUserRaw!.id;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

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

    // return Consumer<SignalRProvider>(
    //   // : (context) => widget.signalRProvider,
    //   builder: (context, signalRBloc, child) {
    return BackgroundScreenWithDialog(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
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
                mUid[0] = context.read<AuthProvider>().currentUserRaw!.id,
                // ?.curUser!
                // .email
                // .toString(),
              },
              icon:
                  // Expanded(child:
                  Container(
                      height: 50,
                      width: 50,
                      child: StoneWidget(Colors.black, Position(0, 0))),
              // )
            ),
            IconButton(
              onPressed: () => {
                mUid.clear(),
                mUid[1] = context.read<AuthProvider>().currentUserRaw!.id,
                // mUid[1] =
                //     MultiplayerData.of(context)?.curUser!.email.toString()
              },
              icon:
                  // Expanded(child:
                  Container(
                      height: 50,
                      width: 50,
                      child: StoneWidget(Colors.white, Position(0, 0))),

              // )
              // ),
            ),
          ]),
          // ),
          // StatefulBuilder(
          //     builder: (BuildContext context, StateSetter setState) =>
          // Expanded(
          //       flex: 5,
          // child:
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: DropdownButton(
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
                  )),
              Expanded(
                  flex: 1,
                  child: Row(children: [
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
                  ])),
            ],
            // ),
          ),
          // ),
          // EnterGameButton(match, newPlace),
          BadukButton(
            onPressed: () async {
              final signalRProvider = context.read<SignalRProvider>();
              final signalRBloc =
                  ChangeNotifierProvider.value(value: signalRProvider);
              final authBloc = context.read<AuthProvider>();
              final token = context.read<AuthProvider>().token;
              final res =
                  await context.read<CreateGameProvider>().createGame(token!);

              res.fold((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message),
                  ),
                );
              }, (game) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                  return MultiProvider(
                      providers: [
                        signalRBloc,
                        // ChangeNotifierProvider.value(
                        //   value: GameStateBloc(
                        //       signalRProvider, authBloc, game, stage),
                        // )

                        // ProxyProvider<SignalRProvider, GameStateBloc>(
                        //   create: (context) =>
                        //       GameStateBloc(signalRBloc, authBloc, game, stage),
                        //   update: (context, value, previous) =>
                        //       GameStateBloc(value, authBloc, game, stage),
                        // )
                      ],
                      builder: (context, child) {
                        return RequestSendScreen(game);
                      });
                }));
              });
            },
            child: Text("Create"),
          ),
        ],
      ),
      //   );
      // },
    );
  }
}
