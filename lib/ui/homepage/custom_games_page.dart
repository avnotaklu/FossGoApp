import 'dart:async';
import 'package:go/constants/constants.dart' as Constants;
import 'dart:io';
import 'package:async/async.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/create/stone_selection_widget.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/game.dart';
import 'package:go/models/stone_representation.dart';
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

class CustomGamesPage extends StatefulWidget {
  const CustomGamesPage({super.key});

  @override
  State<CustomGamesPage> createState() => _CustomGamesPageState();
}

class _CustomGamesPageState extends State<CustomGamesPage> {
  @override
  void initState() {
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
                                showDialog(
                                    context: context,
                                    builder: (context) => MultiProvider(
                                            providers: [
                                              ChangeNotifierProvider.value(
                                                value: signalRBloc,
                                              ),
                                              ChangeNotifierProvider(
                                                create: (context) =>
                                                    CreateGameProvider(
                                                        signalRBloc)
                                                      ..init(),
                                              )
                                            ],
                                            builder: (context, child) {
                                              return const CreateGameScreen();
                                            }));
                              },
                              child: const Text("create game")),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text("Games", style: TextStyle(fontSize: 30)),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          context.read<HomepageBloc>().availableGames.length,
                      itemBuilder: (context, index) {
                        final game =
                            context.read<HomepageBloc>().availableGames[index];
                        return GameCard(game: game);
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

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    final homepageBloc = context.read<HomepageBloc>();
    final signalRBloc = context.read<SignalRProvider>();
    final authBloc = context.read<AuthProvider>();

    void joinGame() async {
      var res = await homepageBloc.joinGame(
          game.gameId, context.read<AuthProvider>().token!);
      res.fold((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
      }, (joinMessage) {
        Navigator.pushReplacement(context,
            MaterialPageRoute<void>(builder: (BuildContext context) {
          var stage = StageType.BeforeStart;
          return MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                  value: signalRBloc,
                )
              ],
              builder: (context, child) {
                final authBloc = context.read<AuthProvider>();
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
    }

    return GestureDetector(
      onTap: joinGame,
      child: Card(
          child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game.gameId),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("You play: "),
                StoneSelectionWidget(game.stoneSelectionType, false)
              ],
            )
          ],
        ),
      )),
    );
  }
}
