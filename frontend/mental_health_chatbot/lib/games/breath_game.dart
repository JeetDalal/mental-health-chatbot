import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

void main() {
  runApp(BreathingGame());
}

class BreathingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: BreathingScreen(),
    );
  }
}

class BreathingScreen extends StatefulWidget {
  @override
  _BreathingScreenState createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  FlutterTts flutterTts = FlutterTts();
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 100, end: 200).animate(_controller);
    _startBreathingInstructions();
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _startBreathingInstructions() {
    List<String> instructions = [
      "Breathe in...",
      "Hold your breath...",
      "Breathe out...",
      "Relax..."
    ];

    Timer.periodic(Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _speak(instructions[_step]);
      setState(() {
        _step = (_step + 1) % instructions.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Breathing Game")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ["Inhale", "Hold", "Exhale", "Relax"][_step],
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 20),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: _animation.value,
                  height: _animation.value,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
