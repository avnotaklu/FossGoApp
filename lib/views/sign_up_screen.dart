import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go/main.dart';
import 'package:go/providers/sign_up_provider.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/views/my_app_bar.dart';
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
      create: (context) => SignUpProvider(),
      child: Scaffold(
        appBar: MyAppBar("Sign Up"),
        body: Provider<SignUpProvider>(
          create: (context) => SignUpProvider(),
          builder: (context, child) => Container(
            child: Center(
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
                          userResponse.fold((e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message),
                              ),
                            );
                          }, (v) async {
                            var signalRConnection =
                               await  context.read<SignalRBloc>().connectionId;
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
                                  content: Text("Successfully Signed up"),
                                ),
                              );
                            });
                          });
                        },
                        child: const Text("Sign Up"))
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
        ),
      ),
    );
  }
}
