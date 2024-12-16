import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/modules/gameplay/playfield_interface/live_game_widget.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';
import 'package:go/modules/homepage/homepage_bloc.dart';
import 'package:go/modules/gameplay/game_state/game_state_oracle.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:provider/provider.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.otherPlayerData,
  });

  final Game game;
  final PublicUserInfo? otherPlayerData;

  void joinGame(BuildContext context) async {
    final homepageBloc = context.read<HomepageBloc>();
    final signalRBloc = context.read<SignalRProvider>();

    var res = await homepageBloc.joinGame(
      game.gameId,
      context.read<AuthProvider>().token!,
    );
    res.fold((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    }, (GameJoinMessage joinMessage) {
                    final statRepo = context.read<IStatsRepository>();
      Navigator.pushReplacement(context,
          MaterialPageRoute<void>(builder: (BuildContext context) {
        return LiveGameWidget(joinMessage.game, joinMessage.getGameAndOpponent(),statRepo);
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => joinGame(context),
      child: Card(
          child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                otherPlayerData == null
                    ? const Text("Waiting")
                    : OppositionInfoWidget(opposition: otherPlayerData!),
                const SizedBox(height: 10),
                MyStoneInfoWidget(game: game, otherPlayerData: otherPlayerData)
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BoardSizeInfoWidget(game: game),
                const SizedBox(height: 10),
                TimeControlInfoWidget(game: game),
              ],
            )
          ],
        ),
      )),
    );
  }
}

class TimeControlInfoWidget extends StatelessWidget {
  const TimeControlInfoWidget({
    super.key,
    required this.game,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.end,
      text: TextSpan(
        text: "Time -  ",
        style: TextStyle(
            color: defaultTheme.mainLightTextColor,
            fontSize: 18,
            fontWeight: FontWeight.normal),
        children: [
          TextSpan(
            text: game.timeControl.repr(),
            style: TextStyle(
                color: defaultTheme.mainLightTextColor,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

class BoardSizeInfoWidget extends StatelessWidget {
  const BoardSizeInfoWidget({
    super.key,
    required this.game,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.end,
      text: TextSpan(
        text: "Board -  ",
        style: TextStyle(
            color: defaultTheme.mainLightTextColor,
            fontSize: 18,
            fontWeight: FontWeight.normal),
        children: [
          TextSpan(
            text: "${game.rows}x${game.columns}",
            style: TextStyle(
                color: defaultTheme.mainLightTextColor,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

class MyStoneInfoWidget extends StatelessWidget {
  const MyStoneInfoWidget({
    super.key,
    required this.game,
    required this.otherPlayerData,
  });

  final Game game;
  final PublicUserInfo? otherPlayerData;

  @override
  Widget build(BuildContext context) {
    final myId = context.read<AuthProvider>().myId;
    StoneSelectionType myColor = StoneSelectionType.auto;
    if (!game.didStart()) {
      var otherIsCreator = game.gameCreator == otherPlayerData?.id;
      if (otherIsCreator) {
        // This means other is creator, i get non selected type
        myColor = game.stoneSelectionType != StoneSelectionType.auto
            ? StoneSelectionType.values[1 - game.stoneSelectionType.index]
            : game.stoneSelectionType;
      } else {
        // I am creator and i get selected stone type
        myColor = game.stoneSelectionType;
      }
    } else {
      // Game is started, we can assign real stone type
      myColor = StoneSelectionType
          .values[game.getOtherStoneFromPlayerId(myId)!.index];
    }

    return Row(
      children: [
        RichText(
          // ignore: prefer_const_constructors
          text: TextSpan(
            text: "Your Stone  ",
            style: TextStyle(
                color: defaultTheme.mainLightTextColor,
                fontSize: 18,
                fontWeight: FontWeight.normal),
          ),
        ),
        SizedBox(
          height: 20,
          width: 20,
          child: StoneSelectionWidget(
            myColor,
          ),
        )
      ],
    );
  }
}

class OppositionInfoWidget extends StatelessWidget {
  const OppositionInfoWidget({
    super.key,
    required this.opposition,
  });

  final PublicUserInfo opposition;

  @override
  Widget build(BuildContext context) {
    return RichText(
      // ignore: prefer_const_constructors
      text: TextSpan(
        text: "VS  ",
        style: TextStyle(
            color: defaultTheme.mainLightTextColor,
            fontSize: 18,
            fontWeight: FontWeight.normal),
        children: [
          TextSpan(
            text: opposition.username ?? "Anonymous",
            style: TextStyle(
                color: defaultTheme.mainLightTextColor,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
