import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';

  late final SharedPreferences _prefs;
  String? _token;

  // Call once at app start, before runApp.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString(_tokenKey);
  }

  String? get token => _token;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> saveToken(String token) async {
    _token = token;
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> clear() async {
    _token = null;
    await _prefs.remove(_tokenKey);
  }
}