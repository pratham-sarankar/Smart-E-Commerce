import 'package:flutter/material.dart';

class AccountSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF19173A), Color(0xFF363079)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main white container with rounded corners
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      // Wave background image instead of custom painter
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.asset(
                            'assets/icons/wave.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      // Content layout
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0,vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title - Account Creation Successful
                            Text(
                              'Account Creation Successful!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Lady illustration
                      Positioned(
                        left:10,
                        bottom: 20,
                        width: 300,
                        height: 650,
                        child: Image.asset(
                          'assets/images/lady.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      // Next button at the bottom next to lady's feet
                      Positioned(
                        bottom: 40,
                        right: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to main screen
                            Navigator.of(context).pushReplacementNamed('/main');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF590DD8),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      // Avatar, Name and Phone on the right side
                      Positioned(
                        top: 130,
                        right: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar in circle
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFFD8D0E3),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/avatar.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            
                            // Name
                            Text(
                              'Rajat',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            // Phone number
                            Text(
                              '236-897 548963256',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
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
      ),
    );
  }
} 