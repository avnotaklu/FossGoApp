import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/auth/sign_up_provider.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/homepage/homepage_bloc.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/homepage/custom_games_page.dart';
import 'package:go/modules/homepage/matchmaking_page.dart';
import 'package:go/modules/homepage/profile/profile_page.dart';
import 'package:go/modules/settings/settings_page.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/api.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:go/widgets/my_app_drawer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((d) {
      var homepageBloc = context.read<HomepageBloc>();
      homepageBloc.getAvailableGames(context.read<AuthProvider>().token!);
      homepageBloc.getMyGames(context.read<AuthProvider>().token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<IStatsRepository>(
      create: (BuildContext context) => StatsRepository(
        Api(),
        context.read<AuthProvider>(),
        context.read<SignalRProvider>(),
      ),
      builder: (context, child) {
        return context.isMobile || context.isTablet
            ? const MobileScaffold()
            : const DesktopScaffold();
      },
    );
  }
}

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<int> sidebarIndex = ValueNotifier(0);

  final List<Widget> pages = const [
    MatchmakingPage(),
    CustomGamesPage(),
    SettingsPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    final sidebar = MyAppDrawer(
      sidebar: true,
      navigationItems: [
        ListTile(
          title: const Text('Home'),
          leading: const Icon(Icons.home),
          onTap: () {
            sidebarIndex.value = 0;
          },
        ),
        ListTile(
          title: const Text('Custom Games'),
          leading: const Icon(Icons.add),
          onTap: () {
            sidebarIndex.value = 1;
          },
        ),
        ListTile(
          title: const Text('Profile'),
          leading: const Icon(Icons.verified_user),
          onTap: () {
            sidebarIndex.value = 3;
          },
        ),
        ListTile(
          title: const Text('Settings'),
          leading: const Icon(Icons.settings),
          onTap: () {
            sidebarIndex.value = 2;
          },
        ),
      ],
    );
    return Scaffold(
      body: SafeArea(
          child: Row(
        children: [
          sidebar,
          ValueListenableBuilder<int>(
              valueListenable: sidebarIndex,
              builder: (context, snapshot, child) {
                return Expanded(
                  child: pages[snapshot],
                );
              })
        ],
      )),
    );
  }
}

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({super.key});

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: MyAppDrawer(),
      appBar: MyAppBar('Baduk',
          leading: IconButton(
            onPressed: () {
              if (scaffoldKey.currentState!.isDrawerOpen) {
                scaffoldKey.currentState!.closeDrawer();
              } else {
                scaffoldKey.currentState!.openDrawer();
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
