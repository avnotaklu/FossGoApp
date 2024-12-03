import 'package:go/core/error_handling/base_error.dart';

class HttpError extends BaseError {
  final String message;

  HttpError({
    required this.message,
  });

  @override
  String toString() =>
      'HttpError(message: $message)';
}
