import 'package:flutter/material.dart';
import 'package:smart_eommerce/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _logoVisible = false;
  bool _logoScaled = false;
  bool _textVisible = false;
  bool _transitionStarted = false;
  double _whiteContainerHeight = 0;
  
  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _whiteContainerAnimation;
  late Animation<double> _contentMoveAnimation;

  // Animation state
  double _logoPosition = -100;
  double _logoScale = 0.5;
  double _textPosition = 100; // Start below screen
  double _textOpacity = 0.0;
  
  // Final transition values
  double _contentScale = 1.0;
  double _contentMoveY = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScaleAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _textScaleAnimation = Tween<double>(begin: 1.0, end: 0.75).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _whiteContainerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _contentMoveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Step 1: Bring in logo from top
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _logoPosition = 0;
        _logoVisible = true;
      });
      
      // Step 2: Scale logo
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          _logoScale = 1.0;
          _logoScaled = true;
        });
        
        // Step 3: Bring text from bottom after logo is centered and scaled
        Future.delayed(const Duration(milliseconds: 400), () {
          setState(() {
            _textPosition = 0; // Move to position below logo
            _textOpacity = 1.0;
            _textVisible = true;
          });
          
          // Step 4: Transition to login screen - scale down and move to bottom
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _transitionStarted = true;
                _contentScale = 0.6; // Scale down
                _contentMoveY = MediaQuery.of(context).size.height * 0.25; // Move down
                _whiteContainerHeight = MediaQuery.of(context).size.height * 0.7;
              });
              _animationController.forward();
              Future.delayed(const Duration(milliseconds: 1200), () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 800),
                  ),
                );
              });
            }
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF19173A), Color(0xFF363079)],
          ),
        ),
        child: Stack(
          children: [
            // White Container with Logo and Text (final transition)
            if (_transitionStarted)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    height: _whiteContainerHeight * _whiteContainerAnimation.value,
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
                        physics: const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // We use logo_container tag to avoid duplicate tag error
                              Hero(
                                tag: 'logo_container',
                                child: Image.network(
                                  'https://cdn.builder.io/api/v1/image/assets/TEMP/2b11c06bdf765b35249d2275cc985e97f0b5fa2a',
                                  width: 207 * _logoScaleAnimation.value,
                                  height: 227 * _logoScaleAnimation.value,
                                ),
                              ),
                              const SizedBox(height: 30),
                              // We use title_container tag to avoid duplicate tag error
                              Hero(
                                tag: 'title_container',
                                child: Text(
                                  'MASTI LOTTIE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32 * _textScaleAnimation.value,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
            // Initial animation (only visible before transition) and transition animation
            AnimatedOpacity(
              opacity: _transitionStarted ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()
                    ..scale(_transitionStarted ? _contentScale : 1.0)
                    ..translate(0.0, _transitionStarted ? _contentMoveY : 0.0),
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
                            tag: 'logo',
                            child: Image.network(
                              'https://cdn.builder.io/api/v1/image/assets/TEMP/2b11c06bdf765b35249d2275cc985e97f0b5fa2a',
                              width: 207,
                              height: 227,
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
                            tag: 'title',
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
