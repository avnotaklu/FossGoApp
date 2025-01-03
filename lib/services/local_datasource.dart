import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/services/user_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatasource {
  final sharedPrefs = SharedPreferencesAsync();
  final String _userDataKey = 'user';
  final String _tokenDataKey = 'token';
  final String _themeSettingKey = 'themeSetting';
  final String _compactGameUIKey = 'compactGameUI';
  final String _notationPositionKey = 'compactGameUI';
  final String _soundKey = 'soundEnabled';
  final String _moveInputKey = 'moveInput';

  Future<void> storeToken(String token) async {
    await sharedPrefs.setString(_tokenDataKey, token);
  }

  Future<void> storeUser(UserAccount user) async {
    await sharedPrefs.setString(_userDataKey, user.toJson());
  }

  Future<void> storeThemeSetting(ThemeSetting themeSetting) async {
    await sharedPrefs.setInt(_themeSettingKey, themeSetting.index);
  }

  Future<void> storeCompactGameUISetting(
      CompactGameUISetting compactGameUISetting) async {
    await sharedPrefs.setInt(_compactGameUIKey, compactGameUISetting.index);
  }

  Future<void> storeSoundEnabled(bool value) async {
    await sharedPrefs.setBool(_soundKey, value);
  }

  Future<void> storeNotationPosition(NotationPosition notationPosition) async {
    await sharedPrefs.setInt(_notationPositionKey, notationPosition.index);
  }

  Future<void> storeMoveInputMode(MoveInputMode mode) async {
    await sharedPrefs.setInt(_moveInputKey, mode.index);
  }

  Future<String?> getToken() async {
    return await sharedPrefs.getString(_tokenDataKey);
  }

  Future<UserAccount?> getUser() async {
    final userJson = await sharedPrefs.getString(_userDataKey);
    if (userJson == null) return null;
    return UserAccount.fromJson(userJson);
  }

  Future<int?> getThemeSetting() async {
    return await sharedPrefs.getInt(_themeSettingKey);
  }

  Future<int?> getCompactGameUISetting() async {
    return await sharedPrefs.getInt(_compactGameUIKey);
  }

  Future<bool?> getSoundEnabled() async {
    return await sharedPrefs.getBool(_soundKey);
  }

  Future<NotationPosition?> getNotationPosition() async {
    final notationPosition = await sharedPrefs.getInt(_notationPositionKey);
    if (notationPosition == null) return null;
    return NotationPosition.values[notationPosition];
  }

  Future<MoveInputMode?> getMoveInputMode() async {
    final mode = await sharedPrefs.getInt(_moveInputKey);
    if (mode == null) return null;
    return MoveInputMode.values[mode];
  }

  Future<void> clear() async {
    await sharedPrefs.remove(_userDataKey);
    await sharedPrefs.remove(_tokenDataKey);
    await sharedPrefs.remove(_themeSettingKey);
    await sharedPrefs.remove(_compactGameUIKey);
    await sharedPrefs.remove(_soundKey);
    await sharedPrefs.remove(_notationPositionKey);
  }
}
