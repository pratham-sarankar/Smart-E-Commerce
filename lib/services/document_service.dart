import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DocumentService {
  final String baseUrl = 'https://4sr8mplp-3035.inc1.devtunnels.ms/api';

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }

    return token;
  }

  Future<Map<String, dynamic>> uploadDocuments({
    required String bankAccountNumber,
    required String ifscCode,
    required String kycDocumentNumber,
    required String kycDocumentImage,
    required String bankName,
    required String branchName,
    required String bankPassbookImage,
  }) async {
    try {
      final token = await _getAuthToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/upload-documents'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bankAccountNumber': bankAccountNumber,
          'ifscCode': ifscCode,
          'kycDocumentNumber': kycDocumentNumber,
          'kycDocumentImage': kycDocumentImage,
          'bankName': bankName,
          'branchName': branchName,
          'bankPassbookImage': bankPassbookImage,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Documents uploaded successfully',
          'data': data,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to upload documents',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading documents: ${e.toString()}',
      };
    }
  }
} 