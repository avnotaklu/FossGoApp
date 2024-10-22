import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/ui/homepage/homepage.dart';
import 'package:go/main.dart';
import 'package:go/services/auth.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    authBloc.currentUser.listen((user) {
      if (user != null) {
        print("got user");
        MultiplayerData?.of(context)?.setUser = user;
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/HomePage',
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SignInButton(
            Buttons.Google,
            onPressed: () async {
              var result = await authBloc.loginGoogle();
              result.fold((e) {
                debugPrint(e.toString());
              }, (v) async {
                var signalRConnection =
                    await context.read<SignalRBloc>().connectionId;
                signalRConnection.fold((e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message),
                    ),
                  );
                }, (connectionId) {
                  context
                      .read<AuthBloc>()
                      .setUser(v.user, v.token, connectionId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Successfully logged in"),
                    ),
                  );
                });
              });
            },
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/SignUp',
                );
              },
              child: Text("Sign Up")),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/LogIn',
                );
              },
              child: Text("Log In"))
        ]),
      ),
    );
  }
}
