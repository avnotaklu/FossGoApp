import 'package:firebase_auth/firebase_auth.dart';
import 'package:go/gameplay/create/create_game.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:share/share.dart';
// import 'package:/share/share.dart';
import 'constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/playfield/board.dart';
import 'package:go/ui/homepage/homepage.dart';
import 'package:go/services/signin.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/position.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ntp/ntp.dart';

import 'playfield/game.dart';
import 'models/game_match.dart';

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
        builder: (context, child) => StreamBuilder<User?>(
            stream: Provider.of<AuthBloc>(context).currentUser,
            builder: (context, snapshot) {
              return MultiplayerData(
                curUser: snapshot.data,
                database: FirebaseDatabase.instance.ref(),
                mChild: MaterialApp(home: snapshot.data != null ? HomePage() : SignIn(), routes: <String, WidgetBuilder>{
                  '/HomePage': (BuildContext context) => HomePage(),
                }),
              );
            }));
  }
}
