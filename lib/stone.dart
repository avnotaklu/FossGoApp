import 'package:flutter/material.dart';
import 'package:go/utils.dart';
import 'package:flutter/foundation.dart';
import 'gameplay.dart';

class Stone extends StatelessWidget {
  Color? color;
  Cluster cluster;

  Stone(this.color, Position pos) : cluster = Cluster({pos});

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
      child: Stack(
        children: [
          Container(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          // widget.cluster,
          Text(StoneLogic.of(context)?.playground_Map[cluster.data.first]?.cluster.freedoms.toString() as String),
        ],
        // Text(widget.cluster.freedoms.toString())
      ),
    );
  }
  
}

class Cluster {
  Set<Position> data;
  Cluster(this.data);
  int freedoms = 0;
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
