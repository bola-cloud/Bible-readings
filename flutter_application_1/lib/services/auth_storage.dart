import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _keyToken = 'auth_token';

  static Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyToken);
  }

  static Future<void> deleteToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_keyToken);
  }
}
