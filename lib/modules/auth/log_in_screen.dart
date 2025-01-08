import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/auth/log_in_provider.dart';
import 'package:go/utils/auth_navigation.dart';
import 'package:go/widgets/loader_basic_button.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:go/widgets/my_text_form_field.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final emailOrUsernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Provider<LogInProvider>(
      create: (context) => LogInProvider(authBloc: context.read()),
      builder: (context, child) {
        final pro = context.read<LogInProvider>();
        return Scaffold(
          appBar: const MyAppBar(
            "Log In",
            showBackButton: true,
          ),
          body: MaxWidthBox(
            maxWidth: context.tabletBreakPoint.end,
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Log in to your\n Account",
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineLarge,
                        ),
                        SizedBox(height: context.height * 0.1),
                        MyTextFormField(
                          controller: emailOrUsernameController,
                          hintText: 'Email/Username',
                          validator: pro
                              .emailOrUsernameValidator()
                              .flutterFieldValidate,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        MyTextFormField(
                          controller: passwordController,
                          hintText: 'Password',
                          validator:
                              pro.passwordValidator().flutterFieldValidate,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        LoaderBasicButton(
                            onPressed: () async {
                              var response =
                                  await context.read<LogInProvider>().logIn(
                                        emailOrUsernameController.text.trim(),
                                        passwordController.text.trim(),
                                      );
                              if (context.mounted) {
                                authNavigation(context, response);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response.fold(
                                      (e) => e.message,
                                      (v) => "Successfully logged in",
                                    )),
                                  ),
                                );
                              }
                            },
                            label: "Log In")
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
