import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/feature_card.dart';
import 'register_screen.dart';
import 'login_screen.dart';
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          // 1. TOP SECTION (Image + Logo)
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // Background Water Image
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      // Using a placeholder water image
                      image: NetworkImage('https://images.unsplash.com/photo-1500375592092-40eb2168fd21?q=80&w=2574&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Overlay Gradient (To make text readable)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black12, kBackgroundColor],
                    ),
                  ),
                ),
                // Top Bar (Logo and Lang Switch)
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.waves, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "BonnaBD",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "EN 🌐 BN",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. BOTTOM SECTION (Text, Cards, Buttons)
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome",
                    style: TextStyle(
                      color: kTextColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Stay safe, stay informed.",
                    style: TextStyle(color: kSubTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // The 3 Feature Cards
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FeatureCard(icon: Icons.notifications_active, text: "Real-time Alerts"),
                      FeatureCard(icon: Icons.volunteer_activism, text: "Join as Volunteer"),
                      FeatureCard(icon: Icons.monetization_on, text: "Support Efforts"),
                    ],
                  ),

                  const Spacer(),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Register Link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "New User? Register Now",
                        style: TextStyle(color: kPrimaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
