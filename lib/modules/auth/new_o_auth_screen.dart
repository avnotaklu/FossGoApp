import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/auth/log_in_provider.dart';
import 'package:go/modules/auth/new_o_auth_provider.dart';
import 'package:go/utils/auth_navigation.dart';
import 'package:go/widgets/loader_basic_button.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:go/widgets/my_text_form_field.dart';
import 'package:provider/provider.dart';

class NewOAuthAccountScreen extends StatefulWidget {
  final String token;
  const NewOAuthAccountScreen({required this.token, super.key});

  @override
  State<NewOAuthAccountScreen> createState() => _NewOAuthAccountState();
}

class _NewOAuthAccountState extends State<NewOAuthAccountScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Provider<NewOAuthProvider>(
      create: (context) =>
          NewOAuthProvider(authBloc: context.read(), token: widget.token),
      builder: (context, child) {
        final pro = context.read<NewOAuthProvider>();
        return Scaffold(
          appBar: const MyAppBar(
            "Create Account",
            showBackButton: true,
          ),
          body: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Select a username",
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineLarge,
                    ),
                    SizedBox(height: context.height * 0.1),
                    MyTextFormField(
                      controller: usernameController,
                      hintText: 'Username',
                      validator: pro.usernameValidator().flutterFieldValidate,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    LoaderBasicButton(
                        onPressed: () async {
                          var response = await pro.signUp(
                            usernameController.text.trim(),
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
        );
      },
    );
  }
}
