import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/create/request_send.dart';
import 'package:go/playfield/game.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/main.dart';
import 'package:go/utils/models.dart';

class HomePage extends StatefulWidget {
  bool joiningGame = false;
  String joinedGame = '';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    debugPrint(
        "first line ${MultiplayerData.of(context)?.database.toString()}");
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            ElevatedButton(onPressed: () => 0, child: Text("create game")),
            ElevatedButton(
                onPressed: () => setState(() {
                      widget.joiningGame = true;
                    }),
                child: const Text("join game")),
            widget.joiningGame
                ? Column(children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          fillColor: Colors.red,
                          border: OutlineInputBorder(),
                          hintText: 'Enter a search term'),
                    ),
                    ElevatedButton(
                      onPressed: () => (Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => StreamBuilder(
                            builder: (context, snapshot) => StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                              GameMatch? match;
                              var matchBuilder = MultiplayerData.of(context)
                                  ?.database
                                  .child('game')
                                  .child(_controller.text)
                                  .orderByKey()
                                  .get()
                                  .then((value) {
                                match = GameMatch.fromJson(value.value);
                                return match;
                              });

                              return FutureBuilder(
                                  future: matchBuilder,
                                  builder: (context,
                                      AsyncSnapshot<GameMatch?> snapshot) {
                                    // if (snapshot.data != null) { return GameScreen(snapshot.data); } // this is correct as it will not allow match to be null when joining game as expected
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return CreateGame(snapshot.data ??
                                          GameMatch.empty(
                                            MultiplayerData.of(context)
                                                    ?.game_ref
                                                    .push()
                                                    .key
                                                    .toString()
                                                as String, // TODO this fails when new game id can't be created in database
                                          ));
                                    } // this checks only connection match can be null not ideal
                                    else
                                      return Center(
                                          child: Container(
                                              width: 40,
                                              height: 50,
                                              child:
                                                  CircularProgressIndicator()));
                                  });
                            }),
                          ),
                        ),
                      )),
                      child: Text("enter game"),
                    ),
                  ])
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
