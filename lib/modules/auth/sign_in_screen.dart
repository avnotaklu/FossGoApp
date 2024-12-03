// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/modules/gameplay/game_state/live_game_interactor.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';

import 'package:go/modules/auth/error_screen.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  void initState() {
    var authBloc = Provider.of<AuthProvider>(context, listen: false);
    var signalRBloc = Provider.of<SignalRProvider>(context, listen: false);

    authBloc.authResult.listen((res) async {
      res.fold((l) {
        authBloc.logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ErrorPage(l),
          ),
          (route) => route.isFirst,
        );
      }, (r) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/HomePage',
          (route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SignInButton(
            Buttons.Google,
            onPressed: () async {
              var result = await authBloc.loginGoogle();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.fold(
                      (l) => l.toString(), (r) => "Successfully logged in")),
                ),
              );
            },
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/SignUp',
                );
              },
              child: const Text("Sign Up")),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/LogIn',
                );
              },
              child: const Text("Log In")),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      var game = testGameConstructor();
                      return GameWidget(
                        game: game,
                        gameInteractor: FaceToFaceGameInteractor(
                          game,
                          systemUtils,
                        ),
                      );
                    },
                  ),
                );
              },
              child: const Text("Over the board"))
        ]),
      ),
    );
  }
}
