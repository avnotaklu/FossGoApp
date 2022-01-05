import 'package:firebase_auth/firebase_auth.dart';
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
        builder: (context,child) => StreamBuilder(
            stream: Provider.of<AuthBloc>(context, listen: false).currentUser,
            builder: (context, snapshot) {
              return snapshot.data != null ? 
              MultiplayerData(
                curUser : snapshot.data,
                database: FirebaseDatabase.instance.reference(),
                mChild:
                    MaterialApp(home: SignIn(), routes: <String, WidgetBuilder>{
                  '/GameScreen': (BuildContext context) =>
                      GameScreen.createGame(),
                  '/HomePage': (BuildContext context) => HomePage(),
                }),
              ) : Text("hello");
            }));
  }
}

class GameScreen extends StatelessWidget {
  static const title = 'Grid List';
  GameMatch? match;

  @override
  GameScreen(this.match);
  GameScreen.createGame();
  Widget build(BuildContext context) {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    Game? game;

    debugPrint(MultiplayerData.of(context)?.database.toString());

    print("getting started");

    authBloc.currentUser.listen((user) {
      if (match == null) {
        print("hurray");
        var newPlace = MultiplayerData.of(context)?.game_ref.push();
        match = GameMatch(9, 9, 5 * 60, newPlace.key,
            {0: user?.uid, 1: null}); // Don't delete default values 0 or 1
        // Json parser depends on it.
        newPlace.set(match?.toJson());
        // game = Game(0, match as GameMatch);
      } else {
        if (match?.uid[1] == null) {
          match?.uid[1] = user?.uid;
          MultiplayerData.of(context)
              ?.gameRef
              .child(match?.id.toString())
              .child('uid')
              .update({1.toString(): user?.uid.toString()});
        }
      }
    });

    return StreamBuilder(
      stream: authBloc.currentUser,
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          title: const Text(title),
          actions: <Widget>[
            TextButton(onPressed: authBloc.logout, child: Text("logout")),
          ],
        ),
        backgroundColor: Colors.green,
        body: snapshot.hasData
            ? Game(0, match as GameMatch, snapshot.data as User)
            : Text("current user not detected"),
      ),
    );
  }
}
