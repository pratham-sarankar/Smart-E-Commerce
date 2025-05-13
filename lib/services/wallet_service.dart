import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  static const String baseUrl = 'https://4sr8mplp-3035.inc1.devtunnels.ms/api/wallet';

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }

    return token;
  }

  Future<Map<String, dynamic>> _makeAuthenticatedRequest(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    try {
      final token = await _getAuthToken();
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Clear stored data on unauthorized access
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_id');
        await prefs.remove('user_email');
        await prefs.setBool('is_logged_in', false);
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Request failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error making request: $e');
    }
  }

  Future<Map<String, dynamic>> topupWallet(double amount) async {
    return _makeAuthenticatedRequest(
      'topup-wallet',
      {'amount': amount},
    );
  }

  Future<Map<String, dynamic>> verifyWalletTopup(double amount) async {
    return _makeAuthenticatedRequest(
      'verify-wallet-topup',
      {'amount': amount},
    );
  }
} 