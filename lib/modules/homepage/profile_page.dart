import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/utils/intl/formatters.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/minimal_rating.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/homepage/homepage_bloc.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/auth/sign_in_screen.dart';
import 'package:go/modules/homepage/game_card.dart';
import 'package:go/modules/homepage/matchmaking_page.dart';
import 'package:go/modules/homepage/profile_page_provider.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/widgets/stateful_card.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfilePageProvider(),
      builder: (context, child) => Consumer<AuthProvider>(
        builder: (context, authProvider, child) =>
            Consumer<ProfilePageProvider>(
          builder: (context, profilePageProvider, child) {
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
                                                    style: context.textTheme
                                                        .headlineLarge,
                                                  ),
                                                  WidgetSpan(
                                                      child: Container(
                                                        height: 20,
                                                        child: Image.network(
                                                          "https://www.worldometers.info//img/flags/small/tn_af-flag.gif",
                                                        ),
                                                      ),
                                                      baseline: TextBaseline
                                                          .alphabetic,
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
                                                style: context
                                                    .textTheme.labelSmall,
                                              ),
                                              Text(
                                                "Last seen ${account.lastSeen.MMM_dd_yyyy()}",
                                                style: context
                                                    .textTheme.labelSmall,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (account != null) ...[
                                            if (account.fullName == null)
                                              RichText(
                                                  text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        "${account.fullName} ",
                                                    style: context
                                                        .textTheme.bodySmall,
                                                  ),
                                                  TextSpan(
                                                    text: "(hidden)",
                                                    style: context
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                            fontStyle: FontStyle
                                                                .italic),
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
                                                                  FontStyle
                                                                      .italic),
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
                            physics: NeverScrollableScrollPhysics(),
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
                              width: context.width * 0.4,
                              child: MyDropDown(
                                label: null,
                                items: StatFilter.values,
                                selectedItem: profilePageProvider.statFilter,
                                itemBuilder: (t) {
                                  return DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      t.realName,
                                      style: context.textTheme.bodySmall,
                                    ),
                                  );
                                },
                                onChanged: (t) {
                                  if (t != null) {
                                    profilePageProvider.setStatFilter(t);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        if (user.rating != null)
                          profilePageProvider.statFilter == StatFilter.byTime
                              ? StatsByTimeWidget(user.rating!)
                              : StatsByBoardSizeWidget(user.rating!),
                        SizedBox(
                          height: 20,
                        ),
                        PrimaryButton(
                          onPressed: () {},
                          text: "Logout",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class StatsByBoardSizeWidget extends StatelessWidget {
  final PlayerRating rating;

  const StatsByBoardSizeWidget(this.rating, {super.key});

  @override
  Widget build(BuildContext context) {
    final boardSizes = [BoardSize.nine, BoardSize.thirteen, BoardSize.nineteen];

    boardSizes.sort((a, b) {
      var aR = rating.ratings[VariantType.b(a)];
      var bR = rating.ratings[VariantType.b(b)];

      if (aR?.latest == null) return -1;
      if (bR?.latest == null) return 1;

      return aR!.latest!.compareTo(bR!.latest!);
    });

    return Container(
      height: 230,
      width: context.width * 0.9,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: StatInfo(
                      variant: VariantType(boardSizes[0], null),
                      playerRating: rating,
                    ),
                  ),
                ),
              ],
            ),
          ),
          StatHorizontalDivider(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: StatInfo(
                    variant: VariantType(boardSizes[1], null),
                    playerRating: rating,
                  ),
                ),
                StatVerticalDivider(),
                Expanded(
                  child: StatInfo(
                    variant: VariantType(boardSizes[2], null),
                    playerRating: rating,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  child: StatInfo(
                    variant: VariantType(null, TimeStandard.blitz),
                    playerRating: rating,
                  ),
                ),
                StatVerticalDivider(),
                Expanded(
                  child: StatInfo(
                    variant: VariantType(null, TimeStandard.rapid),
                    playerRating: rating,
                  ),
                ),
              ],
            ),
          ),
          StatHorizontalDivider(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: StatInfo(
                    variant: VariantType(null, TimeStandard.classical),
                    playerRating: rating,
                  ),
                ),
                StatVerticalDivider(),
                Expanded(
                  child: StatInfo(
                    variant: VariantType(null, TimeStandard.correspondence),
                    playerRating: rating,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    final minimalRating =
        data != null ? MinimalRating.fromRatingData(data) : null;

    final rating = minimalRating?.stringify() ?? "?";
    final games = data?.nb.toString() ?? "?";

    int longCardThresh = 220;

    return Card(
      child: InkWell(
        onTap: () {
          debugPrint("hello");
        },
        splashFactory: InkSplash.splashFactory,
        child: LayoutBuilder(
          builder: (context, constraints) => Container(
            // padding:  wrapArrowThresh > constraints.maxWidth
            //                 ? EdgeInsets.all(4)
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: constraints.maxWidth *
                            (constraints.maxWidth > longCardThresh ? 0.4 : 0.6),
                        child: Text(
                          title,
                          style: context.textTheme.headlineSmall?.copyWith(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // if (constraints.maxWidth > wrapArrowThresh)
                      Icon(
                        Icons.keyboard_arrow_right,
                        size: 30,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: "$rating/", style: context.textTheme.bodyLarge),
                  TextSpan(text: games, style: context.textTheme.labelSmall),
                ])),
                // if (constraints.maxWidth < wrapArrowThresh)
                //   Icon(
                //     Icons.keyboard_arrow_right,
                //     size: 30,
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
