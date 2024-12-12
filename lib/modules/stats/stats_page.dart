import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/stats/stats_page_provider.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/widgets/section_divider.dart';
import 'package:provider/provider.dart';

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

                return stats.fold((l) => Center(child: Text("Error: $l")),
                    (data) {
                  return ChangeNotifierProvider(
                      create: (context) => StatsPageProvider(
                            context.read<AuthProvider>(),
                            defaultVariant,
                            data.$1,
                            data.$2,
                          ),
                      builder: (context, _) {
                        return Consumer<StatsPageProvider>(
                          builder: (context, pro, child) => Scaffold(
                            body:
                                // SingleChildScrollView(
                                //   child:
                                Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Stats for",
                                          style:
                                              context.textTheme.headlineSmall,
                                        ),
                                        Container(
                                          width: 90,
                                          child: MyDropDown(
                                            // label: "Time",
                                            label: null,
                                            items: FilteredBoardSize.values,
                                            selectedItem: pro.boardSize,
                                            itemBuilder: (v) =>
                                                DropdownMenuItem(
                                              child: Text(
                                                v.stringRepr,
                                                style: context
                                                    .textTheme.labelLarge,
                                              ),
                                              value: v,
                                            ),
                                            onChanged: (v) =>
                                                pro.changeVariant(v, null),
                                          ),
                                        ),
                                        Container(
                                          width: 150,
                                          child: MyDropDown(
                                            // label: "Size",
                                            label: null,
                                            items: FilteredTimeStandard.values,
                                            selectedItem: pro.timeStandard,
                                            itemBuilder: (v) =>
                                                DropdownMenuItem(
                                              child: Text(
                                                v.stringRepr,
                                                style: context
                                                    .textTheme.labelLarge,
                                              ),
                                              value: v,
                                            ),
                                            onChanged: (v) =>
                                                pro.changeVariant(null, v),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SectionDivider(),
                                  SizedBox(height: 20),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Rating",
                                          style:
                                              context.textTheme.headlineLarge,
                                        ),
                                        InfoText(
                                          detail: pro
                                              .getRating()
                                              .glicko
                                              .minimal
                                              .stringify(),
                                          label: "Rating",
                                          maxWidth: 50,
                                        ),
                                        InfoText(
                                          detail: pro
                                              .getRating()
                                              .glicko
                                              .deviation
                                              .toStringAsFixed(2),
                                          label: "Deviation",
                                          maxWidth: 70,
                                        ),
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Games",
                                          style:
                                              context.textTheme.headlineLarge,
                                        ),
                                        InfoText(
                                          detail: pro.getCounts().total.toString(),
                                          label: "Games",
                                          maxWidth: 50,
                                        ),
                                        InfoText(
                                          detail: pro.getCounts().wins.toString(),
                                          label: "Wins",
                                          maxWidth: 50,
                                        ),
                                        InfoText(
                                          detail: pro.getCounts().losses.toString(),
                                          label: "Losses",
                                          maxWidth: 50,
                                        ),
                                      ])
                                ],
                              ),
                              // ),
                            ),
                          ),
                        );
                      });
                });
              });
        });
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
      width: maxWidth,
      child: Column(
        children: [
          Text(
            detail,
            style: context.textTheme.bodySmall,
          ),
          Divider(
            height: 1,
          ),
          Text(
            label,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
