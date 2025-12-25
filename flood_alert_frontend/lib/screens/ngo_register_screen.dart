import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

class NgoRegisterScreen extends StatefulWidget {
  const NgoRegisterScreen({super.key});

  @override
  State<NgoRegisterScreen> createState() => _NgoRegisterScreenState();
}

class _NgoRegisterScreenState extends State<NgoRegisterScreen> {
  // Login Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Organization Controllers
  final _orgNameController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aidTypesController = TextEditingController(); // e.g., "Food, Medicine"

  bool _isLoading = false;

  Future<void> _registerNgo() async {
    setState(() => _isLoading = true);

    // Use '10.0.2.2' for Android Emulator, '127.0.0.1' for Web/Linux
    const String apiUrl = "http://127.0.0.1:8000/auth/signup-ngo"; 

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          // User Login Info
          "full_name": _fullNameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          
          // Public Profile Info
          "organization_name": _orgNameController.text,
          "description": _descController.text,
          "contact_phone": _phoneController.text,
          "aid_types": _aidTypesController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Application Submitted! Wait for Admin Verification."), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Go back to login
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['detail'] ?? "Registration Failed"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Partner with FloodSafe"),
        backgroundColor: kCardColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "NGO Registration",
              style: TextStyle(color: kTextColor, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Create an account to manage funds and alerts.",
              style: TextStyle(color: kSubTextColor),
            ),
            const SizedBox(height: 30),

            // --- SECTION 1: LOGIN DETAILS ---
            const Text("Login Credentials", style: TextStyle(color: kPrimaryCyan, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildInputField(controller: _fullNameController, hint: "Representative Name", icon: Icons.person),
            const SizedBox(height: 15),
            _buildInputField(controller: _emailController, hint: "Official Email", icon: Icons.email),
            const SizedBox(height: 15),
            _buildInputField(controller: _passwordController, hint: "Password", icon: Icons.lock, isPassword: true),

            const SizedBox(height: 30),

            // --- SECTION 2: ORGANIZATION PROFILE ---
            const Text("Organization Details", style: TextStyle(color: kPrimaryCyan, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildInputField(controller: _orgNameController, hint: "Organization Name", icon: Icons.business),
            const SizedBox(height: 15),
            _buildInputField(controller: _phoneController, hint: "Contact Phone", icon: Icons.phone),
            const SizedBox(height: 15),
            _buildInputField(controller: _aidTypesController, hint: "Aid Provided (e.g. Food, Shelter)", icon: Icons.medical_services),
            const SizedBox(height: 15),
            // Description Field (Taller)
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Brief description of your mission...",
                hintStyle: const TextStyle(color: kSubTextColor),
                filled: true,
                fillColor: kInputFillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 30),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerNgo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryCyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Application", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
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
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kSubTextColor),
        prefixIcon: Icon(icon, color: kSubTextColor),
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