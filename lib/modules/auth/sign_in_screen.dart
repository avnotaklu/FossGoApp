// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/middleware/local_gameplay_server.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';

import 'package:go/modules/auth/error_screen.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/move_tree.dart';
import 'package:go/utils/auth_navigation.dart';
import 'package:go/widgets/loader_basic_button.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          LoaderCustomButton(
            onPressed: () async {
              var result = await authBloc.loginGoogle();
              if (context.mounted) {
                googleOAuthNavigation(context, result);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.fold(
                        (l) => l.toString(), (r) => "Successfully logged in")),
                  ),
                );
              }
            },
            buttonBuilder: (onPressed) => SignInButton(
              Buttons.Google,
              onPressed: onPressed,
            ),
          ),
          FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/SignUp',
                );
              },
              child: const Text("Sign Up")),
          const SizedBox(
            height: 20,
          ),
          FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/LogIn',
                );
              },
              child: const Text("Log In")),
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 20,
          ),
          LoaderBasicButton(
            onPressed: () async {
              var result = await authBloc.loginAsGuest();

              if (context.mounted) {
                authNavigation(context, result);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.fold(
                        (l) => l.toString(), (r) => "Logged in as guest")),
                  ),
                );
              }
            },
            label: "Enter as guest",
          ),
        ]),
      ),
    );
  }
}
