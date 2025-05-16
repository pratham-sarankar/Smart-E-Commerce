import 'package:flutter/material.dart';
import 'package:smart_eommerce/screens/main_screen.dart';

class WinnerScreen extends StatefulWidget {
  const WinnerScreen({Key? key}) : super(key: key);

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            // App bar section as Stack with line behind transparent app bar
            Container(
              height: 56, // Standard app bar height
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/appbar_line.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen()), (route) => false);
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5030E8).withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Daily Winner',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 280,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        image: DecorationImage(
                          image: AssetImage('assets/images/winners.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        children: [
                          const Text(
                            'Today Winner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      color: const Color(0xFF5030E8),
                      child: const Text(
                        'Rajat Pradhan from Bhopal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Orci, interdum elit gravida enim ac eu tellus.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const Text(
                            'Past Winners',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    
                    _buildPastWinnerItem('assets/images/avatar.png', 'Rajat Pradhan', 'From Bhopal', '₹100000.00'),
                    _buildPastWinnerItem('assets/images/profile_pic.png', 'Rajat Pradhan', 'From Bhopal', '₹100000.00'),
                    _buildPastWinnerItem('assets/images/avatar.png', 'Rajat Pradhan', 'From Bhopal', '₹100000.00'),
                    
                    const SizedBox(height: 24),
                    
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.people_alt_outlined),
                              label: const Text('Invite from Contacts'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5030E8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.favorite_border),
                              label: const Text('Donate 1 rupee'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF5030E8)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastWinnerItem(String imagePath, String name, String location, String amount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD8C4F4),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5030E8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Shimmer text effect class
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerText({
    Key? key,
    required this.text,
    required this.style,
    required this.baseColor,
    required this.highlightColor,
  }) : super(key: key);

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style,
          ),
        );
      },
    );
  }
} 