import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/auth/sign_up_provider.dart';
import 'package:go/utils/auth_navigation.dart';
import 'package:go/widgets/loader_basic_button.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:go/widgets/my_max_width_box.dart';
import 'package:go/widgets/my_text_form_field.dart';
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
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Provider<SignUpProvider>(
      create: (context) =>
          SignUpProvider(authBloc: context.read(), api: context.read()),
      builder: (context, child) {
        final signUpPro = context.read<SignUpProvider>();
        return Scaffold(
          appBar: const MyAppBar(
            "Baduk",
            showBackButton: true,
          ),
          body: MyMaxWidthBox(
            maxWidth: context.tabletBreakPoint.end,
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Create Your\n Account",
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineLarge,
                        ),
                        SizedBox(height: context.height * 0.1),
                        MyTextFormField(
                          hintText: "Username",
                          controller: userNameController,
                          validator: (v) => signUpPro
                              .usernameValidator()
                              .flutterFieldValidate(v),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        MyTextFormField(
                          hintText: "Password",
                          obscureText: true,
                          controller: passwordController,
                          validator: (v) => signUpPro
                              .passwordValidator()
                              .flutterFieldValidate(v),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        LoaderBasicButton(
                            onPressed: () async {
                              var response = await signUpPro.signUp(
                                userNameController.text,
                                passwordController.text,
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
                            label: "Sign Up"),
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
