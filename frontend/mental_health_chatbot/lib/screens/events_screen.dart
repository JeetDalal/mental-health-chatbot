import 'package:flutter/material.dart';
import 'package:mental_health_chatbot/constants/constants.dart';
import 'package:mental_health_chatbot/games/breath_game.dart';
import 'package:mental_health_chatbot/games/zen_garden.dart';

void main() {
  runApp(EventsScreenApp());
}

class EventsScreenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: EventsScreen(),
    );
  }
}

class EventsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> games = [
    {"name": "Breathing Game", "icon": Icons.air, "route": "breathing"},
    {"name": "Memory Match", "icon": Icons.memory, "route": "memory"},
    {"name": "Mood Tracker", "icon": Icons.favorite, "route": "mood"},
    {"name": "Zen Garden", "icon": Icons.nature, "route": "zen"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text(
          "Select a Game",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Navigate to respective game (Routes need to be defined in MaterialApp)
                switch (index) {
                  case 0:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BreathingGame()));
                    break;
                  case 1:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ZenGardenScreen()));
                    break;
                  case 2:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ZenGardenScreen()));
                    break;
                  case 3:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ZenGardenScreen()));
                    break;
                }
              },
              child: Card(
                color: tileColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(games[index]['icon'], size: 50, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      games[index]['name'],
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
