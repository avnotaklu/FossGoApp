// ignore_for_file: public_member_api_docs, sort_constructors_first
class ApiError {
  String message;
  int statusCode;

  ApiError({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiError(message: $message,\n statusCode: $statusCode)';
}
