import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:mental_health_chatbot/provider/auth_provider.dart';
import 'package:mental_health_chatbot/screens/assessment_screen.dart';
import 'package:mental_health_chatbot/screens/home_screen.dart';
import 'package:mental_health_chatbot/screens/login_screen.dart';
import 'package:mental_health_chatbot/screens/register_screen.dart';
import 'package:mental_health_chatbot/screens/screen_controller.dart';
import 'package:mental_health_chatbot/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MentalBot());
}

class MentalBot extends StatelessWidget {
  const MentalBot({super.key});

  Future<bool> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
            bodySmall: TextStyle(color: Colors.black),
            titleLarge: TextStyle(color: Colors.black),
            titleMedium: TextStyle(color: Colors.black),
            titleSmall: TextStyle(color: Colors.black),
            labelLarge: TextStyle(color: Colors.black),
            labelMedium: TextStyle(color: Colors.black),
            labelSmall: TextStyle(color: Colors.black),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<bool>(
          future: _checkToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen(); // Show a splash screen while checking
            } else if (snapshot.hasData && snapshot.data == true) {
              return const MainScreen(); // Navigate to MainScreen if token exists
            } else {
              return const LoginScreen(); // Navigate to LoginScreen if no token
            }
          },
        ),
      ),
    );
  }
}
