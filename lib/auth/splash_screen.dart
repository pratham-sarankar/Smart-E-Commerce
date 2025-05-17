import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_eommerce/auth/login_screen.dart';
import 'package:smart_eommerce/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_eommerce/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _logoVisible = false;
  bool _logoScaled = false;
  bool _textVisible = false;
  bool _taglineVisible = false;
  
  // Animation state
  double _logoPosition = -100;
  double _logoScale = 0.5;
  double _logoOpacity = 0.0; // Add opacity for fade-in
  double _textPosition = 100; // Start below screen
  double _textOpacity = 0.0;
  double _taglineOpacity = 0.0; // Add tagline opacity

  @override
  void initState() {
    super.initState();
    
    // Start splash animation sequence
    _startSplashAnimation();
  }
  
  void _startSplashAnimation() {
    // Step 1: Bring in logo with fade-in and glow
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _logoPosition = 0;
          _logoVisible = true;
          _logoOpacity = 1.0; // Fade in logo
        });
        
        // Step 2: Scale and add glow effect to logo
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _logoScale = 1.0;
              _logoScaled = true;
            });
            
            // Step 3: Bring text from bottom after logo is centered and scaled
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) {
                setState(() {
                  _textPosition = 0; // Move to position below logo
                  _textOpacity = 1.0;
                  _textVisible = true;
                });
                
                // Step 4: Add tagline with fade-in
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    setState(() {
                      _taglineOpacity = 1.0;
                      _taglineVisible = true;
                    });
                    
                    // Step 5: Check login status after animation completes
                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (mounted) {
                        _checkLoginStatus();
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  // Check if user is already logged in and navigate to appropriate screen
  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      if (isLoggedIn) {
        // User is already logged in, navigate to main screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        // User is not logged in, navigate to login screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      // If any error occurs during login check, navigate to login screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B1D3A), Color(0xFF0B1D3A).withOpacity(0.9)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animation from top
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  transform: Matrix4.translationValues(0, _logoPosition, 0),
                  child: AnimatedScale(
                    scale: _logoScale,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    child: Hero(
                      tag: 'login_logo',
                      child: Material(
                        type: MaterialType.transparency,
                        child: AnimatedOpacity(
                          opacity: _logoOpacity,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeIn,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFFD700).withOpacity(0.4), // Gold shadow
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: Offset(0, 5),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: Offset(0, 4),
                                ),
                                // Glow effect
                                BoxShadow(
                                  color: Color(0xFFFFD700).withOpacity(0.3),
                                  blurRadius: 25,
                                  spreadRadius: 1,
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
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Text animation coming from bottom
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  transform: Matrix4.translationValues(0, _textPosition, 0),
                  child: AnimatedOpacity(
                    opacity: _textOpacity,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeIn,
                    child: Hero(
                      tag: 'login_title',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          'Lakhpati Club',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFD700),
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(1, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Tagline animation
                AnimatedOpacity(
                  opacity: _taglineOpacity,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeIn,
                  child: Text(
                    'Har Din Ek Naya Lakhpati',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
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
