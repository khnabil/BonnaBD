import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers to capture user input
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isVolunteer = false;       // Checkbox state
  bool _isPasswordVisible = false; // Eye icon toggle
  bool _isLoading = false;         // Loading spinner state

  // --- BACKEND CONNECTION ---
  Future<void> _registerUser() async {
    // 1. Basic Client-Side Validation
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Prepare Data
    // NOTE: Use '10.0.2.2' if running on Android Emulator
    // NOTE: Use '127.0.0.1' or 'localhost' if running on Web/Linux/Windows
    const String apiUrl = "http://127.0.0.1:8000/auth/signup"; 

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "confirm_password": _confirmPasswordController.text,
          "is_volunteer": _isVolunteer,
        }),
      );

      // 3. Handle Response
      if (response.statusCode == 200) {
        // Success!
        final data = jsonDecode(response.body);
        print("Token: ${data['access_token']}"); // Debugging
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created Successfully! 🚀"), backgroundColor: Colors.green),
        );
        
        // TODO: Navigate to Home Screen or Login
        Navigator.pop(context); 

      } else {
        // Error from Server (e.g., Email already exists)
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['detail'] ?? "Registration failed"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- UI WIDGETS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: kInputFillColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.water_drop, color: kPrimaryCyan, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              
              const Center(
                child: Text(
                  "Create Your Account",
                  style: TextStyle(color: kTextColor, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              const Center(
                child: Text(
                  "Join us to stay safe and informed.",
                  style: TextStyle(color: kSubTextColor, fontSize: 14),
                ),
              ),
              const SizedBox(height: 30),

              // Inputs
              _buildLabel("Full Name"),
              _buildInputField(
                controller: _nameController, 
                hint: "Enter your full name", 
                icon: Icons.person_outline
              ),

              _buildLabel("Email Address"),
              _buildInputField(
                controller: _emailController, 
                hint: "Enter your email address", 
                icon: Icons.email_outlined
              ),

              _buildLabel("Password"),
              _buildInputField(
                controller: _passwordController, 
                hint: "Create a password", 
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              _buildLabel("Confirm Password"),
              _buildInputField(
                controller: _confirmPasswordController, 
                hint: "Confirm your password", 
                icon: Icons.lock_outline,
                isPassword: true,
                showToggle: false,
              ),

              const SizedBox(height: 10),

              // Volunteer Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isVolunteer,
                    activeColor: kPrimaryCyan,
                    side: const BorderSide(color: kSubTextColor),
                    onChanged: (val) => setState(() => _isVolunteer = val!),
                  ),
                  const Text("I agree to work as a volunteer", style: TextStyle(color: kTextColor)),
                ],
              ),

              const SizedBox(height: 20),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryCyan,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Create Account",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),

              const SizedBox(height: 20),
              const Center(child: Text("OR", style: TextStyle(color: kSubTextColor))),
              const SizedBox(height: 20),

              // Google Button (Visual Only)
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
                    Text("Sign up with Google", style: TextStyle(color: kTextColor)),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: kSubTextColor)),
                  GestureDetector(
                    onTap: () {
                       Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                    },
                    child: const Text("Log In", style: TextStyle(color: kPrimaryCyan, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets to keep code clean
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
    bool isPassword = false,
    bool showToggle = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      // FIXED: Using InputDecoration directly instead of BoxDecoration
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kSubTextColor),
        prefixIcon: Icon(icon, color: kSubTextColor),
        suffixIcon: isPassword && showToggle
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: kSubTextColor,
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            )
          : null,
        filled: true,            // This enables the background color
        fillColor: kInputFillColor, // This sets the dark grey color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // Removes the black outline
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

// Extension to make custom Input Decoration work easily
// extension InputDecorationExtension on InputDecoration {
//   InputDecoration get inputDecoration => this;
// }