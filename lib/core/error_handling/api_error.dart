// ignore_for_file: public_member_api_docs, sort_constructors_first
class ApiError {
  String message;
  String? reasonPhrase;
  int statusCode;

  ApiError({
    required this.message,
    required this.reasonPhrase,
    required this.statusCode,
  });

  @override
  String toString() =>
      'ApiError(message: $message,\n statusCode: $statusCode,\n reasonPhrase: $reasonPhrase)';
}
