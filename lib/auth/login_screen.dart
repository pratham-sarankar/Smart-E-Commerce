import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_eommerce/auth/otp_screen.dart';
import 'package:smart_eommerce/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberPassword = false;
  final _formKey = GlobalKey<FormState>();

  // Animation for white container
  double _whiteContainerHeight = 0;
  bool _showLoginForm = false;
  
  late AnimationController _animationController;
  late Animation<double> _whiteContainerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _whiteContainerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutQuart),
      ),
    );

    // Start the white container animation immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
      _loadSavedCredentials();
    });
  }

  void _startAnimation() {
    if (mounted) {
      setState(() {
        _whiteContainerHeight = MediaQuery.of(context).size.height * 0.9;
      });
      
      _animationController.forward();
      
      // Show login form once animation is completed
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _showLoginForm = true;
          });
        }
      });
    }
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberPassword = prefs.getBool('rememberPassword') ?? false;
      
      if (rememberPassword) {
        final savedEmail = prefs.getString('savedEmail') ?? '';
        final savedPassword = prefs.getString('savedPassword') ?? '';
        
        setState(() {
          _rememberPassword = rememberPassword;
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
        });
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_rememberPassword) {
        await prefs.setString('savedEmail', _emailController.text.trim());
        await prefs.setString('savedPassword', _passwordController.text);
        await prefs.setBool('rememberPassword', true);
      } else {
        // Clear saved credentials if remember password is turned off
        await prefs.remove('savedEmail');
        await prefs.remove('savedPassword');
        await prefs.setBool('rememberPassword', false);
      }
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> loginData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save token
      await prefs.setString('auth_token', loginData['token']);
      
      // Save user data
      if (loginData['user'] != null) {
        await prefs.setString('user_id', loginData['user']['id']);
        await prefs.setString('user_email', loginData['user']['email']);
      }
      
      // Set login status
      await prefs.setBool('is_logged_in', true);
      
      print('User data saved successfully');
    } catch (e) {
      print('Error saving user data: $e');
      throw e;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('Starting login process for email: ${_emailController.text.trim()}');
        
        // Save credentials if "Remember password" is checked
        await _saveCredentials();
        
        final result = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        print('Login result: $result');

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          print('Login successful, saving user data');
          // Save user data and token
          await _saveUserData(result);
          
          print('Login successful, navigating to main screen');
          // Navigate to Main Screen on successful login
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          print('Login failed: ${result['message']}');
          // Show specific error message from the server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      } catch (e) {
        print('Exception during login: $e');
        
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: ${e.toString()}'),
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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF19173A), Color(0xFF363079)],
              stops: [0.2, 0.8],
            ),
          ),
          child: Stack(
            children: [
              // White Container Animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    top: 35,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      opacity: _whiteContainerAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, (1.0 - _whiteContainerAnimation.value) * 100),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOut,
                              opacity: _showLoginForm ? 1.0 : 0.0,
                              child: AnimatedSlide(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutQuart,
                                offset: _showLoginForm ? Offset.zero : const Offset(0, 0.2),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Top section
                                        Column(
                                          children: [
                                            // Decorated logo section
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  width: 90,
                                                  height: 90,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFF5F67EE).withOpacity(0.2),
                                                        Color(0xFF5F67EE).withOpacity(0.05),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Hero(
                                                  tag: 'login_logo',
                                                  child: Material(
                                                    type: MaterialType.transparency,
                                                    child: Container(
                                                      padding: EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.08),
                                                            blurRadius: 8,
                                                            spreadRadius: 1,
                                                            offset: Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Image.network(
                                                        'https://cdn.builder.io/api/v1/image/assets/TEMP/2b11c06bdf765b35249d2275cc985e97f0b5fa2a',
                                                        width: 50,
                                                        height: 55,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Hero(
                                              tag: 'login_title',
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: Text(
                                                  'MASTI LOTTIE',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF5F67EE),
                                                    letterSpacing: 2.0,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black.withOpacity(0.12),
                                                        offset: Offset(1, 2),
                                                        blurRadius: 1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 20),
                                        
                                        // Middle section
                                        Column(
                                          children: [
                                            // Welcome text with gradient container
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF5F67EE).withOpacity(0.08),
                                                    Color(0xFF5F67EE).withOpacity(0.02),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Column(
                                                children: [
                                                  const Text(
                                                    'Welcome',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF19173A),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  const Text(
                                                    'By signing in you are agreeing our',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {},
                                                    child: const Text(
                                                      'Term and privacy policy',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Color(0xFF5F67EE),
                                                        fontWeight: FontWeight.bold,
                                                        decoration: TextDecoration.underline,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 24),
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
                                                style: const TextStyle(fontSize: 15),
                                                decoration: InputDecoration(
                                                  hintText: 'Email Address',
                                                  hintStyle: const TextStyle(fontSize: 15),
                                                  prefixIcon: Container(
                                                    margin: EdgeInsets.only(left: 12, right: 8),
                                                    child: Icon(Icons.email_outlined, color: Color(0xFF5F67EE), size: 22),
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
                                                  return null;
                                                },
                                                style: const TextStyle(fontSize: 15),
                                                obscureText: _obscurePassword,
                                                decoration: InputDecoration(
                                                  hintText: 'Password',
                                                  hintStyle: const TextStyle(fontSize: 15),
                                                  prefixIcon: Container(
                                                    margin: EdgeInsets.only(left: 12, right: 8),
                                                    child: Icon(Icons.lock_outline, color: Color(0xFF5F67EE), size: 22),
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
                                            // Remember password and Forget password
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _rememberPassword = !_rememberPassword;
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 22,
                                                    height: 22,
                                                    decoration: BoxDecoration(
                                                      color: _rememberPassword ? Color(0xFF5F67EE) : Colors.white,
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: _rememberPassword 
                                                          ? null 
                                                          : Border.all(color: Colors.grey.shade400, width: 1.5),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: _rememberPassword 
                                                              ? Color(0xFF5F67EE).withOpacity(0.3)
                                                              : Colors.black.withOpacity(0.05),
                                                          blurRadius: 5,
                                                          spreadRadius: 0,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: _rememberPassword
                                                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                                                        : const SizedBox(),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _rememberPassword = !_rememberPassword;
                                                    });
                                                  },
                                                  child: const Text(
                                                    'Remember password',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    // Add forgot password functionality
                                                    Navigator.pushNamed(context, '/forgot_password');
                                                  },
                                                  child: const Text(
                                                    'Forget password',
                                                    style: TextStyle(
                                                      color: Color(0xFF5F67EE),
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 24),
                                        
                                        // Bottom section
                                        Column(
                                          children: [
                                            // Login and Register buttons
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height: 52,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Color(0xFF5F67EE).withOpacity(0.3),
                                                          blurRadius: 8,
                                                          spreadRadius: 0,
                                                          offset: Offset(0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: _isLoading
                                                        ? Center(
                                                            child: CircularProgressIndicator(
                                                              color: Colors.white,
                                                            ),
                                                          )
                                                        : ElevatedButton(
                                                            onPressed: _login,
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Color(0xFF5F67EE),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                                              elevation: 0,
                                                            ),
                                                            child: const Text(
                                                              'Login',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Container(
                                                    height: 52,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.05),
                                                          blurRadius: 8,
                                                          spreadRadius: 0,
                                                          offset: Offset(0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        // Navigate to the register screen
                                                        Navigator.pushNamed(context, '/register');
                                                      },
                                                      style: OutlinedButton.styleFrom(
                                                        side: const BorderSide(color: Color(0xFF5F67EE), width: 1.5),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                                      ),
                                                      child: const Text(
                                                        'Register',
                                                        style: TextStyle(
                                                          color: Color(0xFF5F67EE),
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 24),
                                            Center(
                                              child: const Text(
                                                'Login with touch ID',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Center(
                                              child: Container(
                                                width: 54,
                                                height: 54,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF5F67EE).withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0xFF5F67EE).withOpacity(0.1),
                                                      blurRadius: 8,
                                                      spreadRadius: 0,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.fingerprint,
                                                  color: Color(0xFF5F67EE),
                                                  size: 32,
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5F67EE),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
