import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_eommerce/models/user_model.dart';

class AuthService {
  final String baseUrl = 'https://lakhpati.api.smartchainstudio.in/api';

  // User login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting login for email: $email');
      print('API URL: $baseUrl/user/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Check if the response body is valid JSON
      try {
        final data = jsonDecode(response.body);
        print('Login API response parsed: $data'); 
        
        // Check if response contains token and user data - indicating successful login
        if (response.statusCode == 200 && data['token'] != null && data['user'] != null) {
          print('Login successful, creating user model');
          final user = UserModel.fromJson(data['user'], data['token']);
          await _saveUserData(user);
          
          return {
            'success': true,
            'message': data['message'] ?? 'Login successful',
            'user': user,
          };
        } else {
          print('Login failed: ${data['message'] ?? 'Unknown error'}');
          // Server returned an error or missing data
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed. Please try again.',
          };
        }
      } catch (jsonError) {
        print('Error parsing JSON response: $jsonError');
        return {
          'success': false,
          'message': 'Server returned invalid data. Please try again later.',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please check your connection and try again.',
      };
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(UserModel user) async {
    try {
      print('Saving user data to SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      
      // Save token
      await prefs.setString('token', user.token);
      
      // Save user data
      await prefs.setString('userId', user.id);
      await prefs.setString('userEmail', user.email);
      
      // Save full user details
      if (user.fullname != null) {
        await prefs.setString('userFullname', user.fullname!);
      }
      if (user.dob != null) {
        await prefs.setString('userDob', user.dob!);
      }
      if (user.isVerified != null) {
        await prefs.setString('userIsVerified', user.isVerified!);
      }
      
      // Save user object as JSON string
      await prefs.setString('user', jsonEncode(user.toJson()));
      
      // Save login status
      await prefs.setBool('isLoggedIn', true);
      
      print('User data saved successfully');
    } catch (e) {
      print('Error saving user data: $e');
      throw e; // Rethrow to handle in the login method
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Get user token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get user data
  Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    
    if (userJson != null) {
      try {
        Map<String, dynamic> userMap = jsonDecode(userJson);
        return UserModel(
          id: userMap['id'] ?? '',
          email: userMap['email'] ?? '',
          token: userMap['token'] ?? '',
          fullname: userMap['fullname'] ?? '',
          dob: userMap['dob'] ?? '',
          isVerified: userMap['isVerified'] ?? '',
          userKyc: userMap['userKyc'] != null ? UserKyc.fromJson(userMap['userKyc']) : null,
          wallet: userMap['wallet'] != null ? WalletModel.fromJson(userMap['wallet']) : null,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print('Sending forgot password request for email: $email');
      print('API URL: $baseUrl/user/forget-password');
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/forget-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      try {
        final data = jsonDecode(response.body);
        print('Forgot password API response parsed: $data'); 
        
        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': data['message'] ?? 'Password reset instructions sent to your email',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to process your request. Please try again.',
          };
        }
      } catch (e) {
        print('Error parsing JSON response: $e');
        return {
          'success': false,
          'message': 'Server returned invalid data. Please try again later.',
        };
      }
    } catch (e) {
      print('Forgot password error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please check your connection and try again.',
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register(String fullname, String email, String password, String dob) async {
    try {
      print('Attempting registration for email: $email');
      print('API URL: $baseUrl/user/register');
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'password': password,
          'dob': dob,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Check if the response body is valid JSON
      try {
        final data = jsonDecode(response.body);
        print('Register API response parsed: $data'); 
        
        // Print token separately for better visibility
        if (data['token'] != null) {
          print('\n=== Registration Token ===');
          print('Full Token: ${data['token']}');
          print('Token Length: ${data['token'].length}');
          print('=======================\n');
        }
        
        // Check if registration was successful
        if (response.statusCode == 201 || response.statusCode == 200) {
          print('Registration successful');
          
          // If the API returns token, save the user data
          if (data['success'] == true && data['token'] != null) {
            // Create user model from the response using the specialized factory method
            final user = UserModel.fromRegisterResponse(data);
            
            // Update with additional information not in API response
            final updatedUser = UserModel(
              id: user.id,
              email: user.email,
              token: user.token,
              fullname: fullname,
              dob: dob,
              isVerified: user.isVerified,
            );
            
            await _saveUserData(updatedUser);
            
            return {
              'success': true,
              'message': data['message'] ?? 'Registration successful',
              'user': updatedUser,
              'autoLogin': true
            };
          }
          
          // If no token/user returned, just return success
          return {
            'success': true,
            'message': data['message'] ?? 'Registration successful. Please login.',
            'autoLogin': false
          };
        } else {
          print('Registration failed: ${data['message'] ?? 'Unknown error'}');
          // Server returned an error
          return {
            'success': false,
            'message': data['message'] ?? 'Registration failed. Please try again.',
          };
        }
      } catch (e) {
        print('Error parsing JSON response: $e');
        return {
          'success': false,
          'message': 'Server returned invalid data. Please try again later.',
        };
      }
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please check your connection and try again.',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
} 