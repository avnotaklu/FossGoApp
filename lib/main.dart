import 'package:firebase_auth/firebase_auth.dart';
import 'package:go/firebase_options.dart';
import 'package:go/gameplay/create/create_game.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/providers/sign_up_provider.dart';
import 'package:go/services/app_user.dart';
import 'package:go/views/log_in_screen.dart';
import 'package:go/views/sign_up_screen.dart';
// import 'package:/share/share.dart';
import 'constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/playfield/board.dart';
import 'package:go/ui/homepage/homepage.dart';
import 'package:go/services/sign_in_screen.dart';
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (context) => AuthBloc(),
        builder: (context, child) => StreamBuilder<AppUser?>(
            stream: Provider.of<AuthBloc>(context).currentUser,
            builder: (context, snapshot) {
              return MultiplayerData(
                curUser: snapshot.data,
                database: FirebaseDatabase.instance.reference(),
                mChild: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: DefaultTextStyle(
                      style: TextStyle(color: Constants.defaultTheme.mainTextColor, fontSize: 15),
                      child: snapshot.data != null ? HomePage() : SignIn(),
                    ),
                    theme: ThemeData(
                      // Define the default brightness and colors.
                      brightness: Brightness.dark,
                      primaryColor: Colors.red[800],
                      // textTheme: TextTheme(
                      //   button: TextStyle(color: Constants.defaultTheme.mainTextColor, fontSize: 15),
                      // ),
                      textButtonTheme: TextButtonThemeData(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all<Color>(Constants.defaultTheme.mainTextColor),
                        ),
                      ),
                      
                      buttonTheme: ButtonThemeData(
                        buttonColor: Constants.defaultTheme.mainHighlightColor,
                      ),
                    ),
                    routes: <String, WidgetBuilder>{
                      '/HomePage': (BuildContext context) => HomePage(),

                      '/SignUp': (BuildContext context) => SignUpScreen(),

                      '/LogIn': (BuildContext context) => LogInScreen(),
                    }),
              );
            }));
  }
}
