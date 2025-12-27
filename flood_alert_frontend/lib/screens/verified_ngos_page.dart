import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. THE MODEL
class Ngo {
  final int id;
  final String name;
  final String description;
  final String phone;
  final String aidTypes;
  final bool isVerified;

  Ngo({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.aidTypes,
    required this.isVerified,
  });

  factory Ngo.fromJson(Map<String, dynamic> json) {
    return Ngo(
      id: json['id'] ?? 0,
      name: json['name'] ?? "Unknown NGO",
      description: json['description'] ?? "No description available",
      phone: json['contact_phone'] ?? "N/A",
      aidTypes: json['aid_types'] ?? "",
      isVerified: json['is_verified'] == true,
    );
  }
}

class VerifiedNgoPage extends StatefulWidget {
  const VerifiedNgoPage({super.key});

  @override
  State<VerifiedNgoPage> createState() => _VerifiedNgoPageState();
}

class _VerifiedNgoPageState extends State<VerifiedNgoPage> {
  List<Ngo> _allNgos = [];
  List<Ngo> _filteredNgos = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNgos();
  }

  // 2. API CALL WITH TIMEOUT
  Future<void> _fetchNgos() async {
    // NOTE: Use 10.0.2.2 for Android Emulator. Use real IP (e.g., 192.168.x.x) for physical phone.
    final url = Uri.parse('http://192.168.0.121:8000/ngos/');
    debugPrint("--- DEBUG: Fetching from $url ---");

    try {
      // Timeout added: Stops waiting after 5 seconds
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return http.Response('Error: Connection Timed Out', 408);
        },
      );
      
      debugPrint("DEBUG: Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        if (decodedData is List) {
           List<Ngo> fetchedNgos = decodedData.map((json) => Ngo.fromJson(json)).toList();

           setState(() {
             _allNgos = fetchedNgos;
             _filteredNgos = fetchedNgos;
             _isLoading = false;
             _errorMessage = null;
           });
        } else {
          throw Exception("Expected a list but got ${decodedData.runtimeType}");
        }
      } else {
        throw Exception('Server returned ${response.statusCode}. Check backend.');
      }
    } catch (e) {
      debugPrint("--- DEBUG ERROR: $e ---");
      setState(() {
        _isLoading = false;
        _errorMessage = "Connection Failed. \n\nDetails: $e"; 
      });
    }
  }

  // 3. FILTER LOGIC
  void _filterNgos(String query) {
    final results = _allNgos.where((ngo) {
      final nameLower = ngo.name.toLowerCase();
      final aidLower = ngo.aidTypes.toLowerCase();
      final input = query.toLowerCase();
      return nameLower.contains(input) || aidLower.contains(input);
    }).toList();

    setState(() {
      _filteredNgos = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verified Aid Providers"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterNgos,
              decoration: InputDecoration(
                hintText: "Search NGO name or aid type...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _fetchNgos();
                },
                child: const Text("Retry Connection"),
              )
            ],
          ),
        ),
      );
    }

    if (_filteredNgos.isEmpty) {
      return const Center(child: Text("No NGOs found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredNgos.length,
      itemBuilder: (context, index) {
        final ngo = _filteredNgos[index];
        return _buildNgoCard(ngo);
      },
    );
  }

  Widget _buildNgoCard(Ngo ngo) {
    // Parse tags safely
    List<String> tags = ngo.aidTypes.isNotEmpty 
        ? ngo.aidTypes.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() 
        : [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ngo.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (ngo.isVerified)
                  const Tooltip(
                    message: "Verified Organization",
                    child: Icon(Icons.verified, color: Colors.blue, size: 24),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              ngo.description,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Aid Type Chips (CRASH FIXED)
            if (tags.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    visualDensity: VisualDensity.compact, // Prevents layout crash
                    padding: EdgeInsets.zero, // Safe padding
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),

            const Divider(height: 24),

            // Contact Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Dialing ${ngo.phone}...")),
                    );
                },
                icon: const Icon(Icons.phone, color: Colors.teal),
                label: const Text("Contact Now", style: TextStyle(color: Colors.teal)),
              ),
            )
          ],
        ),
      ),
    );
  }
}