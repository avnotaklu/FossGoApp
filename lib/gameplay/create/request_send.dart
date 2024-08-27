import 'package:flutter/material.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/playfield/game.dart';
import 'package:go/models/game_match.dart';
import 'package:go/utils/widgets/buttons.dart';

class RequestSend extends StatelessWidget {
  final GameMatch match;
  const RequestSend(this.match);
  @override
  Widget build(BuildContext context) {
    return BackgroundScreenWithDialog(
      child: ShareGameIDButton(match),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(flex: 4, child: Container()),
        Expanded(flex: 4, child: TextField()),
        Expanded(flex: 4, child: Container()),
        Expanded(
            flex: 2,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              BadukButton(
                onPressed: () {
                  MultiplayerData.of(context)!.createGameDatabaseRefs(widget.match.id);

                  // if (widget.match.isComplete()) {
                  //   Share.share(widget.match.id);
                  // }

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => Game(widget.match, true, BeforeStartStage()),
                      ));
                },
                child: const Text("Share"),
              ),
              widget.circularIndicator ?? Container(),
            ])),

        Expanded(flex: 4, child: Container()),
        Expanded(flex: 1, child: Container()),
      ],
    );
  }
}
