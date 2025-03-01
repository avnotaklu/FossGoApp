import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/foundation/string.dart';
import 'package:go/core/utils/intl/formatters.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/core/utils/theme_helpers/text_theme_helper.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/gameplay/game_state/game_entrance_data.dart';
import 'package:go/modules/gameplay/playfield_interface/live_game_widget.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/stats/stats_page_provider.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/api.dart';
import 'package:go/models/player_rating.dart';
import 'package:go/models/user_stats.dart';
import 'package:go/widgets/basic_alert.dart';
import 'package:go/widgets/my_max_width_box.dart';
import 'package:go/widgets/section_divider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class StatsPage extends StatelessWidget {
  final VariantType defaultVariant;
  final IStatsRepository repo;

  const StatsPage(
      {required this.defaultVariant, required this.repo, super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: repo,
      builder: (context, child) {
        return FutureBuilder(
          future: repo.getStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final stats = snapshot.data!;

            return stats.fold(
              (l) => Center(child: Text("Error: $l")),
              (data) {
                return ChangeNotifierProvider(
                  create: (context) => StatsPageProvider(
                    context.read<AuthProvider>(),
                    context.read<Api>(),
                    defaultVariant,
                    data.$1,
                    data.$2,
                  ),
                  builder: (context, _) {
                    return Consumer<StatsPageProvider>(
                      builder: (context, pro, child) => Scaffold(
                        body: MyMaxWidthBox(
                          maxWidth: context.tabletBreakPoint.end,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: CustomScrollView(
                              slivers: [
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: PersistentHeader(
                                      widget: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      if (context.isTabletOrDesktop)
                                        IconButton(
                                          onPressed: () {
                                            Navigator.popUntil(
                                                context,
                                                ModalRoute.withName(
                                                    '/HomePage'));
                                          },
                                          icon: Icon(Icons.arrow_back),
                                        ),
                                      Text(
                                        "Stats for",
                                        style: context.textTheme.headlineSmall,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: MyDropDown(
                                          label: null,
                                          items: FilteredBoardSize.values,
                                          selectedItem: pro.boardSize,
                                          itemBuilder: (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(
                                              v.stringRepr,
                                              style:
                                                  context.textTheme.labelLarge,
                                            ),
                                          ),
                                          onChanged: (v) =>
                                              pro.changeVariant(v, null),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: MyDropDown(
                                          label: null,
                                          items: FilteredTimeStandard.values,
                                          selectedItem: pro.timeStandard,
                                          itemBuilder: (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(
                                              v.stringRepr,
                                              style:
                                                  context.textTheme.labelLarge,
                                            ),
                                          ),
                                          onChanged: (v) =>
                                              pro.changeVariant(null, v),
                                        ),
                                      ),
                                    ],
                                  )),
                                ),
                                SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24),
                                        child: Column(
                                          children: [
                                            ratingInfo(context, pro),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            pro.getStats().fold(
                                                  (l) => playEnoughGames(
                                                      context, l),
                                                  (r) => Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      pro.getCounts(r).fold(
                                                            (l) => Center(
                                                              child: Text(
                                                                l.message,
                                                                style: context
                                                                    .textTheme
                                                                    .headlineLarge,
                                                              ),
                                                            ),
                                                            (r) => gamesInfo(
                                                                context, r),
                                                          ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      playTimeInfo(
                                                          context, pro, r),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      recordInfo(
                                                          context, pro, r),
                                                      // SectionDivider(),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        "Streaks",
                                                        style: context
                                                            .textTheme
                                                            .headlineLarge
                                                            ?.underlinify,
                                                      ),
                                                      pro
                                                          .unavailabiltyReasonOrStreakData(
                                                              r)
                                                          .fold(
                                                            (l) => Text(
                                                              l.message,
                                                              style: context
                                                                  .textTheme
                                                                  .bodySmall,
                                                            ),
                                                            (r) => streakInfo(
                                                                context, r),
                                                          ),

                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      // SectionDivider(),
                                                      Text(
                                                        "Greatest Wins",
                                                        style: context
                                                            .textTheme
                                                            .headlineLarge
                                                            ?.underlinify,
                                                      ),
                                                      if (pro.getGreatestWins(
                                                              r) ==
                                                          null)
                                                        Center(
                                                          child: Text(
                                                            "No data available(not applicable for provisional ratings)",
                                                            style: context
                                                                .textTheme
                                                                .bodySmall,
                                                          ),
                                                        )
                                                      else
                                                        SizedBox(
                                                          height: 500,
                                                          width:
                                                              double.infinity,
                                                          child: ListView
                                                              .separated(
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            shrinkWrap: false,
                                                            itemCount: pro
                                                                .getGreatestWins(
                                                                    r)!
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              var result = pro
                                                                  .getGreatestWins(
                                                                      r)![index];

                                                              return GameResultWidget(
                                                                result: result,
                                                              );
                                                            },
                                                            separatorBuilder:
                                                                (context,
                                                                        index) =>
                                                                    Divider(
                                                              height: 1,
                                                            ),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 50,
                                      ),
                                    ],
                                    // )
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget streakInfo(BuildContext context, ResultStreakData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Winning",
          style: context.textTheme.titleLarge?.italicify,
        ),
        SizedBox(
          width: 140,
          child: Divider(
            height: 2,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if (r.winningStreaks == null)
          Text("No winning streaks")
        else
          CurrentAndGreatestStreak(streak: r.winningStreaks!),
        SizedBox(height: 20),
        Text(
          "Losing",
          style: context.textTheme.titleLarge?.italicify,
        ),
        SizedBox(
          width: 140,
          child: Divider(
            height: 2,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if (r.losingStreaks == null)
          Text("No losing streaks")
        else
          CurrentAndGreatestStreak(streak: r.losingStreaks!)
      ],
    );
  }

  Row playTimeInfo(
      BuildContext context, StatsPageProvider pro, UserStatForVariant r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Play Time",
          style: context.textTheme.titleLarge,
        ),
        SizedBox(
          width: 20,
        ),
        Text(
          pro.timePlayed(r).bigRepr(2),
          style: context.textTheme.bodySmall,
        ),
        if (context.isTabletOrDesktop) Spacer(),
      ],
    );
  }

  Row recordInfo(
      BuildContext context, StatsPageProvider pro, UserStatForVariant r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Records",
          style: context.textTheme.titleLarge,
        ),
        InfoText(
            detail: pro.highestRating(r)?.toString() ?? "N/A",
            label: "Highest rating",
            maxWidth: 90),
        InfoText(
            detail: pro.lowestRating(r)?.toString() ?? "N/A",
            label: "lowest rating",
            maxWidth: 90),
        if (context.isTabletOrDesktop) Spacer(),
      ],
    );
  }

  Row gamesInfo(BuildContext context, GameStatCounts r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Games",
          style: context.textTheme.titleLarge,
        ),
        InfoText(
          detail: r.total.toString(),
          label: "Games",
          maxWidth: 60,
        ),
        InfoText(
          detail: r.wins.toString(),
          label: "Wins",
          maxWidth: 50,
        ),
        InfoText(
          detail: r.losses.toString(),
          label: "Losses",
          maxWidth: 70,
        ),
        if (context.isTabletOrDesktop) Spacer(),
      ],
    );
  }

  Row ratingInfo(BuildContext context, StatsPageProvider pro) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Rating",
          style: context.textTheme.titleLarge,
        ),
        InfoText(
          detail: pro.getRating().glicko.minimal.stringify(),
          label: "Rating",
          maxWidth: 50,
        ),
        InfoText(
          detail: pro.getRating().glicko.deviation.toStringAsFixed(2),
          label: "Deviation",
          maxWidth: 70,
        ),
        if (context.isTabletOrDesktop) Spacer(),
      ],
    );
  }

  SizedBox playEnoughGames(BuildContext context, AppError l) {
    return SizedBox(
      height: context.height * 0.5,
      width: context.width * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l.message,
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              "Play some games to see stats",
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

class GameResultWidget extends StatelessWidget {
  final GameResultStat result;

  const GameResultWidget({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    final pro = context.read<StatsPageProvider>();
    return ListTile(
      title: Text(
        "${result.opponentName} (${result.opponentRating})",
        style: context.textTheme.bodySmall,
      ),
      subtitle: Text(
        result.resultAt.MMM_dd_yyyy(),
        style: context.textTheme.labelLarge,
      ),
      contentPadding: EdgeInsets.all(0),
      onTap: () async {
        final statsRepo = context.read<IStatsRepository>();

        final res = await pro.loadGame(result.gameId);

        return res.fold(
          (l) {
            showDialog(
                context: context,
                builder: (context) {
                  return BasicDialog(
                      title: "Game did not load", content: l.message);
                });
          },
          (r) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return LiveGameWidget(
                  r.game, GameEntranceData.fromGameAndOpponent(r), statsRepo);
            }));
          },
        );
      },
      trailing: Icon(
        Icons.keyboard_arrow_right,
        weight: 1,
        size: 30,
      ),
    );
  }
}

