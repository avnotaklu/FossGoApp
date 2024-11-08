// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:go/core/error_handling/api_error.dart';
import 'package:go/core/error_handling/base_error.dart';

class AppError extends BaseError {
  final String message;
  AppError({
    required this.message,
  });

  @override
  String toString() => 'AppError(message: $message)';

  AppError.fromApiError(ApiError error)
      : message = error.message.isEmpty
            ? error.reasonPhrase ?? "Internal Server Error"
            : error.message;
}

class RegisterError extends AppError {
  RegisterError({
    required super.message,
  });

  @override
  String toString() => 'RegisterError(message: $message)';

}
