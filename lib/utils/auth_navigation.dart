import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/auth/error_screen.dart';
import 'package:go/modules/auth/new_o_auth_screen.dart';
import 'package:go/models/user_account.dart';
import 'package:go/models/user_authentication_model.dart';
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
      Navigator.of(context).pushNamedAndRemoveUntil("/Root", (route) => false);
    }
  });
}

void googleOAuthNavigation(
    BuildContext context, Either<AppError, Either<String, UserAccount>> res) {
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
    r.fold((l) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NewOAuthAccountScreen(token: l),
        ),
      );
    }, (r) {
      return Navigator.of(context).pushNamedAndRemoveUntil(
        '/HomePage',
        (route) => false,
      );
    });
  });
}
