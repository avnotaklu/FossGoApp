import 'dart:async';
import 'package:go/constants/constants.dart' as Constants;
import 'dart:io';
import 'package:async/async.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/system_utilities.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/create/request_send_screen.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/main.dart';
import 'package:go/models/game_match.dart';
import 'package:go/providers/create_game_provider.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/homepage_bloc.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/utils/widgets/buttons.dart';
import 'package:go/views/my_app_bar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool joiningGame = false;
  String joinedGame = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    var homepageBloc = context.read<HomepageBloc>();
    homepageBloc.getAvailableGames(context.read<AuthProvider>().token!);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomepageBloc>(
      builder: (context, homepageBloc, child) {
        return Consumer<SignalRProvider>(
          builder: (context, signalRBloc, child) {
            if (context.read<SignalRProvider>().connectionId.isLeft()) {
              return const Center(child: CircularProgressIndicator());
            }

            return Scaffold(
              appBar: MyAppBar(
                "Home Page",
                trailing: IconButton(
                    onPressed: () {}, icon: const Icon(Icons.logout)),
              ),
              body: Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Container(
                    child: Center(
                      child: Column(
                        children: [
                          BadukButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MultiProvider(
                                            providers: [
                                              ChangeNotifierProvider.value(
                                                value: signalRBloc,
                                              ),
                                              Provider(
                                                create: (context) =>
                                                    CreateGameProvider(
                                                        signalRBloc),
                                              )
                                            ],
                                            builder: (context, child) {
                                              return const CreateGameScreen();
                                            })));
                              },
                              child: const Text("create game")),
                          BadukButton(
                              onPressed: () => setState(() {
                                    joiningGame = true;
                                  }),
                              child: const Text("join game")),
                        ],
                      ),
                    ),
                  ),
                  joiningGame
                      ? Column(children: [
                          TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                                fillColor: Colors.red,
                                border: OutlineInputBorder(),
                                hintText: 'Enter game id'),
                          ),
                          BadukButton(
                            onPressed: () {
                              // TODO: What to even do here??
                              // (Navigator.of(context).pushReplacement(
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         // StreamBuilder(
                              //         //   builder: (context, snapshot) =>
                              //         StatefulBuilder(builder:
                              //             (BuildContext context, StateSetter setState) {
                              //       GameMatch? match;
                              //       var matchBuilder = MultiplayerData.of(context)
                              //           ?.database
                              //           .child('game')
                              //           .child(_controller.text)
                              //           .orderByKey()
                              //           .get()
                              //           .then((value) {
                              //         match = GameMatch.fromJson(value.value as Map);
                              //         return match;
                              //       }).asStream();

                              //       return StreamBuilder(
                              //           stream: matchBuilder,
                              //           builder: (context,
                              //               AsyncSnapshot<GameMatch?> snapshot) {
                              //             // if (snapshot.data != null) { return GameScreen(snapshot.data); } // this is correct as it will not allow match to be null when joining game as expected
                              //             try {
                              //               if (snapshot.connectionState ==
                              //                   ConnectionState.done) {
                              //                 return CreateGame(snapshot.data);
                              //               }
                              //               {
                              //                 return const Center(
                              //                     child: SizedBox(
                              //                         width: 40,
                              //                         height: 50,
                              //                         child:
                              //                             CircularProgressIndicator()));
                              //               }
                              //             } catch (FirebaseException) {
                              //               // TODO sometimes this exception is caused catch it correctly
                              //               return const Center(
                              //                   child: SizedBox(
                              //                       width: 40,
                              //                       height: 50,
                              //                       child:
                              //                           CircularProgressIndicator()));
                              //             }
                              //           });
                              //     }),
                              //   ),
                              //   // ),
                              // ));
                            },
                            child: const Text("enter game"),
                          ),
                        ])
                      : const SizedBox.shrink(),
                  const SizedBox(height: 50),
                  const Text("Active Players", style: TextStyle(fontSize: 30)),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          context.read<HomepageBloc>().availableGames.length,
                      itemBuilder: (context, index) {
                        final game =
                            context.read<HomepageBloc>().availableGames[index];
                        return ListTile(
                          onTap: () async {
                            // Navigator.of(context).pushReplacement(
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             ChangeNotifierProvider.value(
                            //                 value: signalRBloc,
                            //                 builder: (context, child) {
                            var res = await homepageBloc.joinGame(game.gameId,
                                context.read<AuthProvider>().token!);
                            res.fold((e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.message),
                                ),
                              );
                            }, (joinMessage) {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute<void>(
                                      builder: (BuildContext context) {
                                var stage = StageType.BeforeStart;
                                return MultiProvider(
                                    providers: [
                                      ChangeNotifierProvider.value(
                                        value: signalRBloc,
                                      )
                                    ],
                                    builder: (context, child) {
                                      final authBloc =
                                          context.read<AuthProvider>();
                                      return ChangeNotifierProvider(
                                          create: (context) => GameStateBloc(
                                                Api(),
                                                signalRBloc,
                                                authBloc,
                                                game,
                                                systemUtils,
                                                stage,
                                                joinMessage,
                                              ),
                                          builder: (context, child) {
                                            return GameWidget(false);
                                          });
                                    });
                              }));
                            });
                            // })));
                          },
                          title: Text(game.gameId),
                          // onTap: () {
                          //   Navigator.of(context).pushReplacement(MaterialPageRoute(
                          //       builder: (context) => CreateGame(null)));
                          // },
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
