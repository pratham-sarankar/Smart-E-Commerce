import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_eommerce/models/user_model.dart';

class UserService {
  final String baseUrl = 'https://lakhpati.api.smartchainstudio.in/api';

  // Get user profile from API
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Create a user model from the response
        final userModel = UserModel.fromJson(data, token);
        
        // Update the stored user data with the profile information
        await _updateUserData(userModel);
        
        return {
          'success': true,
          'message': 'Profile loaded successfully',
          'user': userModel,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please check your connection and try again.',
      };
    }
  }
  
  // Toggle auto-deduct setting
  Future<Map<String, dynamic>> toggleAutoDeduct(bool enable) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/auto-deduct-on'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'autoDeduct': enable,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Update the user profile after successful toggle
        await getUserProfile();
        
        return {
          'success': true,
          'message': enable ? 'Auto-deduct enabled' : 'Auto-deduct disabled',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update auto-deduct setting',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please check your connection and try again.',
      };
    }
  }
  
  // Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      print('Starting logout process');
      final token = await _getToken();
      
      if (token == null) {
        print('No token found, clearing preferences only');
        // If no token exists, just clear preferences
        await _clearUserData();
        return {
          'success': true,
          'message': 'Logged out successfully',
        };
      }
      
      print('Token found, calling logout API');
      // Call logout API
      final response = await http.post(
        Uri.parse('$baseUrl/user/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('Logout API response: ${response.statusCode} - ${response.body}');
      
      // Clear shared preferences regardless of API response
      print('Clearing user data from SharedPreferences');
      await _clearUserData();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Logout API success: ${data['message']}');
        return {
          'success': true,
          'message': data['message'] ?? 'Logout successful',
        };
      } else {
        print('Logout API failed but still clearing local data');
        // Even if the API call fails, we still clear local data
        return {
          'success': true,
          'message': 'Logged out locally',
        };
      }
    } catch (e) {
      print('Error during logout: $e');
      // If there's an error with the API call, still clear local data
      await _clearUserData();
      return {
        'success': true,
        'message': 'Logged out locally',
      };
    }
  }
  
  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Update user data in SharedPreferences
  Future<void> _updateUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update user data JSON
      await prefs.setString('user', jsonEncode(user.toJson()));
      
    } catch (e) {
      print('Error updating user data: $e');
    }
  }
  
  // Clear all user data from SharedPreferences
  Future<void> _clearUserData() async {
    try {
      print('Starting to clear SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.clear();
      print('SharedPreferences cleared: $result');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // Generate referral code
  Future<Map<String, dynamic>> generateReferralCode() async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/generate-referral'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Referral code generated successfully',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to generate referral code',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please check your connection and try again.',
      };
    }
  }
} 