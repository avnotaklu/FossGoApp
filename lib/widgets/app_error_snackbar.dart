import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';

showAppErrorSnackBar<T>(
  BuildContext context,
  Either<AppError, T> error, {
  String? successPhrase,
}) {
  error.fold(
    (l) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.message),
          backgroundColor: Colors.red,
        ),
      );
    },
    (r) {
      if (successPhrase != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successPhrase),
            backgroundColor: Colors.green,
          ),
        );
      }
    },
  );
}
