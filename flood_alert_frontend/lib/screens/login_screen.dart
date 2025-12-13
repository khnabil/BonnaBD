import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // --- BACKEND CONNECTION ---
  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    // NOTE: Use '10.0.2.2' for Android Emulator, '127.0.0.1' for Web/Linux
    const String apiUrl = "http://127.0.0.1:8000/auth/login"; 

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // 1. Parse Token
        final data = jsonDecode(response.body);
        String token = data['access_token'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Welcome Back! 👋"), backgroundColor: kPrimaryCyan),
        );

        // 2. Go to Home Screen (and remove Login from back history)
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userToken: token)),
          );
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Email or Password"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Logo Section
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: kInputFillColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person, color: kPrimaryCyan, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              
              const Center(
                child: Text(
                  "Welcome Back",
                  style: TextStyle(color: kTextColor, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              const Center(
                child: Text(
                  "Stay Safe, Stay Informed.",
                  style: TextStyle(color: kSubTextColor, fontSize: 14),
                ),
              ),
              const SizedBox(height: 40),

              // 2. Input Fields
              _buildLabel("Email"),
              _buildInputField(
                controller: _emailController, 
                hint: "Enter your email", 
                icon: Icons.email_outlined
              ),

              _buildLabel("Password"),
              _buildInputField(
                controller: _passwordController, 
                hint: "Enter your password", 
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?", style: TextStyle(color: kPrimaryCyan)),
                ),
              ),

              const SizedBox(height: 20),

              // 3. Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryCyan,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Log In",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                ),
              ),

              const SizedBox(height: 30),
              
              // 4. Divider
              Row(
                children: [
                  Expanded(child: Divider(color: kInputFillColor, thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR", style: TextStyle(color: kSubTextColor)),
                  ),
                  Expanded(child: Divider(color: kInputFillColor, thickness: 1)),
                ],
              ),
              const SizedBox(height: 30),

              // 5. Google Button
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kInputFillColor),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: kInputFillColor,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.g_mobiledata, size: 30, color: Colors.white), 
                    SizedBox(width: 10),
                    Text("Continue with Gmail", style: TextStyle(color: kTextColor)),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              
              // 6. Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: kSubTextColor)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text("Register Now", style: TextStyle(color: kPrimaryCyan, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
      child: Text(text, style: const TextStyle(color: kTextColor, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    bool isPassword = false
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kSubTextColor),
        prefixIcon: Icon(icon, color: kSubTextColor),
        suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: kSubTextColor,
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            )
          : null,
        filled: true,
        fillColor: kInputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}