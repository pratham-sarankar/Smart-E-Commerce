import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Stack(
        children: [
          // Background structure
          Column(
            children: [
              // App bar section with custom background
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // App bar with background image
                  Container(
                    height: 160,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/app_bar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Color(0xFF5030E8)),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Wave overlay at the bottom
                  Image.asset(
                    'assets/images/appbar_line.png',
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                ],
              ),
            ],
          ),
          
          // Content
          Column(
            children: [
              // Spacer for the app bar area
              const SizedBox(height: 180),
              
              // Avatar section
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/profile_pic.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Color(0xFF5030E8), size: 20),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Profile details
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Name section
                                ProfileInfoItem(
                                  icon: Icons.person,
                                  iconColor: const Color(0xFF5030E8),
                                  title: 'Name',
                                  value: 'Rajat Pradhan',
                                  onEdit: () {},
                                ),
                                
                                // DOB section
                                ProfileInfoItem(
                                  icon: Icons.info,
                                  iconColor: const Color(0xFF5030E8),
                                  title: 'DOB',
                                  value: '05/06/2001',
                                  onEdit: () {},
                                ),
                                
                                // Email section
                                ProfileInfoItem(
                                  icon: Icons.email,
                                  iconColor: const Color(0xFF5030E8),
                                  title: 'Email',
                                  value: 'rajat.pradhan@gmail.com',
                                  onEdit: () {},
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
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onEdit;

  const ProfileInfoItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.edit, color: Color(0xFF5030E8), size: 22),
            ),
          ),
        ],
      ),
    );
  }
} 