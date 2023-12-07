import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesController {
  SharedPreferencesController._privateConstructor();

  static final SharedPreferencesController instance =
      SharedPreferencesController._privateConstructor();

  Future<SharedPreferences> get _instance async =>
      await SharedPreferences.getInstance();

  Future<bool> saveData(String key, String value) async {
    final SharedPreferences prefs = await _instance;
    return prefs.setString(key, value);
  }

  Future<String?> getData(String key) async {
    final SharedPreferences prefs = await _instance;
    return prefs.getString(key);
  }
}
