import 'package:flutter/material.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/game.dart';
import 'package:go/utils/widgets/buttons.dart';

class RequestSendScreen extends StatelessWidget {
  final Game game;
  const RequestSendScreen(this.game, {super.key});
  @override
  Widget build(BuildContext context) {
    return BackgroundScreenWithDialog(
      child: ShareGameIDButton(game),
    );
  }
}

class ShareGameIDButton extends StatefulWidget {
  final Game game;
  ShareGameIDButton(this.game, {super.key});
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
        const Expanded(flex: 4, child: TextField()),
        Expanded(flex: 4, child: Container()),
        Expanded(
            flex: 2,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              BadukButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => GameWidget(widget.game, true),
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
