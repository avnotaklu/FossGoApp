import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/homepage/homepage_bloc.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/homepage/custom_games_page.dart';
import 'package:go/modules/homepage/matchmaking_page.dart';
import 'package:go/modules/homepage/profile/profile_page.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:go/widgets/my_app_drawer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    var homepageBloc = context.read<HomepageBloc>();
    homepageBloc.getAvailableGames(context.read<AuthProvider>().token!);
    homepageBloc.getMyGames(context.read<AuthProvider>().token!);
  }

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      drawer: const MyAppDrawer(),
      appBar: MyAppBar('Baduk',
          leading: IconButton(
            onPressed: () {
              if (key.currentState!.isDrawerOpen) {
                key.currentState!.closeDrawer();
              } else {
                key.currentState!.openDrawer();
              }
            },
            icon: const Icon(Icons.menu),
          )),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        // indicatorColor: context.theme.indicatorColor,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(
              Icons.join_full_rounded,
              // color: context.theme.disabledColor,
            ),
            label: 'Match',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.games,
              // color: context.theme.disabledColor,
            ),
            label: 'Custom',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person,
              // color: context.theme.disabledColor,
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        const MatchmakingPage(),
        const CustomGamesPage(),
        const ProfilePage()
      ][currentPageIndex],
    );
  }
}
