// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go/modules/gameplay/stages/stage.dart';

import 'package:go/services/local_datasource.dart';

enum GameUI {
  compact,
  full,
}

extension CompactGameUISettingExt on CompactGameUISetting {
  bool isCompact(StageType stage) {
    switch (this) {
      case CompactGameUISetting.never:
        return false;
      case CompactGameUISetting.always:
        return true;
      case CompactGameUISetting.whenAnalyzing:
        return stage == StageType.analysis;
    }
  }
}

enum CompactGameUISetting {
  never,
  always,
  whenAnalyzing,
}

enum ThemeSetting {
  light,
  dark,
  system,
}

extension ThemeSettingExt on ThemeSetting {
  ThemeMode get themeMode {
    switch (this) {
      case ThemeSetting.light:
        return ThemeMode.light;
      case ThemeSetting.dark:
        return ThemeMode.dark;
      case ThemeSetting.system:
        return ThemeMode.system;
    }
  }
}

class SettingsProvider extends ChangeNotifier {
  final LocalDatasource localDatasource;

  SettingsProvider({
    required this.localDatasource,
  });

  ThemeSetting _themeSetting = ThemeSetting.system;
  ThemeSetting get themeSetting => _themeSetting;

  CompactGameUISetting _compactGameUISetting =
      CompactGameUISetting.whenAnalyzing;
  CompactGameUISetting get compactGameUISetting => _compactGameUISetting;

  void setup() async {
    final themeSetting = await localDatasource.getThemeSetting();
    if (themeSetting != null) {
      _themeSetting = ThemeSetting.values[themeSetting];
    }

    final compactGameUISetting =
        await localDatasource.getCompactGameUISetting();
    if (compactGameUISetting != null) {
      _compactGameUISetting = CompactGameUISetting.values[compactGameUISetting];
    }
  }

  void setThemeSetting(ThemeSetting themeSetting) {
    _themeSetting = themeSetting;
    localDatasource.storeThemeSetting(themeSetting);
    notifyListeners();
  }

  void setCompactGameUISetting(CompactGameUISetting compactGameUISetting) {
    _compactGameUISetting = compactGameUISetting;
    localDatasource.storeCompactGameUISetting(compactGameUISetting);
    notifyListeners();
  }
}
