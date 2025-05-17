import 'package:flutter/material.dart';
import 'package:smart_eommerce/models/user_model.dart';
import 'package:smart_eommerce/services/user_service.dart';
import 'package:smart_eommerce/screens/main_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  UserModel? _userProfile;
  String _errorMessage = '';

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
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MainScreen()),
                                  (route) => false,
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
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
                                  'User Information',
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
              const SizedBox(height: 170),
              Expanded(
                child: _isLoading 
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFD700),
                        strokeWidth: 3,
                      ),
                    )
                  : _errorMessage.isNotEmpty
                    ? _buildErrorView()
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Basic Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              
                              _buildInfoItem(
                                icon: Icons.person,
                                iconColor: const Color(0xFFFFD700),
                                title: 'Full Name',
                                subtitle: _userProfile?.fullname ?? 'Not available',
                              ),
                              
                              _buildInfoItem(
                                icon: Icons.email,
                                iconColor: const Color(0xFFFFD700),
                                title: 'Email',
                                subtitle: _userProfile?.email ?? 'Not available',
                              ),
                              
                              _buildInfoItem(
                                icon: Icons.calendar_today,
                                iconColor: const Color(0xFFFFD700),
                                title: 'Date of Birth',
                                subtitle: _userProfile?.dob ?? 'Not available',
                              ),
                              
                              _buildInfoItem(
                                icon: Icons.verified_user,
                                iconColor: const Color(0xFFFFD700),
                                title: 'Verification Status',
                                subtitle: _formatVerificationStatus(_userProfile?.isVerified),
                              ),
                              
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'KYC Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              
                              _buildInfoItem(
                                icon: Icons.account_balance,
                                iconColor: const Color(0xFFFFD700),
                                title: 'Bank Name',
                                subtitle: _userProfile?.userKyc?.bankName ?? 'Not available',
                              ),
                              
                              _buildInfoItem(
                                icon: Icons.account_balance_wallet,
                                iconColor: const Color(0xFFFFD700),
                                title: 'Account Number',
                                subtitle: _userProfile?.userKyc?.bankAccountNumber ?? 'Not available',
                              ),
                              
                              _buildInfoItem(
                                icon: Icons.business,
                                iconColor: const Color(0xFFFFD700),
                                title: 'Branch Name',
                                subtitle: _userProfile?.userKyc?.branchName ?? 'Not available',
                              ),
                              
                              _buildInfoItem(
                                icon: Icons.numbers,
                                iconColor: const Color(0xFFFFD700),
                                title: 'IFSC Code',
                                subtitle: _userProfile?.userKyc?.ifscCode ?? 'Not available',
                              ),
                              
                              _buildInfoItem(
                                icon: Icons.badge,
                                iconColor: const Color(0xFFFFD700),
                                title: 'KYC Document Number',
                                subtitle: _userProfile?.userKyc?.kycDocumentNumber ?? 'Not available',
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

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
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
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: const Color(0xFFFFD700),
                size: 64,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF0B1D3A),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _loadUserProfile,
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Color(0xFF0B1D3A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
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