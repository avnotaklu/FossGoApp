import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/modules/auth/sign_up_provider.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Provider<SignUpProvider>(
      create: (context) => SignUpProvider(authBloc: context.read()),
      builder: (context, child) {
        final signUpPro = context.read<SignUpProvider>();
        return Scaffold(
          appBar: const MyAppBar("Sign Up"),
          body: Form(
            key: key,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: userNameController,
                      validator: (v) =>
                          signUpPro.usernameValidator().flutterFieldValidate(v),
                      decoration: const InputDecoration(
                        hintText: 'Username',
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
                          var userResponse = await signUpPro.signUp(
                            userNameController.text,
                            passwordController.text,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(userResponse.fold(
                                  (e) => e.message,
                                  (v) => "Successfully logged in",
                                )),
                              ),
                            );
                          }
                        },
                        child: const Text("Sign Up")),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
