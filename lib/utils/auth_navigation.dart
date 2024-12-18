import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/auth/error_screen.dart';
import 'package:go/services/user_account.dart';
import 'package:go/services/user_authentication_model.dart';
import 'package:provider/provider.dart';

void authNavigation(
    BuildContext context, Either<AppError, AbstractUserAccount?> res) {
  final authBloc = context.read<AuthProvider>();
  res.fold((l) {
    authBloc.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => ErrorPage(l),
      ),
      (route) => route.isFirst,
    );
  }, (r) {
    if (r != null) {
      return Navigator.of(context).pushNamedAndRemoveUntil(
        '/HomePage',
        (route) => false,
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
    }
  });
}
