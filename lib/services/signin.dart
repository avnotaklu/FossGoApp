import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:go/blocs/auth_bloc.dart';
import 'package:go/game.dart';
import 'package:go/homepage/homepage.dart';
import 'package:go/main.dart';
import 'package:go/services/auth.dart';
import 'package:provider/provider.dart';

import '../gameplay.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  void initState() {
    // TODO: implement initState
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    authBloc.currentUser.listen((user) {
      if (user != null) {
        Navigator.of(context).pushReplacementNamed(
        '/HomePage',  
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SignInButton(
            Buttons.Google,
            onPressed: () => authBloc.loginGoogle(),
          ),
        ]),
      ),
    );
  }
}
