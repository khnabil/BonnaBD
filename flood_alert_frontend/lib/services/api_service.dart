import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station.dart';
import '../models/campaign.dart';
class ApiService {
  // USE '10.0.2.2' for Emulator, '127.0.0.1' for Web/Linux
  static const String baseUrl = "http://127.0.0.1:8000"; 

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
}