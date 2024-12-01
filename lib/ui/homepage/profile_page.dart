import 'package:flutter/material.dart';
import 'package:go/providers/homepage_bloc.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/sign_in_screen.dart';
import 'package:go/ui/homepage/game_card.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Center(
                  child:
                      Text(context.read<AuthProvider>().currentUserRaw.email),
                ),
                ElevatedButton(
                  onPressed: () {
                    authProvider.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SignIn(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Logout'),
                ),
                const SizedBox(height: 50),
                const Text("My Games", style: TextStyle(fontSize: 30)),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: context.read<HomepageBloc>().myGames.length,
                      itemBuilder: (context, index) {
                        final game =
                            context.read<HomepageBloc>().myGames[index];
                        return GameCard(
                          game: game.game,
                          otherPlayerData: game.opposingPlayer,
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
