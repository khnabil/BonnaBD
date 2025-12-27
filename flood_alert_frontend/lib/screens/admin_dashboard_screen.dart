import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Use a Future to load the REAL list from the backend
  late Future<List<dynamic>> _futureNgos;

  @override
  void initState() {
    super.initState();
    _loadNgos();
  }

  void _loadNgos() {
    setState(() {
      _futureNgos = ApiService.fetchUnverifiedNGOs();
    });
  }

  void _verifyNgo(int id) async {
    try {
      await ApiService.verifyNGO(id); // Calls the real backend
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("NGO Verified Successfully!"), backgroundColor: Colors.green)
      );
      
      // Refresh the list to remove the verified one
      _loadNgos(); 
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Admin Dashboard"), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureNgos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryCyan));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("No pending approvals.", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            );
          }

          final ngos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ngos.length,
            itemBuilder: (context, index) {
              final ngo = ngos[index];
              return Card(
                color: kCardColor,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.orange, 
                            child: Icon(Icons.priority_high, color: Colors.white)
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ngo['name'] ?? "Unknown Org", 
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                                Text(
                                  ngo['aid_types'] ?? "General Aid", 
                                  style: const TextStyle(color: kPrimaryCyan, fontSize: 12)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ngo['description'] ?? "No description provided.",
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _verifyNgo(ngo['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Approve & Verify"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}