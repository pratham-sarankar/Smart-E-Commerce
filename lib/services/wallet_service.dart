import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart';
import 'dart:io';

class WalletService {
  static const String baseUrl = 'https://lakhpati.api.smartchainstudio.in/api/wallet';
  static const int maxVideoSizeMB = 50;

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token: $token');
    
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

      // Check if response is HTML (error page)
      if (response.headers['content-type']?.contains('text/html') ?? false) {
        throw Exception('Server error: Received HTML response instead of JSON');
      }

      // Try to parse JSON response
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid server response format');
      }

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 401) {
        // Clear stored data on unauthorized access
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('user_id');
        await prefs.remove('user_email');
        await prefs.setBool('is_logged_in', false);
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception(responseData['message'] ?? 'Request failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format from server');
      }
      throw Exception('Error making request: $e');
    }
  }

  Future<Map<String, dynamic>> getMyWallet() async {
    try {
      final token = await _getAuthToken();
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/my-wallet'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Clear stored data on unauthorized access
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
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

  Future<Map<String, dynamic>> verifyWalletTopup({
    required String paymentId,
    required String orderId,
    required String signature,
    required int amount,
  }) async {
    try {
      if (paymentId.isEmpty || orderId.isEmpty || signature.isEmpty) {
        throw Exception('Invalid payment details');
      }

      final requestBody = {
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
        'amount': amount,
      };

      final token = await _getAuthToken();

      print('Request Body: $requestBody');
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('https://lakhpati.api.smartchainstudio.in/api/wallet/verify-wallet-topup'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Payment verification failed');
        }
      } else if (response.statusCode == 401) {
        // Clear stored data on unauthorized access
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('user_id');
        await prefs.remove('user_email');
        await prefs.setBool('is_logged_in', false);
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to verify payment: ${response.statusCode}');
      }
    } catch (e) {
      print('Verification error: $e');
      throw Exception('Failed to verify payment: $e');
    }
  }

  Future<String?> _validateAndConvertVideo(String videoPath) async {
    try {
      final file = File(videoPath);
      final fileSize = await file.length();
      final maxSize = maxVideoSizeMB * 1024 * 1024; // Convert MB to bytes

      if (fileSize > maxSize) {
        throw Exception('Video size must be less than $maxVideoSizeMB MB');
      }

      // Compress video if needed
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (mediaInfo?.file == null) {
        throw Exception('Failed to process video');
      }

      return mediaInfo!.file!.path;
    } catch (e) {
      print('Video validation error: $e');
      throw Exception('Failed to process video: $e');
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal(double amount, {String? videoPath}) async {
    try {
      final token = await _getAuthToken();
      
      if (videoPath != null) {
        // For winning withdrawals - use multipart request
        print('Processing winning withdrawal request with video...');
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://lakhpati.api.smartchainstudio.in/api/user/withdrawl-request'),
        );

        // Add authorization header
        request.headers['Authorization'] = 'Bearer $token';

        // Add amount in the request body
        request.fields['amount'] = amount.toString();

        try {
          // Process and add video
          final processedVideoPath = await _validateAndConvertVideo(videoPath);
          if (processedVideoPath != null) {
            print('Adding processed video to request: $processedVideoPath');
            request.files.add(
              await http.MultipartFile.fromPath(
                'winnerVerificationVideo',
                processedVideoPath,
              ),
            );
          }
        } catch (e) {
          print('Video processing failed: $e');
          throw Exception('Video processing failed: $e');
        }

        print('Sending winning withdrawal request...');
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print('Received response with status code: ${response.statusCode}');
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 401) {
          // Clear stored data on unauthorized access
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          await prefs.remove('user_id');
          await prefs.remove('user_email');
          await prefs.setBool('is_logged_in', false);
          throw Exception('Unauthorized: Please login again');
        } else {
          print('Request failed with response: ${response.body}');
          throw Exception('Request failed: ${response.body}');
        }
      } else {
        // For regular withdrawals - use JSON request
        print('Processing regular withdrawal request...');
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

        final response = await http.post(
          Uri.parse('$baseUrl/withdrawl-request'),
          headers: headers,
          body: jsonEncode({'amount': amount}),
        );

        print('Received response with status code: ${response.statusCode}');
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 401) {
          // Clear stored data on unauthorized access
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          await prefs.remove('user_id');
          await prefs.remove('user_email');
          await prefs.setBool('is_logged_in', false);
          throw Exception('Unauthorized: Please login again');
        } else {
          print('Request failed with response: ${response.body}');
          throw Exception('Request failed: ${response.body}');
        }
      }
    } catch (e) {
      print('Error in withdrawal request: $e');
      throw Exception('Error making withdrawal request: $e');
    }
  }

  Future<Map<String, dynamic>> getAllTransactions() async {
    try {
      final token = await _getAuthToken();
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('https://lakhpati.api.smartchainstudio.in/api/user/all-transactions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Clear stored data on unauthorized access
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('user_id');
        await prefs.remove('user_email');
        await prefs.setBool('is_logged_in', false);
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Request failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }
} 