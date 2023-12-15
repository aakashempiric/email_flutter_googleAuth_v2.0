import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

void saveToSharedPreferences({
  required String key,
  required String value,
}) async {
  await prefs.setString(key, value);
}

dynamic loadFromSharedPreferences(String key) async {
  return prefs.getString("$key");
}
