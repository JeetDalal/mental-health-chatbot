import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2F4F), // Dark purple background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or main image
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/4076/4076478.png',
              height: 150,
              width: 150,
            )
                .animate()
                .fadeIn(duration: 1000.ms)
                .scale(delay: 500.ms)
                .then()
                .shimmer(duration: 1200.ms),

            const SizedBox(height: 30),

            // App name or tagline
            const Text(
              'MindfulChat',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 800.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 20),

            // Supportive message
            const Text(
              'Your Mental Wellness Companion',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            )
                .animate()
                .fadeIn(delay: 1200.ms, duration: 800.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 40),

            // Loading indicator
            // const CircularProgressIndicator(
            //   color: Colors.white,
            // )
            //     .animate(onPlay: (controller) => controller.repeat())
            //     .scale(
            //       duration: 1000.ms,
            //       begin: const Offset(0.5, 0.5),
            //       end: const Offset(1.0, 1.0),
            //     )
            //     .then()
            //     .scale(
            //       duration: 1000.ms,
            //       begin: const Offset(1.0, 1.0),
            //       end: const Offset(0.5, 0.5),
            //     ),
          ],
        ),
      ),
    );
  }
}
