import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
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
                    height: 175,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/app_bar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Color(0xFF5030E8), size: 18),
                                    onPressed: () => Navigator.pop(context),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Setting',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.search, color: Color(0xFF5030E8), size: 18),
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Avatar and user info section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white,
                                  backgroundImage: const AssetImage('assets/images/profile_pic.png'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Rajat Pradhan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        'rajat.pradhan@gmail.com',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: IconButton(
                                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
              const SizedBox(height: 195),
              
              // Settings categories
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'App Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        // Settings items
                        SettingsItem(
                          icon: Icons.person,
                          iconColor: const Color(0xFF5030E8),
                          title: 'Personal Information',
                          subtitle: 'Your account information',
                          onTap: () {},
                        ),
                        
                        SettingsItem(
                          icon: Icons.notifications,
                          iconColor: const Color(0xFF5030E8),
                          title: 'Notifications & Chat',
                          subtitle: 'Chat and notifications settings',
                          onTap: () {},
                        ),
                        
                        SettingsItem(
                          icon: Icons.privacy_tip,
                          iconColor: const Color(0xFF5030E8),
                          title: 'Privacy & Permissions',
                          subtitle: 'Contact, My Album and Block Contact',
                          onTap: () {},
                        ),
                        
                        SettingsItem(
                          icon: Icons.storage,
                          iconColor: const Color(0xFF5030E8),
                          title: 'Data & Storage',
                          subtitle: 'Data preferences and storage settings',
                          onTap: () {},
                        ),
                        
                        SettingsItem(
                          icon: Icons.lock,
                          iconColor: const Color(0xFF5030E8),
                          title: 'Password & Account',
                          subtitle: 'Manage your Account settings',
                          onTap: () {},
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'More',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        SettingsItem(
                          icon: Icons.help,
                          iconColor: const Color(0xFF5030E8),
                          title: 'Help',
                          subtitle: 'Data preferences and storage settings',
                          onTap: () {},
                        ),
                        
                        SettingsItem(
                          icon: Icons.feedback,
                          iconColor: const Color(0xFF5030E8),
                          title: 'Feedback',
                          subtitle: 'Chat and notifications settings',
                          onTap: () {},
                        ),
                        
                        SettingsItem(
                          icon: Icons.info,
                          iconColor: const Color(0xFF5030E8),
                          title: 'About',
                          subtitle: 'Version 1.2',
                          onTap: () {},
                        ),
                        
                        SettingsItem(
                          icon: Icons.share,
                          iconColor: const Color(0xFF5030E8),
                          title: 'Invite a Friend',
                          subtitle: 'Invite a friend to make this app',
                          onTap: () {},
                        ),
                        
                        // Logout button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
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

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
} 