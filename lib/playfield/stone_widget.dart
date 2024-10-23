import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/position.dart';
import 'package:flutter/foundation.dart';

class StoneWidget extends StatelessWidget {
  Color? color;
  // Cluster cluster;
  Position pos;

  StoneWidget(this.color, this.pos, {super.key});

  @override
  Widget build(BuildContext context) {
    // for (var i in cluster.data) {
    //   debugPrint(cluster.data.length.toString());
    //   debugPrint(cluster.freedoms.toString());
    //   debugPrint(StoneLogic.of(context)
    //       ?.playgroundMap[i]
    //       ?.cluster
    //       .data
    //       .length
    //       .toString());
    //   debugPrint(StoneLogic.of(context)
    //       ?.playgroundMap[i]
    //       ?.cluster
    //       .freedoms
    //       .toString());
    //   debugPrint("${i.x} ${i.y} belongs to currently inserted stone cluster");
    //   assert(StoneLogic.of(context)?.playgroundMap[i]?.cluster == cluster);
    // }

    return Container(
        // child: Stack(
        // children: [
        // Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)
        // ),
        // widget.cluster,
        // Text(StoneLogic.of(context)?.stoneAt(cluster.data.first)?.cluster.freedoms.toString() ?? ""),
        // ],
        // Text(widget.cluster.freedoms.toString())
        // ),
        );
  }
}



// class Cluster extends StatefulWidget {
//   List<Position> data;
//   Cluster(this.data);
//   int freedoms = 0;
// 
//   @override
//   State<Cluster> createState() => _ClusterState();
// }
// 
// class _ClusterState extends State<Cluster> {
// 
//   Widget build(BuildContext context) {
//     
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//                   
//                 });
//       },
// 
//       child: Text(widget.freedoms.toString()),
//       );
//   }
// }
