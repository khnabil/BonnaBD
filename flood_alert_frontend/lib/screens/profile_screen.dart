import 'package:flutter/material.dart';
import '../constants.dart';
import 'welcome_screen.dart'; // Ensure you have this import for logout

class ProfileScreen extends StatelessWidget {
  // In a real app, you would fetch these details from your backend
  final String userName;
  final String userEmail;
  final String userRole; // "User", "Volunteer", or "NGO"

  const ProfileScreen({
    super.key,
    this.userName = "Nabil Ahmed", // Default placeholders
    this.userEmail = "nabil@example.com",
    this.userRole = "Volunteer", 
  });

  void _handleLogout(BuildContext context) {
    // 1. Clear any stored tokens (e.g., SharedPreferences) here
    // 2. Navigate back to Welcome Screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. THE PROFILE HEADER
            _buildProfileHeader(),
            
            const SizedBox(height: 30),

            // 2. STATS ROW (Optional, makes it look pro)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("05", "Reports"),
                _buildContainerLine(),
                _buildStatItem("12", "Alerts"),
                _buildContainerLine(),
                _buildStatItem("2", "Donations"),
              ],
            ),

            const SizedBox(height: 30),

            // 3. MENU OPTIONS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Account", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            
            _buildMenuTile(Icons.person_outline, "Personal Information", () {}),
            _buildMenuTile(Icons.history, "Donation History", () {}),
            _buildMenuTile(Icons.notifications_outlined, "Notification Settings", () {}),
            
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Support", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            
            _buildMenuTile(Icons.help_outline, "Help & FAQ", () {}),
            _buildMenuTile(Icons.privacy_tip_outlined, "Privacy Policy", () {}),

            const SizedBox(height: 30),

            // 4. LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30).withOpacity(0.1), // Light red bg
                  foregroundColor: const Color(0xFFFF3B30), // Red text
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPrimaryCyan, width: 2),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: kCardColor,
                child: Icon(Icons.person, size: 50, color: Colors.grey),
                // backgroundImage: NetworkImage("..."), // Use this for real images
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: kPrimaryCyan,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          userName,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          userEmail,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimaryCyan.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kPrimaryCyan.withOpacity(0.5)),
          ),
          child: Text(
            userRole.toUpperCase(),
            style: const TextStyle(color: kPrimaryCyan, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildContainerLine() {
    return Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3));
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimaryCyan, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }
}