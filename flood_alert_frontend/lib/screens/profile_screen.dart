import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/api_service.dart';
import 'welcome_screen.dart';
import 'create_campaign_screen.dart';
import 'admin_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variables to hold dynamic data
  bool _isLoading = true;
  String _fullName = "Loading...";
  String _email = "";
  String _role = "user"; // Default to basic user
  String _firstLetter = "?"; // For the avatar

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // --- FETCH DATA FROM BACKEND ---
  void _loadProfileData() async {
    try {
      final data = await ApiService.fetchUserProfile();
      
      setState(() {
        _fullName = data['full_name'] ?? "Unknown User";
        _email = data['email'] ?? "No Email";
        _role = data['role'] ?? "user";
        
        // Get first letter for Avatar
        if (_fullName.isNotEmpty) {
          _firstLetter = _fullName[0].toUpperCase();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _fullName = "Error loading profile";
        _isLoading = false;
      });
      // Optional: Redirect to login if token expired
      print("Profile Error: $e");
    }
  }

  void _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Delete token
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If loading, show spinner
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: kPrimaryCyan)),
      );
    }

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
            // 1. DYNAMIC HEADER
            _buildProfileHeader(),
            
            const SizedBox(height: 30),

            // 2. STATS ROW (Static for now, can be dynamic later)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("0", "Reports"),
                _buildContainerLine(),
                _buildStatItem("0", "Alerts"),
                _buildContainerLine(),
                _buildStatItem("0", "Donations"),
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
            
            const SizedBox(height: 20),

            // --- DYNAMIC ADMIN SECTION ---
            if (_role == "admin") ...[
              const Align(
                alignment: Alignment.centerLeft, 
                child: Text("Admin Panel", style: TextStyle(color: kPrimaryCyan, fontWeight: FontWeight.bold))
              ),
              const SizedBox(height: 10),
              _buildMenuTile(Icons.verified_user, "Verify NGOs", () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
              }),
              const SizedBox(height: 20),
            ],

            // --- DYNAMIC NGO SECTION ---
            if (_role == "ngo") ...[
              const Align(
                alignment: Alignment.centerLeft, 
                child: Text("Organization Tools", style: TextStyle(color: kPrimaryCyan, fontWeight: FontWeight.bold))
              ),
              const SizedBox(height: 10),
              _buildMenuTile(Icons.campaign, "Create New Campaign", () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCampaignScreen()));
              }),
              const SizedBox(height: 20),
            ],

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
                  backgroundColor: const Color(0xFFFF3B30).withOpacity(0.1),
                  foregroundColor: const Color(0xFFFF3B30),
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
              child: CircleAvatar(
                radius: 50,
                backgroundColor: kCardColor,
                child: Text(
                  _firstLetter, 
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)
                ),
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
          _fullName,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          _email,
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
            _role.toUpperCase(),
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