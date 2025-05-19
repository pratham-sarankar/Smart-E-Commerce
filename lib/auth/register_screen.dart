import 'package:flutter/material.dart';
import 'package:smart_eommerce/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    // No default values in production
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dobController.text.isEmpty 
          ? DateTime(2000) 
          : DateFormat('dd-MM-yyyy').parse(_dobController.text),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFFFD700),
              onPrimary: Color(0xFF0B1D3A),
              onSurface: Color(0xFF0B1D3A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('Starting registration process for email: ${_emailController.text.trim()}');
        
        // Prepare registration data
        Map<String, dynamic> registrationData = {
          'fullname': _fullnameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'dob': _dobController.text,
        };

        // Add referral code if it's not empty
        if (_referralCodeController.text.trim().isNotEmpty) {
          registrationData['referredBy'] = _referralCodeController.text.trim();
        }
        
        final result = await _authService.register(
          registrationData['fullname'],
          registrationData['email'],
          registrationData['password'],
          registrationData['dob'],
          referredBy: registrationData['referredBy'],
        );

        print('Registration result: $result');

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          print('Registration successful');
          
          // Save user data to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode({
            'email': _emailController.text.trim(),
            'fullname': _fullnameController.text.trim(),
            'dob': _dobController.text,
          }));
          
          // Setup FCM token refresh listener
          _authService.setupFcmTokenRefresh();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration successful!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          
          // Navigate to onboarding screen first after registration
          print('User registered, navigating to onboarding screen');
          Navigator.pushReplacementNamed(context, '/onboarding');
        } else {
          print('Registration failed: ${result['message']}');
          // Show specific error message from the server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration failed. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      } catch (e) {
        print('Exception during registration: $e');
        
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1D3A), Color(0xFF0B1D3A).withOpacity(0.9)],
            stops: [0.2, 0.8],
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -15,
                  right: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFD700).withOpacity(0.2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: -8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFD700).withOpacity(0.15),
                    ),
                  ),
                ),
                
                // Main content with scroll
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Top section
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow effect
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: RadialGradient(
                                    colors: [
                                      Color(0xFFFFD700).withOpacity(0.15),
                                      Color(0xFFFFD700).withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                    stops: [0.0, 0.6, 1.0],
                                  ),
                                ),
                              ),
                              // Middle gradient container
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFD700).withOpacity(0.2),
                                      Color(0xFFFFD700).withOpacity(0.05),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFFFD700).withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              // Logo container
                              Hero(
                                tag: 'login_logo',
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 0,
                                          offset: Offset(0, 4),
                                        ),
                                        BoxShadow(
                                          color: Colors.white,
                                          blurRadius: 4,
                                          spreadRadius: 2,
                                          offset: Offset(0, -2),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.9),
                                          ],
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          'assets/icon/icon.png',
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Hero(
                            tag: 'login_title',
                            child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                'Lakhpati Club',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFFD700),
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(1, 2),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Registration welcome container
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFFD700).withOpacity(0.08),
                                  Color(0xFFFFD700).withOpacity(0.02),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0B1D3A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'By signing up you are agreeing our',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF0B1D3A),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Term and privacy policy',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFFFD700),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Full Name field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _fullnameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF0B1D3A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Full Name',
                                hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                                prefixIcon: Container(
                                  margin: EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(Icons.person_outline, color: Color(0xFFFFD700), size: 22),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFFFD700), width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Email field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF0B1D3A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                                prefixIcon: Container(
                                  margin: EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(Icons.email_outlined, color: Color(0xFFFFD700), size: 22),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFFFD700), width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Date of Birth field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _dobController,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your date of birth';
                                }
                                return null;
                              },
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF0B1D3A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Date of Birth (DD-MM-YYYY)',
                                hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                                prefixIcon: Container(
                                  margin: EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(Icons.calendar_today_outlined, color: Color(0xFFFFD700), size: 22),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF5F67EE), width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF0B1D3A),
                              ),
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                                prefixIcon: Container(
                                  margin: EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(Icons.lock_outline, color: Color(0xFFFFD700), size: 22),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.grey,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF5F67EE), width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Confirm Password field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF0B1D3A),
                              ),
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                                prefixIcon: Container(
                                  margin: EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(Icons.lock_outline, color: Color(0xFFFFD700), size: 22),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.grey,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFF5F67EE), width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Add Referral Code field (optional)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _referralCodeController,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(8),
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                              ],
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF0B1D3A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Referral Code (Optional)',
                                hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                                prefixIcon: Container(
                                  margin: EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(Icons.card_giftcard, color: Color(0xFFFFD700), size: 22),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Color(0xFFFFD700), width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Register button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFFD700).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFFD700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0B1D3A),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Color(0xFF0B1D3A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Already have an account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Color(0xFF0B1D3A),
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Back button
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFD700).withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFFFD700),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Loading overlay
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 