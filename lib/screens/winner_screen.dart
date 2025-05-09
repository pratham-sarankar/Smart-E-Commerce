import 'package:flutter/material.dart';

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
              height: 70, // Reduced height from 70 to 56 (standard app bar height) 
              child: Stack(
                children: [
                  // App bar line as the base layer
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/appbar_line.png',
                      fit: BoxFit.cover, // Changed from fill to cover for better scaling
                      width: double.infinity,
                    ),
                  ),
                  
                  // Transparent app bar overlaying the line
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0), // Reduced vertical padding
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back button with title next to it
                          Row(
                            children: [
                              // Back button - with transparent background
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 40, // Reduced from 50 to 40
                                  height: 40, // Reduced from 50 to 40
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5030E8).withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 20, // Added size parameter to reduce icon size
                                  ),
                                ),
                              ),
                              // Title - positioned next to back button
                              const SizedBox(width: 15),
                              const Text(
                                'Daily Winner',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20, // Reduced from 24 to 20
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
                    // Winners banner image at the top
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        image: DecorationImage(
                          image: AssetImage('assets/images/winners.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    // Main winner profile
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Container(
                          //   width: 120,
                          //   height: 120,
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     border: Border.all(
                          //       color: const Color(0xFF5030E8),
                          //       width: 3,
                          //     ),
                          //     image: const DecorationImage(
                          //       image: AssetImage('assets/images/profile_pic.png'),
                          //       fit: BoxFit.cover,
                          //     ),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: const Color(0xFF5030E8).withOpacity(0.5),
                          //         blurRadius: 20,
                          //         spreadRadius: 5,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          
                          // const SizedBox(height: 16),
                          
                          const Text(
                            'Today Winner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: const Color(0xFF5030E8),
                      child: const Text(
                        'Rajat Pradhan from Bhopal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Orci, interdum elit gravida enim ac eu tellus.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    
                    // Past winner title with decorative elements
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: Column(
                        children: [
                          const Text(
                            'Past Winners',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Past winners list
                    _buildPastWinnerItem('assets/images/avatar.png', 'Rajat Pradhan', 'From Bhopal', '₹100000.00'),
                    _buildPastWinnerItem('assets/images/profile_pic.png', 'Rajat Pradhan', 'From Bhopal', '₹100000.00'),
                    _buildPastWinnerItem('assets/images/avatar.png', 'Rajat Pradhan', 'From Bhopal', '₹100000.00'),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons in a row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        children: [
                          // Invite button
                          Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.people_alt_outlined),
                              label: const Text('Invite from Contacts'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5030E8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Donate button
                          Container(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.favorite_border),
                              label: const Text('Donate 1 rupee'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF5030E8)),
                                padding: const EdgeInsets.symmetric(vertical: 15),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
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
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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