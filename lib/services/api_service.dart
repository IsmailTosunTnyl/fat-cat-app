// lib/services/api_service.dart (legacy code for API calls, not using Firebase)
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/daily_food_summary.dart';
import '../models/food_entry.dart';
import '../models/monthly_food_summary.dart';

class ApiService {
  // base URL for API calls
  static const String baseUrl = 'http://sony.local:9000';

  Future<void> addFoodEntry(FoodEntry entry) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-daily-food'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(entry.toJson()),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        // showing error content for debugging
        throw Exception(
          'Failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<DailyFoodSummary>> getDailyFoodSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/daily-food-summary?limit=7'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => DailyFoodSummary.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load food summary');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // lib/services/api_service.dart - add this method
  Future<List<MonthlyFoodSummary>> getMonthlyFoodSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/monthly-food-summary?limit=12'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => MonthlyFoodSummary.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load monthly summary');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<DailyFoodSummary> getTodaySummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/daily-food-today'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return DailyFoodSummary.fromJson(jsonResponse);
      } else {
        throw 'Failed to get daily data: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      throw 'Failed to get daily data: $e';
    }
  }
}
