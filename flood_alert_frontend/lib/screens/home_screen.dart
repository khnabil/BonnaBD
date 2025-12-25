import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../models/station.dart';
import 'all_stations_screen.dart';
import 'profile_screen.dart';
import 'donate_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userToken;
  const HomeScreen({super.key, required this.userToken});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Station>> futureStations;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    futureStations = ApiService.fetchStations();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- 1. FIXED: Moved _buildHomeContent OUT of the build method ---
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. WARNING BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F), // Red Alert Color
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CRITICAL FLOOD WARNING",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 5),
                const Text(
                    "River at major flood stage. Evacuate low-lying areas immediately.",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("View Details →"),
                )
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 2. WATER STATIONS HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Water Stations",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () async {
                  // Pass loaded data to the "View All" page
                  final stations = await futureStations;
                  if (mounted) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                AllStationsScreen(stations: stations)));
                  }
                },
                child: const Text("View All →",
                    style: TextStyle(color: kPrimaryCyan)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3. DYNAMIC WATER STATIONS LIST
          SizedBox(
            height: 160, // Height of the cards
            child: FutureBuilder<List<Station>>(
              future: futureStations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No station data found.",
                          style: TextStyle(color: Colors.white)));
                }

                // Data Loaded Successfully
                final stations = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stations.length > 5
                      ? 5
                      : stations.length, // Show max 5 here
                  itemBuilder: (context, index) {
                    return _buildStationCard(stations[index]);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 25),

          // 4. GRID MENU
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.4,
            children: [
              _buildMenuCard(Icons.report_problem, "Report Flood", "Help others"),
              _buildMenuCard(Icons.house, "Find Shelter", "Safe locations"),
              _buildMenuCard(Icons.contact_phone, "Contacts", "Emergency"),
              _buildMenuCard(Icons.checklist, "Checklist", "Be prepared"),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the pages list
    final List<Widget> pages = [
      _buildHomeContent(), // 0: Home
      const Center(
          child: Text("Map Screen",
              style: TextStyle(color: Colors.white))), // 1: Map
      const DonateScreen(),
      const ProfileScreen(), // 3: Profile
    ];

    return Scaffold(
      backgroundColor: kBackgroundColor,
      // Only show AppBar on Home Screen (Index 0)
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: kBackgroundColor,
              elevation: 0,
              centerTitle: true,
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.water_drop, color: Colors.white),
                  SizedBox(width: 8),
                  Text("BonnaBD",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.person_outline)),
              ],
            )
          : null, // Hide AppBar for other tabs

      // --- 2. FIXED: Body correctly calls the pages list ---
      body: pages[_selectedIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kBackgroundColor,
        selectedItemColor: kPrimaryCyan,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: "Donate"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: Station Card ---
  Widget _buildStationCard(Station station) {
    bool isDanger = station.currentLevel >= station.dangerLevel;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(station.river.toUpperCase(),
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                      overflow: TextOverflow.ellipsis)),
              CircleAvatar(
                  radius: 4,
                  backgroundColor: isDanger ? Colors.red : Colors.green),
            ],
          ),
          const SizedBox(height: 5),
          Text(station.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Text("${station.currentLevel} m",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text("Danger: ${station.dangerLevel} m",
              style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
          const Spacer(),
          const Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey, size: 12),
              SizedBox(width: 4),
              Text("Just now",
                  style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  // --- WIDGET HELPER: Menu Card ---
  Widget _buildMenuCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1F3A46),
            child: Icon(icon, color: kPrimaryCyan, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}