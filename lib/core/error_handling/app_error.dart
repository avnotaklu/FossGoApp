// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:go/core/error_handling/base_error.dart';

class AppError extends BaseError {
  final String message;
  AppError({
    required this.message,
  });

  @override
  String toString() => 'AppError(message: $message)';
}
