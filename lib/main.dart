import 'package:flutter/material.dart';
import 'package:signing/splash_screen.dart';
import 'landing.dart';
import 'session_manager.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _checkUserSession() async {
    final isValidSession = await SessionManager.isSessionValid();

    if (isValidSession) {
      return 'home';
    } else {
      return 'login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _checkUserSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          Widget homeScreen;
          if (snapshot.data == 'home') {
            homeScreen = LandingPage();
          } else {
            homeScreen = SplashScreen();
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'User Sign Up',
            theme: ThemeData(
              primarySwatch: Colors.green,
              scaffoldBackgroundColor: Colors.white,
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            home: homeScreen, // Navigate directly based on session check
          );
        });
  }
}
