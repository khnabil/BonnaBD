import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import is correct
import '../models/station.dart';
import '../models/campaign.dart';

class ApiService {
  // USE '10.0.2.2' for Emulator, '127.0.0.1' for Web/Linux
  static const String baseUrl = "http://127.0.0.1:8000"; 

  // --- ADD THIS FUNCTION (This was missing!) ---
  // --- USER PROFILE FEATURE ---
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    final url = Uri.parse('$baseUrl/auth/me');
    final token = await getToken();

    if (token.isEmpty) {
      throw Exception("No token found. Please log in.");
    }

    final response = await http.get(
      url, 
      headers: {"Authorization": "Bearer $token"}
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load profile");
    }
  }
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Returns the token string, or empty string if not found
    return prefs.getString('access_token') ?? "";
  }
  // ---------------------------------------------

  static Future<List<Station>> fetchStations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/water-levels'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Station.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load stations");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  static Future<List<Campaign>> fetchCampaigns() async {
    final url = Uri.parse('$baseUrl/campaigns/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Campaign.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load campaigns");
      }
    } catch (e) {
      throw Exception("Error fetching campaigns: $e");
    }
  }

  // --- NGO FEATURES ---
  
  static Future<void> createCampaign(String title, String description, double targetAmount) async {
    final url = Uri.parse('$baseUrl/campaigns/');
    final token = await getToken(); // Now this works because we defined it above!

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", 
      },
      body: jsonEncode({
        "title": title,
        "description": description,
        "target_amount": targetAmount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create campaign: ${response.body}");
    }
  }

  // --- ADMIN FEATURES ---

  static Future<List<dynamic>> fetchUnverifiedNGOs() async {
    final url = Uri.parse('$baseUrl/admin/unverified-ngos');
    final token = await getToken(); 

    final response = await http.get(url, headers: {"Authorization": "Bearer $token"});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // If endpoint is missing or fails, return empty list to prevent app crash
      return []; 
    }
  }

  static Future<void> verifyNGO(int ngoId) async {
    final url = Uri.parse('$baseUrl/admin/verify-ngo/$ngoId');
    final token = await getToken();

    final response = await http.put(
      url, 
      headers: {"Authorization": "Bearer $token"}
    );

    if (response.statusCode != 200) {
      throw Exception("Verification failed");
    }
  }
}