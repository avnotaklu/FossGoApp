import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/minimal_rating.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/game_state/game_entrance_data.dart';
import 'package:go/modules/gameplay/playfield_interface/live_game_widget.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';
import 'package:go/modules/homepage/homepage_bloc.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/player_rating.dart';
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
    }, (data) {
      final statRepo = context.read<IStatsRepository>();
      Navigator.push(context,
          MaterialPageRoute<void>(builder: (BuildContext context) {
        return LiveGameWidget(data.game, data, statRepo);
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
                    : OppositionInfoWidget(
                        opposition: otherPlayerData!,
                        game: game,
                      ),
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
        style: context.textTheme.bodyLarge,
        children: [
          TextSpan(
            text: game.timeControl.getTimeControlDto().repr(),
            style: context.textTheme.labelLarge,
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
        style: context.textTheme.bodyLarge,
        children: [
          TextSpan(
            text: "${game.rows}x${game.columns}",
            style: context.textTheme.labelLarge,
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
            style: context.textTheme.bodyLarge,
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
    required this.game,
  });

  final PublicUserInfo opposition;
  final Game game;

  @override
  Widget build(BuildContext context) {
    final rating = opposition.rating?.getRatingForGame(game);

    final minRat =
        rating == null ? null : MinimalRating.fromRatingData(rating.glicko);

    return RichText(
      // ignore: prefer_const_constructors
      text: TextSpan(
        text: "VS  ",
        style: context.textTheme.bodyLarge,
        children: [
          TextSpan(
            text: opposition.username ?? "Anonymous",
            style: context.textTheme.labelLarge,
          ),
          if (minRat != null)
            TextSpan(
              text: "( ${minRat.stringify()} )",
              style: context.textTheme.labelLarge,
            ),
        ],
      ),
    );
  }
}
