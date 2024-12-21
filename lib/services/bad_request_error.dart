import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
// {
//   "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",
//   "title": "One or more validation errors occurred.",
//   "status": 400,
//   "errors": {
//     "FullName": [
//       "Full name can only contain unicode characters, spaces, apostrophes, and hyphens."
//     ]
//   },
//   "traceId": "00-3b49ffbe973ba12cd5055e244fa432d5-9c9df9a5bf5200f0-00"
// }

class BadRequestError {
  final String type;
  final String title;
  final int status;
  final Map<String, List<String>> errors;
  final String traceId;
  BadRequestError({
    required this.type,
    required this.title,
    required this.status,
    required this.errors,
    required this.traceId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'title': title,
      'status': status,
      'errors': errors,
      'traceId': traceId,
    };
  }

  factory BadRequestError.fromMap(Map<String, dynamic> map) {
    return BadRequestError(
      type: map['type'] as String,
      title: map['title'] as String,
      status: map['status'] as int,
      errors: Map<String, List<String>>.from(
        ((map['errors'] as Map<String, dynamic>)
            .map((a, b) => MapEntry(a, List<String>.from(b as List<dynamic>)))),
      ),
      traceId: map['traceId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BadRequestError.fromJson(String source) =>
      BadRequestError.fromMap(json.decode(source) as Map<String, dynamic>);

  String get message => errors.isNotEmpty ? errors.values.first.first : title;
}
