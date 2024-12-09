import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/utils/intl/formatters.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/homepage/homepage_bloc.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/auth/sign_in_screen.dart';
import 'package:go/modules/homepage/game_card.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/services/public_user_info.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUserInfo;
        final account = authProvider.currentUserAccount;
        final stats = authProvider.currentUserStat;

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 10,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 140,
                      child: Card(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(14),
                            child: LayoutBuilder(
                              builder: (context, cons) => Row(
                                children: [
                                  Container(
                                    width: cons.maxWidth * 0.64,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    "${user.usernameOrGuest} ",
                                                style: context
                                                    .textTheme.headlineLarge,
                                              ),
                                              WidgetSpan(
                                                  child: Container(
                                                    height: 20,
                                                    child: Image.network(
                                                      "https://www.worldometers.info//img/flags/small/tn_af-flag.gif",
                                                    ),
                                                  ),
                                                  baseline:
                                                      TextBaseline.alphabetic,
                                                  alignment:
                                                      PlaceholderAlignment
                                                          .baseline),
                                            ],
                                          ),
                                        ),
                                        // TextButton(
                                        //   onPressed: () {
                                        //     debugPrint("hello world");
                                        //   },
                                        //   style: ButtonStyle(
                                        //     minimumSize: WidgetStateProperty.all(
                                        //       Size(0, 0),
                                        //     ),
                                        //     tapTargetSize:
                                        //         MaterialTapTargetSize.shrinkWrap,
                                        //     padding: WidgetStatePropertyAll(
                                        //       EdgeInsets.all(0),
                                        //     ),
                                        //   ),
                                        //   child: Text(
                                        //     "Edit profile",
                                        //     style: context.textTheme.labelSmall,
                                        //   ),
                                        // ),
                                        if (account != null) ...[
                                          Spacer(),
                                          Text(
                                            "Joined ${account.creationDate.MMM_dd_yyyy()}",
                                            style: context.textTheme.labelSmall,
                                          ),
                                          Text(
                                            "Last seen ${account.lastSeen.MMM_dd_yyyy()}",
                                            style: context.textTheme.labelSmall,
                                          ),
                                        ] else ...[
                                          TextButton(
                                              onPressed: () {},
                                              child: Text("Create Account"))
                                        ]
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (account != null) ...[
                                        if (account.fullName == null)
                                          RichText(
                                              text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "${account.fullName} ",
                                                style:
                                                    context.textTheme.bodySmall,
                                              ),
                                              TextSpan(
                                                text: "(hidden)",
                                                style: context
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                        fontStyle:
                                                            FontStyle.italic),
                                              ),
                                            ],
                                          )),
                                        if (account.email == null)
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "${account.email} ",
                                                  style: context
                                                      .textTheme.bodySmall,
                                                ),
                                                TextSpan(
                                                  text: "(hidden)",
                                                  style: context
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                          fontStyle:
                                                              FontStyle.italic),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ]
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SectionDivider(),
                    Container(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          // Container(height: 20,)
                          ListTile(
                            // tileColor: ,
                            onTap: () {
                              debugPrint("hello");
                            },
                            minTileHeight: 50,
                            title: Text("Edit Profile"),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              size: 30,
                            ),
                          ),
                          ListTile(
                            // tileColor: ,
                            onTap: () {
                              debugPrint("hello");
                            },
                            minTileHeight: 50,
                            title: Text("Games"),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              size: 30,
                            ),
                          ),
                          ListTile(
                            // tileColor: ,
                            onTap: () {
                              debugPrint("hello");
                            },
                            minTileHeight: 50,
                            title: Text("Settings"),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SectionDivider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Stats",
                          style: context.textTheme.headlineLarge,
                        ),
                        Container(
                          height: 40,
                          width: context.width * 0.3,
                          child: MyDropDown(
                            label: null,
                            items: StatFilter.values,
                            selectedItem: StatFilter.byTime,
                            itemBuilder: (t) {
                              return DropdownMenuItem(
                                value: t,
                                child: Text(t.realName),
                              );
                            },
                            onChanged: (t) {},
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (user.rating != null) StatsByTimeWidget(user.rating!),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StatsByTimeWidget extends StatelessWidget {
  final PlayerRating rating;

  const StatsByTimeWidget(this.rating, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: context.width * 0.9,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: StatInfo(
                      variant: VariantType(null, TimeStandard.blitz),
                      playerRating: rating,
                    ),
                  ),
                ),
                StatVerticalDivider(),
                Expanded(child: Container(color: Colors.blue)),
              ],
            ),
          ),
          StatHorizontalDivider(),
          Expanded(
            child: Row(
              children: [
                Expanded(child: Container(color: Colors.blue)),
                StatVerticalDivider(),
                Expanded(child: Container(color: Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension DisplayForVariant on VariantType {
  String get title {
    assert(boardSize == null || timeStandard == null,
        "Currently only supports one of the two");

    if (boardSize != null) {
      return boardSize!.toDisplayString;
    } else {
      return timeStandard!.standardName;
    }
  }
}

class StatInfo extends StatelessWidget {
  final VariantType variant;
  final PlayerRating playerRating;

  const StatInfo({
    required this.variant,
    required this.playerRating,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final data = playerRating.ratings[variant];
    final title = variant.title;
    final rating = data?.glicko.rating.toStringAsFixed(0) ?? "?";
    final games = data?.nb.toString() ?? "?";

    return Card(
      child: InkWell(
        onTap: () {
          debugPrint("hello");
        },
        splashFactory: InkSplash.splashFactory,
        child: Container(
          padding: EdgeInsets.all(14),
          color: Colors.transparent,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    title,
                    style: context.textTheme.headlineSmall,
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: 30,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(text: "$rating/", style: context.textTheme.bodyLarge),
                TextSpan(text: games, style: context.textTheme.labelSmall),
              ])),
            ],
          ),
        ),
      ),
    );
  }
}

enum StatFilter {
  byTime("By Time"),
  byBoardSize("By Board Size"),
  ;

  final String realName;

  const StatFilter(this.realName);
}

class SectionDivider extends StatelessWidget {
  const SectionDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Divider(
        color: context.theme.colorScheme.outlineVariant,
      ),
    );
  }
}

class StatHorizontalDivider extends StatelessWidget {
  const StatHorizontalDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Divider(
        color: context.theme.colorScheme.outlineVariant,
      ),
    );
  }
}

class StatVerticalDivider extends StatelessWidget {
  const StatVerticalDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: VerticalDivider(
        color: context.theme.colorScheme.outlineVariant,
      ),
    );
  }
}
