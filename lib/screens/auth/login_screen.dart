// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart'; // <-- Added import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Navigation is handled automatically by StreamBuilder in main.dart
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.pets, size: 64, color: Color(0xFF2563EB)),
            const SizedBox(height: 32),
            const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Log In', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24),
            
            // <-- Added Sign Up Navigation Here -->
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}