class CurrentAndGreatestStreak extends StatelessWidget {
  final StreakData streak;
  const CurrentAndGreatestStreak({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreakDataDisplay(
            title: "Current Streak", streak: streak.currentStreak),
        SizedBox(
          height: 10,
        ),
        StreakDataDisplay(
            title: "Greatest Streak", streak: streak.greatestStreak),
      ],
    );
  }
}

class StreakDataDisplay extends StatelessWidget {
  const StreakDataDisplay({
    super.key,
    required this.title,
    required this.streak,
  });

  final String title;
  final Streak? streak;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: context.textTheme.titleLarge?.italicify),
                Text(
                    streak?.streakLength.stringConv((l) => "$l games") ?? "N/A",
                    style: context.textTheme.bodySmall?.italicify),
              ],
            ),
            if (streak != null)
              Container(
                alignment: Alignment.topLeft,
                child: RichText(
                  text: TextSpan(
                    style: context.textTheme.labelLarge?.italicify,
                    children: [
                      TextSpan(text: "From "),
                      TextSpan(
                        text: streak!.streakFrom.MMM_dd_yyyy(),
                        style: context.textTheme.labelLarge?.boldify,
                      ),
                      TextSpan(text: " To "),
                      TextSpan(
                        text: streak!.streakTo.MMM_dd_yyyy(),
                        style: context.textTheme.labelLarge?.boldify,
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  final String detail;
  final String label;
  final double maxWidth;

  const InfoText({
    required this.detail,
    required this.label,
    required this.maxWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: context.isTabletOrDesktop ? 20 : 0),
      child: Column(
        children: [
          Text(
            detail,
            style: context.textTheme.labelSmall,
          ),
          Container(
            width: maxWidth,
            child: Divider(
              height: 1,
            ),
          ),
          Text(
            label,
            style: context.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class PersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;

  PersistentHeader({required this.widget});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: Card(
        margin: EdgeInsets.all(0),
        color: context.theme.colorScheme.surfaceContainerHigh,
        elevation: 5.0,
        child: Center(child: widget),
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
