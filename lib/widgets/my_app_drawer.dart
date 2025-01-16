import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/main.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/settings/settings_page.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:go/widgets/signal_indicator.dart';
import 'package:provider/provider.dart';

class MyAppDrawer extends StatelessWidget {
  final bool gameWidgetDrawer;
  final bool sidebar;
  final List<ListTile>? navigationItems;

  MyAppDrawer({
    this.navigationItems,
    this.gameWidgetDrawer = false,
    this.sidebar = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = !context.isDesktop;
    final desktop = context.isDesktop;
    final showConnectionOverview = desktop && !gameWidgetDrawer;

    return Drawer(
      child: Column(
        // // Important: Remove any padding from the ListView.

        // padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              child: UserInfoOverview(
                  showConnectionOverview: showConnectionOverview)),
          if (gameWidgetDrawer)
            const ListTile(
              title: Text('Compact'),
              trailing: GameUIToggle(),
            ),
          if (desktop) ...[
            ...navigationItems!,
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Divider(),
            ),
          ],
          if (mobile || gameWidgetDrawer)
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
          if (mobile || gameWidgetDrawer)
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Scaffold.of(context).closeDrawer();
                Navigator.pushNamed(context, '/Settings');
              },
            ),
          Spacer(),
        ],
      ),
    );
  }
}

class UserInfoOverview extends StatelessWidget {
  final bool showConnectionOverview;
  const UserInfoOverview({required this.showConnectionOverview, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                child: Text(
                  getUserName(context),
                  style: context.textTheme.headlineLarge,
                ),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              ValueListenableBuilder(
                  valueListenable:
                      context.read<SignalRProvider>().connectionStrength,
                  builder: (context, strength, child) {
                    return SignalIndicator(strength: strength);
                  }),
              if (showConnectionOverview) ...[
                // Container(
                //   height: 20,
                // ),
                Row(
                  children: [
                    Container(
                      width: 20,
                    ),
                    ConnectionOverviewWidget(
                        connStream:
                            context.read<SignalRProvider>().connectionStream),
                  ],
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  String getUserName(BuildContext context) {
    return context.read<AuthProvider>().myUsername;
  }
}
