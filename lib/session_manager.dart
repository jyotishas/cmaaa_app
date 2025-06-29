import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const int sessionDuration = 3 * 60 * 1000;

  static Future<void> saveLoginSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_logged_in', true);
    await prefs.setInt('user_id', userId);
    await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch );

    print("✅ Session saved");
    print("📌 is_logged_in: ${prefs.getBool('is_logged_in')}");
    print("📌 user_id: ${prefs.getInt('user_id')}");
    print("📌 login_time: ${prefs.getInt('login_time')}");
  }


  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final int? loginTime = prefs.getInt('login_time');
    final int? userId = prefs.getInt('user_id');
    final bool? isLoggedIn = prefs.getBool('is_logged_in');
    if (loginTime == null || userId == null || isLoggedIn != true) return false;

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    return (currentTime - loginTime) < sessionDuration;
  }


  // ✅ Clear session on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_id');
    await prefs.remove('login_time');
  }

  // (Optional) helper: get userId
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}
