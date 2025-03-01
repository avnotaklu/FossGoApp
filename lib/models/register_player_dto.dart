import 'dart:convert';

class RegisterPlayerDto {
  final String connectionId;
  RegisterPlayerDto({
    required this.connectionId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'connectionId': connectionId,
    };
  }

  factory RegisterPlayerDto.fromMap(Map<String, dynamic> map) {
    return RegisterPlayerDto(
      connectionId: map['connectionId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterPlayerDto.fromJson(String source) =>
      RegisterPlayerDto.fromMap(json.decode(source) as Map<String, dynamic>);
}
