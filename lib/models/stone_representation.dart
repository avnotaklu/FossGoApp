import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class StoneRepresentation {
  final int player;
  final int clusterId;
  final int clusterFreedoms;
  StoneRepresentation({
    required this.player,
    required this.clusterId,
    required this.clusterFreedoms,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'player': player,
      'clusterId': clusterId,
      'clusterFreedoms': clusterFreedoms,
    };
  }

  factory StoneRepresentation.fromMap(Map<String, dynamic> map) {
    return StoneRepresentation(
      player: map['player'] as int,
      clusterId: map['clusterId'] as int,
      clusterFreedoms: map['clusterFreedoms'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoneRepresentation.fromJson(String source) =>
      StoneRepresentation.fromMap(json.decode(source) as Map<String, dynamic>);

  StoneRepresentation.fromString(String val)
      : player = int.parse(val.split(' ')[0]),
        clusterId = int.parse(val.split(' ')[1]),
        clusterFreedoms = int.parse(val.split(' ')[1]);
}
