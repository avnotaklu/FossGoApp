// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:go/firebase_options.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/providers/create_game_provider.dart';
import 'package:go/providers/homepage_bloc.dart';
import 'package:go/providers/sign_up_provider.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/app_user.dart';
import 'package:go/views/log_in_screen.dart';
import 'package:go/views/sign_up_screen.dart';
// import 'package:/share/share.dart';
import 'constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/playfield/board.dart';
import 'package:go/ui/homepage/homepage.dart';
import 'package:go/services/sign_in_screen.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/models/position.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:ntp/ntp.dart';

import 'playfield/game_widget.dart';
import 'models/game_match.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignalRProvider(),
      builder: (context, child) => MultiProvider(
        providers: [
          Provider(create: (context) => AuthProvider(context.read<SignalRProvider>())),
        ],
        builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: DefaultTextStyle(
            style: TextStyle(
                color: Constants.defaultTheme.mainTextColor, fontSize: 15),
            child: SignIn(),
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
                foregroundColor: WidgetStateProperty.all<Color>(
                    Constants.defaultTheme.mainTextColor),
              ),
            ),

            buttonTheme: ButtonThemeData(
              buttonColor: Constants.defaultTheme.mainHighlightColor,
            ),
          ),
          routes: <String, WidgetBuilder>{
            '/HomePage': (BuildContext context) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) =>
                        HomepageBloc(signalRProvider: context.read(), authBloc:  context.read()),
                  ),
                  // ChangeNotifierProvider(create: (context) => signalR),
                ],
                builder: (context, child) => HomePage(),
              );
            },
            '/SignUp': (BuildContext context) => SignUpScreen(),
            '/LogIn': (BuildContext context) => LogInScreen(),
            // '/CreateGame': (BuildContext context) => MultiProvider(
            //       providers: [
            //         ChangeNotifierProvider(
            //             create: (context) => context.read<SignalRProvider>()),
            //         Provider(
            //           create: (context) => CreateGameProvider(),
            //         ),
            //       ],
            //       builder: (context, child) => CreateGameScreen(),
            //     ),
          },
        ),
      ),
    );
  }
}
