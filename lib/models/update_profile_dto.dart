// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UpdateProfileDto {
  String? fullName;
  String? bio;
  String? nationality;

  UpdateProfileDto({
    this.fullName,
    this.bio,
    this.nationality,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'bio': bio,
      'nationality': nationality,
    };
  }

  factory UpdateProfileDto.fromMap(Map<String, dynamic> map) {
    return UpdateProfileDto(
      fullName: map['fullName'] != null ? map['fullName'] as String : null,
      bio: map['bio'] != null ? map['bio'] as String : null,
      nationality:
          map['nationality'] != null ? map['nationality'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdateProfileDto.fromJson(String source) =>
      UpdateProfileDto.fromMap(json.decode(source) as Map<String, dynamic>);
}
