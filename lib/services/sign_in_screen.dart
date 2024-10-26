// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/auth_provider.dart';
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
    var authBloc = Provider.of<AuthProvider>(context, listen: false);
    authBloc.currentUser.listen((user) async {
      if (user != null) {
        print("got user");
        // MultiplayerData?.of(context)?.setUser = user;
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/HomePage',
          (route) => false,
        );
      }
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
