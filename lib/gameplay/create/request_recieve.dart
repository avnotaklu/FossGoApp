import 'package:flutter/material.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/models/game.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/position.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/utils/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'create_game_screen.dart';
import 'package:go/constants/constants.dart' as Constants;

class RequestRecieve extends StatelessWidget {
  final GameJoinMessage joinMessage;
  final Game game;
  const RequestRecieve({super.key, required this.game, required this.joinMessage});
  @override
  Widget build(BuildContext context) {
    // int recieversTurn = (() {
    //   if (match.uid[0] == null) {
    //     return 0;
    //   } else {
    //     return 1;
    //   }
    // }).call();

    // // assert(match.uid[recieversTurn] == null);

    // match.uid[recieversTurn] =
    //     MultiplayerData.of(context)?.curUser!.email.toString();

    return BackgroundScreenWithDialog(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Spacer(),
      Expanded(
        flex: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: FittedBox(child: Text("You are playing")),
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 2,
              child: StoneWidget(
                  Constants.playerColors[game.players[
                      context.read<AuthProvider>().currentUserRaw!.id]!.index],
                  const Position(0, 0)),
            ),
          ],
        ),
      ),
      Expanded(flex: 4, child: Container()),
      Expanded(flex: 3, child: EnterGameButton(game,joinMessage)),
      const Spacer(flex: 3),
    ]));
  }
}

class EnterGameButton extends StatelessWidget {
  final GameJoinMessage joinMessage;

  final Game game;
  const EnterGameButton(this.game, this.joinMessage);
  @override
  Widget build(BuildContext context) {
    // try {
    //   MultiplayerData.of(context)!.createGameDatabaseRefs(game.game);
    // } catch (Exception) {
    //   throw "couldn't start game";
    // }

    return Expanded(
      flex: 2,
      child: BadukButton(
        onPressed: () {
          // newPlace.set(match.toJson());
          // if (match.isComplete()) {
          // MultiplayerData.of(context)!
          //     .curGameReferences!
          //     .game
          //     .child('uid')
          //     .onValue
          //     .listen((event) {
          //   print(event.snapshot.value.toString());
          // match.uid =
          //     GameMatch.uidFromJson(event.snapshot.value as List<Object?>);
          // if (match.bothPlayers.contains(null) == false) {

          final signalRBloc = context.read<SignalRProvider>();
          final authBloc = context.read<AuthProvider>();

          Navigator.pushReplacement(context,
              MaterialPageRoute<void>(builder: (BuildContext context) {
            var stage = BeforeStartStage();
            return ChangeNotifierProvider.value(
                value: signalRBloc,
                builder: (context, child) {
                  return ChangeNotifierProvider(
                      create: (context) =>
                          GameStateBloc(signalRBloc, authBloc, game, stage, joinMessage),
                      builder: (context, child) {
                        return GameWidget(game, false);
                      });
                });
          }));

          // }
          // });
          // } else {
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute<void>(
          //       builder: (BuildContext context) => const Text("Match wasn't created"),
          //     ),
          //   );
          // }
        },
        child: Text("Enter"),
      ),
    );
  }
}
