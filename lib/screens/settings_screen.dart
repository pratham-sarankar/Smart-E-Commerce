import 'package:flutter/material.dart';
import 'package:smart_eommerce/screens/main_screen.dart';
import 'package:smart_eommerce/screens/user_info_screen.dart';
import 'package:smart_eommerce/services/user_service.dart';
import 'package:smart_eommerce/models/user_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_eommerce/screens/home_screen.dart';
import 'package:smart_eommerce/screens/feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  UserModel? _userProfile;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isAutoDeductEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _userService.getUserProfile();
      
      if (result['success']) {
        setState(() {
          _userProfile = result['user'];
          _isAutoDeductEnabled = _userProfile?.wallet?.autoDeduct ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile data';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAutoDeduct(bool value) async {
    try {
      final result = await _userService.toggleAutoDeduct(value);
      if (result['success']) {
        setState(() {
          _isAutoDeductEnabled = value;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while updating settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D3A),
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
                  ),
                  
                  // Wave overlay at the bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/images/appbar_line.png',
                      fit: BoxFit.fill,
                      width: double.infinity,
                    ),
                  ),

                  // Content overlay
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 46.0),
                      child: Row(
                        children: [
                          // Back button
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                splashColor: Colors.white.withOpacity(0.2),
                                highlightColor: Colors.white.withOpacity(0.1),
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    FadePageRoute(page: const MainScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Center(
                                  child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Avatar and user info
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/profile_pic.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userProfile?.fullname ?? 'Loading...',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _userProfile?.email ?? 'Loading...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
                                    letterSpacing: 0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
            ],
          ),
          
          // Content
          Column(
            children: [
              // Spacer for the app bar area
              const SizedBox(height: 170),
              
              // Settings categories
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          iconColor: const Color(0xFFFFD700),
                          title: 'Personal Information',
                          subtitle: 'Your account information',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserInfoScreen()),
                            );
                          },
                        ),
                        
                        // Add Auto-deduct toggle
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B1D3A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Auto-deduct',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isAutoDeductEnabled ? 'Enabled' : 'Disabled',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Switch.adaptive(
                                      value: _isAutoDeductEnabled,
                                      onChanged: _toggleAutoDeduct,
                                      activeColor: const Color(0xFFFFD700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                          icon: Icons.feedback,
                          iconColor: const Color(0xFFFFD700),
                          title: 'Feedback',
                          subtitle: 'Chat and notifications settings',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                            );
                          },
                        ),
                        
                        SettingsItem(
                          icon: Icons.info,
                          iconColor: const Color(0xFFFFD700),
                          title: 'About',
                          subtitle: 'Version 1.2',
                          onTap: () {},
                        ),
                        
                        SettingsItem(
                          icon: Icons.share,
                          iconColor: const Color(0xFFFFD700),
                          title: 'Invite a Friend',
                          subtitle: 'Invite a friend to make this app',
                          onTap: () async {
                            try {
                              // Generate referral code first
                              final result = await _userService.generateReferralCode();
                              
                              if (result['success']) {
                                final referralCode = result['user']['referralCode'];
                                await Share.share(
                                  'Join me on Lakhpati Club! Download the app and start winning real money. Use my referral code: $referralCode',
                                  subject: 'Join Lakhpati Club',
                                );
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message']),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to share. Please try again.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        
                        // Logout button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Show confirmation dialog
                              final bool? confirmLogout = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xFF0B1D3A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                                    title: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFD700).withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.logout_rounded,
                                            color: Color(0xFFFFD700),
                                            size: 34,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                                    content: const Text(
                                      'Are you sure you want to logout from your account? You will need to login again to access your profile.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    actions: <Widget>[
                                      SizedBox(
                                        width: double.infinity,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                                  ),
                                                ),
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text(
                                                  'CANCEL',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFFFD700),
                                                  foregroundColor: const Color(0xFF0B1D3A),
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text(
                                                  'LOGOUT',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              
                              // If user confirms logout
                              if (confirmLogout == true) {
                                try {
                                  // Call logout API
                                  final result = await _userService.logout();
                                  
                                  // Navigate to login screen and clear all previous routes
                                  if (mounted) {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/login',
                                      (route) => false, // This removes all previous routes
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed to logout. Please try again.')),
                                    );
                                  }
                                }
                              }
                            },
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
            color: const Color(0xFF0B1D3A),
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