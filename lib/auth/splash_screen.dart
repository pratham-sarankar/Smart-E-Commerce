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
  
  // Animation state
  double _logoPosition = -100;
  double _logoScale = 0.5;
  double _textPosition = 100; // Start below screen
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Start splash animation sequence
    _startSplashAnimation();
  }
  
  void _startSplashAnimation() {
    // Step 1: Bring in logo from top
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _logoPosition = 0;
          _logoVisible = true;
        });
        
        // Step 2: Scale logo
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
                
                // Step 4: Check login status and navigate after animation completes
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF19173A), Color(0xFF363079)],
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
                        child: Image.network(
                          'https://cdn.builder.io/api/v1/image/assets/TEMP/2b11c06bdf765b35249d2275cc985e97f0b5fa2a',
                          width: 207,
                          height: 227,
                          fit: BoxFit.contain,
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
                          'MASTI LOTTIE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: <Color>[
                                  Color(0xFF7DE2FC),
                                  Color(0xFF6366F1),
                                ],
                              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
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
