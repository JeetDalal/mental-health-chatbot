import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mental_health_chatbot/provider/auth_provider.dart';
import 'package:mental_health_chatbot/screens/login_screen.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF2A2F4F),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/4076/4076478.png',
                  height: 100,
                  width: 100,
                ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                const SizedBox(height: 30),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                const SizedBox(height: 40),
                _buildTextField(_nameController, 'Full Name', Icons.person),
                const SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, 'Password', Icons.lock,
                    isPassword: true),
                const SizedBox(height: 20),
                _buildTextField(_confirmPasswordController, 'Confirm Password',
                    Icons.lock_outline,
                    isPassword: true),
                const SizedBox(height: 30),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          _buildRegisterButton(authProvider),
                          if (authProvider.errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                const SizedBox(height: 20),
                _buildLoginRedirect(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter your $hint';
        }
        if (hint == 'Confirm Password' && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            authProvider
                .register(
              _nameController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text.trim(),
            )
                .then((value) {
              if (value) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2A2F4F),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Register',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? ",
            style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Login',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
