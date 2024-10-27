import 'package:flutter/material.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/game.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/utils/widgets/buttons.dart';
import 'package:provider/provider.dart';

class RequestSendScreen extends StatefulWidget {
  final Game game;
  const RequestSendScreen(this.game, {super.key});

  @override
  State<RequestSendScreen> createState() => _RequestSendScreenState();
}

class _RequestSendScreenState extends State<RequestSendScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SignalRProvider>(
        builder: (context, value, child) => BackgroundScreenWithDialog(
              child: ShareGameIDButton(widget.game),
            ));
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
    return Consumer<SignalRProvider>(
      builder: (context, signalRBloc, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(flex: 4, child: Container()),
            const Expanded(flex: 4, child: TextField()),
            Expanded(flex: 4, child: Container()),
            Expanded(
                flex: 2,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BadukButton(
                        onPressed: () {
                          final signalRProvider =
                              context.read<SignalRProvider>();

                          final authBloc = context.read<AuthProvider>();
                          var stage = BeforeStartStage();
                          // final gameStatebloc = context.read<GameStateBloc>();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider(
                                    create: (context) => GameStateBloc(
                                      signalRProvider,
                                      authBloc,
                                      widget.game,
                                      stage,
                                      null,
                                    ),
                                  ),
                                  ChangeNotifierProvider.value(
                                    value: signalRProvider,
                                  )
                                ],
                                builder: (context, child) =>
                                    GameWidget(widget.game, true),
                              ),
                            ),
                          );
                        },
                        child: const Text("Share"),
                      ),
                      widget.circularIndicator ?? Container(),
                    ])),
            Expanded(flex: 4, child: Container()),
            Expanded(flex: 1, child: Container()),
          ],
        );
      },
    );
  }
}
