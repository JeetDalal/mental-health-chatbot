import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:mental_health_chatbot/screens/home_screen.dart';
import 'package:mental_health_chatbot/screens/login_screen.dart';
import 'package:mental_health_chatbot/screens/register_screen.dart';
import 'package:mental_health_chatbot/screens/screen_controller.dart';
import 'package:mental_health_chatbot/screens/splash_screen.dart';

void main() {
  runApp(MentalBot());
}

class MentalBot extends StatelessWidget {
  const MentalBot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
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
      home: MainScreen(),
    );
  }
}
