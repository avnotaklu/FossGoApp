// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/middleware/board_utility/cluster.dart';
import 'package:go/models/position.dart';

extension StoneExt on Stone {
  Position toPosition() {
    return position;
  }

  StoneType toStoneType() {
    return player == 0 ? StoneType.black : StoneType.white;
  }
}

class Stone {
  final Position position;
  final int player;
  final Cluster cluster;

  Stone({required this.position, required this.player, required this.cluster});

  Stone copyWith({
    Position? position,
    int? player,
    Cluster? cluster,
  }) {
    return Stone(
      position: position ?? this.position,
      player: player ?? this.player,
      cluster: cluster ?? this.cluster,
    );
  }

  Stone deepCopy() {
    return Stone(
      position: position,
      player: player,
      cluster: cluster.deepCopy(),
    );
  }
}
