import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/food_entry.dart';
import '../models/dashboard_stats.dart';

class ApiService {
  // Base URL - change this to your backend URL
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  
  // Get dashboard stats
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return DashboardStats.fromJson(data);
      } else {
        print('Error getting dashboard stats: ${response.statusCode}');
        return DashboardStats.empty();
      }
    } catch (e) {
      print('Exception getting dashboard stats: $e');
      return DashboardStats.empty();
    }
  }

  // Get list of food entries
  Future<List<FoodEntry>> getFoodEntries({int limit = 10}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/foods?limit=$limit'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return (data['food_entries'] as List)
            .map((foodJson) => FoodEntry.fromJson(foodJson))
            .toList();
      } else {
        print('Error getting food entries: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception getting food entries: $e');
      return [];
    }
  }

  // Get a specific food entry by ID
  Future<FoodEntry?> getFoodEntry(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/foods/$id'));
      
      if (response.statusCode == 200) {
        return FoodEntry.fromJson(jsonDecode(response.body));
      } else {
        print('Error getting food entry: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception getting food entry: $e');
      return null;
    }
  }

  // Scan food image
  Future<FoodEntry?> scanFood(File imageFile) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/scan'));
      
      // Add file to request
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: 'food_image.jpg',
      );
      
      request.files.add(multipartFile);
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        return FoodEntry.fromJson(jsonDecode(response.body));
      } else {
        print('Error scanning food: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception scanning food: $e');
      return null;
    }
  }
} 