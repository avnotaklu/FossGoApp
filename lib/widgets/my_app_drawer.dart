import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/main.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/settings/settings_page.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/widgets/signal_indicator.dart';
import 'package:provider/provider.dart';

class MyAppDrawer extends StatelessWidget {
  final bool showCompactUiSwitch;

  const MyAppDrawer({
    this.showCompactUiSwitch = false,
    super.key,
  });

  String getUserName(BuildContext context) {
    return context.read<AuthProvider>().myUsername;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: context.height * 0.12,
            child: DrawerHeader(
              decoration: BoxDecoration(),
              child: Row(
                children: [
                  Container(
                    child: Text(
                      getUserName(context),
                      style: context.textTheme.headlineLarge,
                    ),
                  ),
                  Spacer(),
                  ValueListenableBuilder(
                      valueListenable:
                          context.read<SignalRProvider>().connectionStrength,
                      builder: (context, strength, child) {
                        return SignalIndicator(strength: strength);
                      }),
                ],
              ),
            ),
          ),
          if (showCompactUiSwitch)
            const ListTile(
              title: Text('Compact'),
              trailing: GameUIToggle(),
            ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            onTap: () {
              Scaffold.of(context).closeDrawer();
              Navigator.popUntil(context, ModalRoute.withName('/HomePage'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.create),
            title: const Text('Create Game'),
            onTap: () {
              showLiveCreateCustomGameDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_customize),
            title: const Text('Over the board'),
            onTap: () {
              showOverTheBoardCreateCustomGameDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
              Navigator.pushNamed(context, '/Settings');
            },
          ),
        ],
      ),
    );
  }
}
