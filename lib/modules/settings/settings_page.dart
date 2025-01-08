import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/games_history/games_history_page.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/services/local_datasource.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // return
    // ChangeNotifierProvider(
    //   create: (context) => SettingsProvider(localDatasource: LocalDatasource()),
    // builder: (context, child) {
    return MaxWidthBox(
      maxWidth: context.tabletBreakPoint.end,
      child: Scaffold(
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
                    context, 'Enable Sound', soundSwitch(context));
              },
            ),
            SizedBox(
              height: 10,
            ),
            Consumer<SettingsProvider>(
              builder: (context, pro, child) {
                return settingsKeyVal(
                    context, 'Move Crosshair', showCrosshairSwitch(context));
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
            SizedBox(
              height: 10,
            ),
            Consumer<SettingsProvider>(
              builder: (context, pro, child) {
                return settingsKeyVal(
                    context, 'Notation', const NotationPositionDropDown());
              },
            ),
            SizedBox(
              height: 10,
            ),
            Consumer<SettingsProvider>(
              builder: (context, pro, child) {
                return settingsKeyVal(
                    context, 'Move input', const MoveInputDropDown());
              },
            ),
          ]),
        ),
      ),
    );
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
            style: context.textTheme.bodySmall,
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

  Widget showCrosshairSwitch(BuildContext context) {
    return Switch(
        thumbIcon: WidgetStateProperty.resolveWith(
          (state) => state.contains(WidgetState.selected)
              ? Icon(
                  Icons.check,
                  color: context.theme.colorScheme.primary,
                )
              : null,
        ),
        value: context.read<SettingsProvider>().showCrosshair,
        onChanged: (v) {
          if (v) {
            SystemSound.play(SystemSoundType.click);
          }
          context.read<SettingsProvider>().setShowCrosshair(v);
        });
  }

  Widget soundSwitch(BuildContext context) {
    return Switch(
        thumbIcon: WidgetStateProperty.resolveWith(
          (state) => state.contains(WidgetState.selected)
              ? Icon(
                  Icons.check,
                  color: context.theme.colorScheme.primary,
                )
              : null,
        ),
        value: context.read<SettingsProvider>().sound,
        onChanged: (v) {
          if (v) {
            SystemSound.play(SystemSoundType.click);
          }
          context.read<SettingsProvider>().setSound(v);
        });
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

class NotationPositionDropDown extends StatelessWidget {
  const NotationPositionDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) => Container(
        width: 180,
        child: MyDropDown(
          label: null,
          items: NotationPosition.values,
          itemBuilder: (e) => DropdownMenuItem(
            value: e,
            child: Text(
              e.displayText,
              style: context.textTheme.labelLarge,
            ),
          ),
          selectedItem: context.read<SettingsProvider>().notationPosition,
          onChanged: (NotationPosition? e) {
            if (e != null) {
              context.read<SettingsProvider>().setNotationPosition(e);
            }
          },
        ),
      ),
    );
  }
}

class MoveInputDropDown extends StatelessWidget {
  const MoveInputDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) => Container(
        width: 180,
        child: MyDropDown<MoveInputMode>(
          label: null,
          items: MoveInputMode.values,
          itemBuilder: (e) => DropdownMenuItem(
            value: e,
            child: Text(
              e.displayText,
              style: context.textTheme.labelLarge,
            ),
          ),
          selectedItem: context.read<SettingsProvider>().moveInput,
          onChanged: (MoveInputMode? e) {
            if (e != null) {
              context.read<SettingsProvider>().setMoveInput(e);
            }
          },
        ),
      ),
    );
  }
}

extension MoveInputDisplay on MoveInputMode {
  String get displayText {
    switch (this) {
      case MoveInputMode.immediate:
        return 'Immediate';
      case MoveInputMode.submitButton:
        return 'Submit Button';
    }
  }
}

extension NotationPositionDisplay on NotationPosition {
  String get displayText {
    switch (this) {
      case NotationPosition.both:
        return 'Both';
      case NotationPosition.onlyLeftTop:
        return 'Top And Left';
      case NotationPosition.onlyRightBotton:
        return 'Bottom And Right';
      case NotationPosition.none:
        return 'Disable';
    }
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
