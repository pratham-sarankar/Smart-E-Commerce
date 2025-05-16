import 'package:flutter/material.dart';
import 'package:smart_eommerce/models/user_model.dart';
import 'package:smart_eommerce/screens/main_screen.dart';
import 'package:smart_eommerce/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  bool _isLoggingOut = false;
  UserModel? _userProfile;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Test method to show a simple dialog
  void _showTestDialog() {
    print('Attempting to show test dialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Dialog'),
          content: const Text('This is a test dialog to verify dialogs are working'),
          actions: [
            TextButton(
              onPressed: () {
                print('Test dialog dismissed');
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) => print('Dialog future completed'));
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
  
  // Simplified logout method
  Future<void> _logout() async {
    print('Direct logout without dialog');
    
    setState(() {
      _isLoggingOut = true;
    });
    
    try {
      print('Calling logout API directly');
      final result = await _userService.logout();
      print('Logout API response: $result');
      
      // Try to navigate to login screen
      try {
        print('Attempting navigation to login screen');
        // Check if the /login route exists in the app
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        print('Navigation to /login route successful');
      } catch (navError) {
        print('Error navigating to /login: $navError');
        // Fallback: Try to pop to the root
        Navigator.of(context).popUntil((route) => route.isFirst);
        print('Navigated to root as fallback');
      }
    } catch (e) {
      print('Error during direct logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during logout')),
      );
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

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
                            GestureDetector(
                              onTap: () {
                                print('Back button pressed');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Back button pressed')),
                                );
                                try {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MainScreen()),
                                  );
                                  print('Navigation to MainScreen successful');
                                } catch (e) {
                                  print('Error during navigation: $e');
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF5030E8),
                                  size: 24,
                                ),
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
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Color(0xFF5030E8))
                    : _errorMessage.isNotEmpty
                      ? _buildErrorView()
                      : SingleChildScrollView(
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
                                        value: _userProfile?.fullname ?? 'Not available',
                                        onEdit: () {},
                                      ),
                                      
                                      // DOB section
                                      ProfileInfoItem(
                                        icon: Icons.info,
                                        iconColor: const Color(0xFF5030E8),
                                        title: 'DOB',
                                        value: _userProfile?.dob ?? 'Not available',
                                        onEdit: () {},
                                      ),
                                      
                                      // Email section
                                      ProfileInfoItem(
                                        icon: Icons.email,
                                        iconColor: const Color(0xFF5030E8),
                                        title: 'Email',
                                        value: _userProfile?.email ?? 'Not available',
                                        onEdit: () {},
                                      ),

                                      // Verification status
                                      ProfileInfoItem(
                                        icon: Icons.verified_user,
                                        iconColor: const Color(0xFF5030E8),
                                        title: 'Verification Status',
                                        value: _formatVerificationStatus(_userProfile?.isVerified),
                                        onEdit: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Professional logout button outside the card
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(horizontal: 30),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5030E8).withOpacity(0.9),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () async {
                                    // Show confirmation dialog
                                    final bool? confirmLogout = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: const Color(0xFF2A2A2A),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                                          title: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF5030E8).withOpacity(0.15),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.logout_rounded,
                                                  color: Color(0xFF5030E8),
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
                                                        backgroundColor: const Color(0xFF5030E8),
                                                        foregroundColor: Colors.white,
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
                                      setState(() {
                                        _isLoggingOut = true;
                                      });
                                      
                                      try {
                                        // Call logout API
                                        final result = await _userService.logout();
                                        
                                        // Navigate to login screen and clear all previous routes
                                        Navigator.of(context).pushNamedAndRemoveUntil(
                                          '/login',
                                          (route) => false, // This removes all previous routes
                                        );
                                      } catch (e) {
                                        setState(() {
                                          _isLoggingOut = false;
                                        });
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Failed to logout. Please try again.')),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.logout_rounded),
                                  label: const Text(
                                    'LOGOUT',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
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

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red[300],
          size: 60,
        ),
        const SizedBox(height: 20),
        Text(
          _errorMessage,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5030E8),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: _loadUserProfile,
          child: const Text(
            'Try Again',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  String _formatVerificationStatus(String? status) {
    if (status == null) return 'Not available';
    
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Verification';
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Verification Rejected';
      default:
        return status;
    }
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