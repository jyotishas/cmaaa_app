import 'package:flutter/material.dart';
import 'landing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'session_manager.dart';

class LogoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6E6E6E), Color(0xFFF6C2AD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _buildLogoutDialog(context),
        ),
      ),
    );
  }

  Widget _buildLogoutDialog(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.exit_to_app, color: Colors.red, size: 50),
          SizedBox(height: 15),
          Text(
            "Logout",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Are you sure you want to logout?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();

                  int? userId = prefs.getInt('user_id');

                  await prefs.setBool('is_logged_in', false);
                  await prefs.remove('user_id');
                  await prefs.remove('login_time');

                  if (userId != null) {
                    final dbHelper = DatabaseHelper();
                    await dbHelper.updateUserLoginStatus(userId, 0);
                  }

                  await SessionManager.clearSession();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LandingPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text("Logout"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


