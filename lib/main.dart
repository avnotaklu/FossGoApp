import 'package:firebase_auth/firebase_auth.dart';
// import 'package:/share/share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/playfield/board.dart';
import 'package:go/gameplay.dart';
import 'package:go/ui/homepage/homepage.dart';
import 'package:go/services/signin.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/position.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'playfield/game.dart';
import 'gameplay.dart';
import 'utils/models.dart';

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
        builder: (context, child) => StreamBuilder(
            stream: Provider.of<AuthBloc>(context, listen: false).currentUser,
            builder: (context, snapshot) {
              return snapshot.data != null
                  ? MultiplayerData(
                      curUser: snapshot.data,
                      database: FirebaseDatabase.instance.reference(),
                      mChild: MaterialApp(
                          home: SignIn(),
                          routes: <String, WidgetBuilder>{
                            '/GameScreen': (BuildContext context) =>
                                GameScreen.createGame(),
                            '/HomePage': (BuildContext context) => HomePage(),
                          }),
                    )
                  : MaterialApp(home: Text("hello"));
            }));
  }
}

class GameScreen extends StatelessWidget {
  static const title = 'Grid List';
  GameMatch? match;

  // ignore: use_key_in_widget_constructors
  GameScreen(this.match);

  // ignore: use_key_in_widget_constructors
  GameScreen.createGame();
  @override
  Widget build(BuildContext context) {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);

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

    return Stack(children: [
      Positioned.fill(
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
                                Container(),
                                Expanded(
                                    child: Stone(Colors.black, Position(0, 0))),
                                Expanded(
                                    child: Stone(Colors.white, Position(0, 0)))
                              ])),
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: DropdownButton(
                                    hint: Text("Board Size"), items: [])),
                            Expanded(
                                flex: 1,
                                child: Row(children: [
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      child: Container(child: Text("Time")),
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => Center(
                                          child: FractionallySizedBox(
                                            heightFactor: 0.8,
                                            widthFactor: 1.0,
                                            child: Dialog(
                                              child: CupertinoTimerPicker(
                                                  mode: CupertinoTimerPickerMode
                                                      .hms,
                                                  onTimerDurationChanged:
                                                      (value) {
                                                    debugPrint("hello");
                                                    match?.time =
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
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(children: [
                          // ElevatedButton(onPressed: () => Share.share(match?.id ?? "null"),child: Container(child: Text("Share"),),),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white)),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      Game(0, match as GameMatch),
                                ),
                              );
                            },
                            child: Container(),
                          ),
                        ]),
                      ),
                    ]))),
        decoration: BoxDecoration(color: Colors.green),
      )),
    ]);
  }
}
