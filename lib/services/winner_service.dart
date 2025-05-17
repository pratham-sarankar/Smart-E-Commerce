import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/winner_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WinnerService {
  static const String baseUrl = 'https://lakhpati.api.smartchainstudio.in/api';

  Future<WinnerResponse> getTodayWinner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/draw/today-winner'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return WinnerResponse(
          message: responseData['message'] as String,
          data: responseData['data'] != null ? WinnerData.fromJson(responseData['data']) : null,
        );
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load winner data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<PastWinnersResponse> getPastWinners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/draw/past-winners'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PastWinnersResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load past winners data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 