import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/playfield/game.dart';
import 'package:go/utils/models.dart';
import 'package:share/share.dart';

class BackgroundScreenWithDialog extends StatelessWidget {
  @override
  final Widget child;
  BackgroundScreenWithDialog({required this.child});

  Widget build(BuildContext context) {
    // TODO: implement build
    return Positioned.fill(
        child: Container(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.6,
        child: Dialog(backgroundColor: Colors.blue, child: child),
      ),
      decoration: BoxDecoration(color: Colors.green),
    ));
  }
}

Stream<bool> checkGameEnterable(BuildContext context, GameMatch match) {
  StreamController<bool> controller = StreamController<bool>();
  MultiplayerData.of(context)?.getCurGameRef(match.id).set(match.toJson());
  if (match.isComplete()) {
    bool gameEnterable = false;
    var changeStream = MultiplayerData.of(context)
        ?.getCurGameRef(match.id)
        .child('uid')
        .onValue
        .listen((event) {
      print(event.snapshot.value.toString());
      match.uid = Map<int?, String?>.from(event.snapshot.value
          .asMap()
          .map((i, element) => MapEntry(i as int, element.toString())));
      if (match.bothPlayers.contains(null) == false) {
        // gameEnterable = true;
        controller.add(true);
      } else {
        // gameEnterable = false;
        controller.add(false);
      }
    });
  }
  return controller.stream;
}

class EnterGameButton extends StatelessWidget {
  final match;
  final newPlace;
  EnterGameButton(this.match, this.newPlace);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Expanded(
      flex: 2,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white)),
        onPressed: () {
          newPlace.set(match.toJson());
          if (match.isComplete()) {
            MultiplayerData.of(context)
                ?.getCurGameRef(match.id)
                .child('uid')
                .onValue
                .listen((event) {
              print(event.snapshot.value.toString());
              match.uid = Map<int?, String?>.from(event.snapshot.value
                  .asMap()
                  .map((i, element) => MapEntry(i as int, element.toString())));
              if (match.bothPlayers.contains(null) == false) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => Game(0, match),
                    ));
              }
            });
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    const Text("Match wasn't created"),
              ),
            );
          }
        },
        child: Container(),
      ),
    );
  }
}

class ShareGameIDButton extends StatefulWidget {
  final GameMatch match;
  ShareGameIDButton(this.match);
  Widget? circularIndicator;

  @override
  State<ShareGameIDButton> createState() => _ShareGameIDButtonState();
}

class _ShareGameIDButtonState extends State<ShareGameIDButton> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(flex: 10, child: Container()),
        Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
              ElevatedButton(
                onPressed: () {
                  if (widget.match.isComplete()) {
                    Share.share(widget.match.id);
                  }
                  checkGameEnterable(context, widget.match).listen((event) {
                    if (event) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                Game(0, widget.match),
                          ));
                    } else {
                      setState(() {
                        widget.circularIndicator = CircularProgressIndicator(
                          color: Colors.white,
                        );
                      });
                      // Navigator.pushReplacement(
                      //     context,
                      //     MaterialPageRoute<void>(
                      //       builder: (BuildContext context) => Center(
                      //           child: Container(
                      //               width: 40,
                      //               height: 50,
                      //               child: CircularProgressIndicator())),
                      //     ));
                    }
                  });
                },
                child: Container(
                  child: Text("Share"),
                ),
              ),
              widget.circularIndicator ?? Container(),
            ])),
        Expanded(flex: 1, child: Container()),
      ],
    );
  }
}
