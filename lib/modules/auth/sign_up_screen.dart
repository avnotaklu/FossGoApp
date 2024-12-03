import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/main.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';
import 'package:go/modules/gameplay/game_state/live_game_interactor.dart';
import 'package:go/modules/auth/sign_up_provider.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Provider<SignUpProvider>(
      create: (context) => SignUpProvider(authBloc: context.read()),
      builder: (context, child) => Scaffold(
        appBar: MyAppBar("Sign Up"),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      var userResponse =
                          await context.read<SignUpProvider>().signUp(
                                emailController.text,
                                passwordController.text,
                              );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(userResponse.fold(
                            (e) => e.message,
                            (v) => "Successfully logged in",
                          )),
                        ),
                      );
                    },
                    child: const Text("Sign Up")),
              ],
            ),
          ),
        ),
      ),
      // child: Container(
      //   child: Center(
      //     child: Padding(
      //       padding: const EdgeInsets.all(20.0),
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           TextField(
      //             controller: emailController,
      //             decoration: const InputDecoration(
      //               hintText: 'Email',
      //               border: OutlineInputBorder(),
      //             ),
      //           ),
      //           SizedBox(
      //             height: 20,
      //           ),
      //           TextField(
      //             controller: passwordController,
      //             decoration: const InputDecoration(
      //               hintText: 'Password',
      //               border: OutlineInputBorder(),
      //             ),
      //           ),
      //           SizedBox(
      //             height: 20,
      //           ),
      //           ElevatedButton(
      //               onPressed: () async {
      //                 var userResponse =
      //                     await context.read<SignUpProvider>().signUp(
      //                           emailController.text,
      //                           passwordController.text,
      //                         );
      //                 userResponse.fold((e) {
      //                   ScaffoldMessenger.of(context).showSnackBar(
      //                     SnackBar(
      //                       content: Text(e.message),
      //                     ),
      //                   );
      //                 }, (v) {
      //                   ScaffoldMessenger.of(context).showSnackBar(
      //                     SnackBar(
      //                       content: Text("Successfully signed up"),
      //                     ),
      //                   );
      //                   context.read<AuthBloc>().setUser(v.user);
      //                 });
      //               },
      //               child: const Text("Sign Up"))
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
