import 'package:flutter/material.dart';
import 'package:go/modules/auth/log_in_provider.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Provider<LogInProvider>(
      create: (context) => LogInProvider(authBloc: context.read()),
      builder:(context, child) => Scaffold(
        appBar: const MyAppBar("Log In"),
        body: Container(
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
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        var userResponse =
                            await context.read<LogInProvider>().logIn(
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
                      child: const Text("Log In"))
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
        //                     await context.read<LogInProvider>().logIn(
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
        //                   context.read<AuthBloc>().setUser(v.user, v.token);
        //                 });
        //               },
        //               child: const Text("Log In"))
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
