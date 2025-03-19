import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:mental_health_chatbot/screens/home_screen.dart';

void main() {
  runApp(MentalBot());
}

class MentalBot extends StatelessWidget {
  const MentalBot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
