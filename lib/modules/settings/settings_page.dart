import 'package:flutter/material.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/games_history/games_history_page.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/services/local_datasource.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // return
    // ChangeNotifierProvider(
    //   create: (context) => SettingsProvider(localDatasource: LocalDatasource()),
    // builder: (context, child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Consumer<SettingsProvider>(
            builder: (context, pro, child) {
              return settingsKeyVal(
                context,
                'Theme',
                themeToggle(context),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
          Consumer<SettingsProvider>(
            builder: (context, pro, child) {
              return settingsKeyVal(
                  context, 'Compact Game UI', const GameUIToggle());
            },
          ),
        ]),
      ),
    );
    //   },
    // );
  }

  Widget settingsKeyVal(
    BuildContext context,
    String key,
    Widget val,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            key,
            style: context.textTheme.titleLarge,
          ),
          Spacer(),
          val,
        ],
      ),
    );
  }

  Widget themeToggle(BuildContext context) {
    return SegmentedButton(
      segments: [
        ...ThemeSetting.values.map(
          (e) => ButtonSegment(
            value: e,
            icon: Icon(
              e.displayIcon,
            ),
          ),
        ),
      ],
      onSelectionChanged: (p0) {
        context.read<SettingsProvider>().setThemeSetting(p0.first);
      },
      selected: {context.read<SettingsProvider>().themeSetting},
      selectedIcon: SizedBox.shrink(),
    );
  }
}

class GameUIToggle extends StatelessWidget {
  const GameUIToggle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) => Container(
        width: 150,
        child: MyDropDown(
          label: null,
          items: CompactGameUISetting.values,
          itemBuilder: (e) => DropdownMenuItem(
            value: e,
            // onTap: () {
            // },
            child: Text(
              e.displayText,
              style: context.textTheme.labelLarge,
            ),
          ),
          selectedItem: context.read<SettingsProvider>().compactGameUISetting,
          onChanged: (CompactGameUISetting? e) {
            if (e != null) {
              context.read<SettingsProvider>().setCompactGameUISetting(e);
            }
          },
        ),
      ),
    );
  }
}

extension CompactGameUISettingDisplay on CompactGameUISetting {
  String get displayText {
    switch (this) {
      case CompactGameUISetting.always:
        return 'Always';
      case CompactGameUISetting.never:
        return 'Never';
      case CompactGameUISetting.whenAnalyzing:
        return 'When Analyzing';
    }
  }

  IconData get displayIcon {
    switch (this) {
      case CompactGameUISetting.always:
        return Icons.visibility_off;
      case CompactGameUISetting.never:
        return Icons.visibility;
      case CompactGameUISetting.whenAnalyzing:
        return Icons.analytics;
    }
  }
}

extension ThemeSettingDisplay on ThemeSetting {
  IconData get displayIcon {
    switch (this) {
      case ThemeSetting.light:
        return Icons.light_mode;
      case ThemeSetting.dark:
        return Icons.dark_mode;
      case ThemeSetting.system:
        return Icons.auto_awesome;
    }
  }
}
