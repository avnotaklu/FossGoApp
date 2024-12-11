import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/homepage/profile/stats_page_provider.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/widgets/section_divider.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatelessWidget {
  final VariantType defaultVariant;
  const StatsPage({required this.defaultVariant, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) =>
            StatsPageProvider(context.read<AuthProvider>(), defaultVariant),
        builder: (context, _) {
          final statsProvider = context.watch<StatsPageProvider>();
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Stats for",
                            style: context.textTheme.headlineSmall,
                          ),
                          Container(
                            width: 90,
                            child: MyDropDown(
                              // label: "Time",
                              label: null,
                              items: FilteredBoardSize.values,
                              selectedItem: pro.boardSize,
                              itemBuilder: (v) => DropdownMenuItem(
                                child: Text(
                                  v.stringRepr,
                                  style: context.textTheme.labelLarge,
                                ),
                                value: v,
                              ),
                              onChanged: (v) => pro.changeVariant(v, null),
                            ),
                          ),
                          Container(
                            width: 150,
                            child: MyDropDown(
                              // label: "Size",
                              label: null,
                              items: FilteredTimeStandard.values,
                              selectedItem: pro.timeStandard,
                              itemBuilder: (v) => DropdownMenuItem(
                                child: Text(
                                  v.stringRepr,
                                  style: context.textTheme.labelLarge,
                                ),
                                value: v,
                              ),
                              onChanged: (v) => pro.changeVariant(null, v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SectionDivider(),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(children: [
                            Text(
                              "Rating",
                              style: context.textTheme.headlineSmall,
                            ),
                            ...pro
                                .unavailabiltyReasonOrRating()
                                .fold<List<Widget>>(
                                  (l) => [Text(l)],
                                  (r) => [
                                    Text(
                                      r.glicko.minimal.stringify(),
                                      style: context.textTheme.headlineLarge,
                                    ),
                                  ],
                                ),
                          ]),
                        ),
                        // Expanded(
                        //   child: Column(
                        //     children: [
                        //       Text(
                        //         "Games Played",
                        //         style: context.textTheme.headlineSmall,
                        //       ),
                        //       Text(
                        //         pro.stats.gamesPlayed.toString(),
                        //         style: context.textTheme.headlineLarge,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Expanded(
                        //   child: Column(
                        //     children: [
                        //       Text(
                        //         "Wins",
                        //         style: context.textTheme.headlineSmall,
                        //       ),
                        //       Text(
                        //         pro.stats.wins.toString(),
                        //         style: context.textTheme.headlineLarge,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    )
                  ],
                ),
                // ),
              ),
            ),
          );
        });
  }
}
