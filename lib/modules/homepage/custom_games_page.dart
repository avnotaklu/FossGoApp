import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/homepage/create_game_screen.dart';

import 'package:go/modules/homepage/create_game_provider.dart';
import 'package:go/modules/homepage/home_page.dart';
import 'package:go/modules/homepage/homepage_bloc.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/homepage/game_card.dart';
import 'package:go/modules/homepage/matchmaking_page.dart';
import 'package:go/widgets/buttons.dart';
import 'package:go/widgets/my_max_width_box.dart';
import 'package:go/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CustomGamesPage extends StatefulWidget {
  const CustomGamesPage({super.key});

  @override
  State<CustomGamesPage> createState() => _CustomGamesPageState();
}

class _CustomGamesPageState extends State<CustomGamesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomepageBloc>(
      builder: (context, homepageBloc, child) {
        return Consumer<SignalRProvider>(
          builder: (context, signalRBloc, child) {
            if (context.read<SignalRProvider>().connectionId.isLeft()) {
              return const Center(child: CircularProgressIndicator());
            }

            return MyMaxWidthBox(
              maxWidth: context.tabletBreakPoint.end,
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (context.read<HomepageBloc>().availableGames.isEmpty)
                        Text(
                          'No Available Games',
                          style: context.textTheme.titleLarge,
                        )
                      else ...[
                        Text(
                          'Available Games',
                          style: context.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Consumer<HomepageBloc>(
                              builder: (context, homeBloc, child) =>
                                  ListView.builder(
                                shrinkWrap: true,
                                itemCount: homeBloc.availableGames.length,
                                itemBuilder: (context, index) {
                                  final game = homeBloc.availableGames[index];
                                  return GameCard(
                                    game: game.game,
                                    otherPlayerData: game.creatorInfo,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                      Spacer(),
                      Center(
                        child: PrimaryButton(
                          onPressed: () {
                            showLiveCreateCustomGameDialog(context);
                          },
                          text: "Create New",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
