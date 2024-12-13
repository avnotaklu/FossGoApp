import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/main.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:provider/provider.dart';

class MyAppDrawer extends StatelessWidget {
  const MyAppDrawer({super.key});

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
              child: Container(
                child: Text(
                  getUserName(context),
                  style: context.textTheme.headlineLarge,
                ),
              ),
            ),
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
              Scaffold.of(context).closeDrawer();
              showCreateCustomGameDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
