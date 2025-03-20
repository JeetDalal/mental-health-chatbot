import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mental_health_chatbot/provider/auth_provider.dart';
import 'package:mental_health_chatbot/screens/screen_controller.dart';
import 'package:provider/provider.dart';
// import 'package:mental_health_chatbot/providers/auth_provider.dart';
import 'package:mental_health_chatbot/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF2A2F4F),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.network(
                      'https://cdn-icons-png.flaticon.com/512/4076/4076478.png',
                      height: 120,
                      width: 120,
                    ).animate().fadeIn(duration: 1000.ms).scale(delay: 500.ms),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 800.ms)
                      .slideY(begin: 0.3),
                  const SizedBox(height: 8),
                  const Text(
                    'Your journey to wellness continues here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 800.ms)
                      .slideY(begin: 0.3),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Colors.white70),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 1200.ms).slideX(begin: -0.2),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.white70),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 1400.ms).slideX(begin: 0.2),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ).animate().fadeIn(delay: 1600.ms),
                  const SizedBox(height: 30),
                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                await authProvider
                                    .login(
                                  _emailController.text,
                                  _passwordController.text,
                                )
                                    .then(
                                  (value) {
                                    if (value) {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MainScreen()));
                                    }
                                  },
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2A2F4F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.blue)
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(delay: 1800.ms).slideY(begin: 0.2),
                  const SizedBox(height: 30),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RegisterScreen()));
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 2000.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
