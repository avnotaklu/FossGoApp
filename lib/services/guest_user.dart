// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class GuestUser {
  final String id;

  GuestUser(this.id);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
    };
  }

  factory GuestUser.fromMap(Map<String, dynamic> map) {
    return GuestUser(
      map['id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GuestUser.fromJson(String source) =>
      GuestUser.fromMap(json.decode(source) as Map<String, dynamic>);
}
