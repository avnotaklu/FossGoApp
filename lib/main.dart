import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go/blocs/auth_bloc.dart';
import 'package:go/board.dart';
import 'package:go/gameplay.dart';
import 'package:go/homepage/homepage.dart';
import 'package:go/services/signin.dart';
import 'package:go/utils.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'game.dart';
import 'gameplay.dart';
import 'multiplayer/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (context) => AuthBloc(),
        child: MultiplayerData(
          database: FirebaseDatabase.instance.reference(),
          mChild: MaterialApp(home: SignIn(), routes: <String, WidgetBuilder>{
            '/GameScreen': (BuildContext context) => GameScreen.createGame(),
            '/HomePage': (BuildContext context) => HomePage(),
          }),
        ));
  }
}

class GameScreen extends StatelessWidget {
  static const title = 'Grid List';
  GameMatch? match = null;

  @override
  GameScreen(this.match);
  GameScreen.createGame();
  Widget build(BuildContext context) {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    Game? game;

    debugPrint(MultiplayerData.of(context)?.database.toString());

    print("getting started");

    if (match == null) {
      var str = authBloc.currentUser.listen((user) {
        print("hurray");
        var newPlace = MultiplayerData.of(context)?.game_ref.push();
        match = GameMatch(9, 9, 5 * 60, newPlace.key, {1: user?.uid, 0: user?.uid});
        newPlace.set(match?.toJson());
        game = Game(0, match as GameMatch);
      });
    }
    else game = Game(0, match as GameMatch);


    return StreamBuilder(
      stream: authBloc.currentUser,
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        backgroundColor: Colors.green,
        body: game,
      ),
    );
  }
}
