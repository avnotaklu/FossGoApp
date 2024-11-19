import 'package:flutter/material.dart';
import 'package:go/ui/homepage/custom_games_page.dart';
import 'package:go/ui/homepage/matchmaking_page.dart';
import 'package:go/ui/homepage/profile_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[


          NavigationDestination(
            icon: Icon(Icons.join_full_rounded),
            label: 'Match',
          ),

          NavigationDestination(
            icon: Icon(Icons.games),
            label: 'Custom',
          ),

          NavigationDestination(
            icon: Icon(Icons.person),
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
