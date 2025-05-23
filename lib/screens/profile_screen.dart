import 'package:flutter/material.dart';
import 'package:smart_eommerce/models/user_model.dart';
import 'package:smart_eommerce/screens/main_screen.dart';
import 'package:smart_eommerce/screens/scratch_card_screen.dart';
import 'package:smart_eommerce/services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  
  // Add these variables for tracking changes
  bool _hasChanges = false;
  String? _newName;
  String? _newDob;
  File? _newProfileImage;

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

  void _navigateToScratchCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScratchCardScreen(),
      ),
    );
  }

  // Add this method to handle profile updates
  Future<void> _updateProfile() async {
    if (!_hasChanges) {
      print('No changes detected, skipping update');
      return;
    }

    print('Starting profile update...');
    print('Changes detected:');
    if (_newName != null) print('- New name: $_newName');
    if (_newDob != null) print('- New DOB: $_newDob');
    if (_newProfileImage != null) print('- New profile image: ${_newProfileImage!.path}');

    setState(() {
      _isLoading = true;
    });

    try {
      final formData = {
        if (_newName != null) 'fullname': _newName,
        if (_newDob != null) 'dob': _newDob,
      };

      print('Sending update request with form data: $formData');
      final result = await _userService.updateProfile(
        formData: formData,
        profileImage: _newProfileImage,
      );

      print('Update API response: $result');

      if (result['success']) {
        print('Profile update successful');
        // Clear the changes
        setState(() {
          _hasChanges = false;
          _newName = null;
          _newDob = null;
          _newProfileImage = null;
        });
        
        // Reload the user profile to get fresh data
        print('Reloading user profile...');
        await _loadUserProfile();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully', style: TextStyle(color: Colors.white),), ),
        );
      } else {
        print('Profile update failed: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to update profile')),
        );
      }
    } catch (e) {
      print('Error during profile update: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while updating profile')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editName() {
    print('Opening name edit dialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController(text: _userProfile?.fullname);
        return AlertDialog(
          backgroundColor: const Color(0xFF1E3A70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              width: 1,
            ),
          ),
          title: const Text(
            'Edit Name',
            style: TextStyle(color: Color(0xFFFFD700)),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFD700)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('Name edit cancelled');
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF0B1D3A),
              ),
              onPressed: () {
                final newName = nameController.text.trim();
                print('New name entered: $newName');
                if (newName.isNotEmpty && newName != _userProfile?.fullname) {
                  print('Name changed from ${_userProfile?.fullname} to $newName');
                  setState(() {
                    _newName = newName;
                    _hasChanges = true;
                  });
                } else {
                  print('No name change detected');
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editDOB() {
    print('Opening DOB edit dialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E3A70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              width: 1,
            ),
          ),
          title: const Text(
            'Select Date of Birth',
            style: TextStyle(color: Color(0xFFFFD700)),
          ),
          content: SizedBox(
            height: 300,
            child: CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onDateChanged: (DateTime date) {
                final newDob = date.toString().split(' ')[0];
                print('New DOB selected: $newDob');
                if (newDob != _userProfile?.dob) {
                  print('DOB changed from ${_userProfile?.dob} to $newDob');
                  setState(() {
                    _newDob = newDob;
                    _hasChanges = true;
                  });
                } else {
                  print('No DOB change detected');
                }
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateProfileImage() async {
    print('Opening profile image update dialog');
    final ImagePicker picker = ImagePicker();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E3A70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              width: 1,
            ),
          ),
          title: const Text(
            'Update Profile Picture',
            style: TextStyle(color: Color(0xFFFFD700)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFFFD700)),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  print('Camera option selected');
                  Navigator.pop(context);
                  try {
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      print('Image captured from camera: ${image.path}');
                      setState(() {
                        _newProfileImage = File(image.path);
                        _hasChanges = true;
                      });
                    } else {
                      print('No image selected from camera');
                    }
                  } catch (e) {
                    print('Error capturing image: $e');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFFFD700)),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  print('Gallery option selected');
                  Navigator.pop(context);
                  try {
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      print('Image selected from gallery: ${image.path}');
                      setState(() {
                        _newProfileImage = File(image.path);
                        _hasChanges = true;
                      });
                    } else {
                      print('No image selected from gallery');
                    }
                  } catch (e) {
                    print('Error selecting image from gallery: $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
                              image: _newProfileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_newProfileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : _userProfile?.profileImage != null
                                      ? DecorationImage(
                                          image: NetworkImage(_userProfile!.profileImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage('assets/images/profile_pic.png'),
                                          fit: BoxFit.cover,
                                        ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Profile',
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
                                if (_hasChanges)
                                  TextButton.icon(
                                    onPressed: _isLoading ? null : _updateProfile,
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFD700),
                                      foregroundColor: const Color(0xFF0B1D3A),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B1D3A)),
                                            ),
                                          )
                                        : const Icon(Icons.save, size: 16),
                                    label: Text(
                                      _isLoading ? 'Saving...' : 'Save',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
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
            ],
          ),
          
          // Content
          Column(
            children: [
              // Spacer for the app bar area
              const SizedBox(height: 100),
              
              // Avatar section
              Expanded(
                child: Center(
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                    : _errorMessage.isNotEmpty
                      ? _buildErrorView()
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  GestureDetector(
                                    onTap: _updateProfileImage,
                                    child: Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFFFD700), width: 3),
                                        image: _newProfileImage != null
                                            ? DecorationImage(
                                                image: FileImage(_newProfileImage!),
                                                fit: BoxFit.cover,
                                              )
                                            : _userProfile?.profileImage != null
                                                ? DecorationImage(
                                                    image: NetworkImage(_userProfile!.profileImage!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : const DecorationImage(
                                                    image: AssetImage('assets/images/profile_pic.png'),
                                                    fit: BoxFit.cover,
                                                  ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3A70),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, color: Color(0xFFFFD700), size: 20),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Profile details
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 30),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A70).withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Name section
                                      ProfileInfoItem(
                                        icon: Icons.person,
                                        iconColor: const Color(0xFFFFD700),
                                        title: 'Name',
                                        value: _userProfile?.fullname ?? 'Not available',
                                        isEditable: true,
                                        onTap: _editName,
                                      ),
                                      
                                      // DOB section
                                      ProfileInfoItem(
                                        icon: Icons.info,
                                        iconColor: const Color(0xFFFFD700),
                                        title: 'DOB',
                                        value: _userProfile?.dob ?? 'Not available',
                                        isEditable: true,
                                        onTap: _editDOB,
                                      ),
                                      
                                      // Email section
                                      ProfileInfoItem(
                                        icon: Icons.email,
                                        iconColor: const Color(0xFFFFD700),
                                        title: 'Email',
                                        value: _userProfile?.email ?? 'Not available',
                                      ),

                                      // Scratch Card section
                                      ProfileInfoItem(
                                        icon: Icons.card_giftcard,
                                        iconColor: const Color(0xFFFFD700),
                                        title: 'Scratch Card',
                                        value: 'Check your rewards',
                                        onTap: _navigateToScratchCard,
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
                                    backgroundColor: const Color(0xFFFFD700),
                                    foregroundColor: const Color(0xFF0B1D3A),
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
                                          backgroundColor: const Color(0xFF1E3A70),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                            side: BorderSide(
                                              color: const Color(0xFFFFD700).withOpacity(0.3),
                                              width: 1,
                                            ),
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
                                                  color: Color(0xFFFFD700),
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
                                                          side: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
                                                        ),
                                                      ),
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: const Text(
                                                        'CANCEL',
                                                        style: TextStyle(
                                                          color: Colors.white54,
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
          color: const Color(0xFFFFD700),
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
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: const Color(0xFF0B1D3A),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: _loadUserProfile,
          child: const Text(
            'Try Again',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final bool isEditable;

  const ProfileInfoItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
    this.isEditable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
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
            if (isEditable)
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: const Color(0xFFFFD700),
                  size: 20,
                ),
                onPressed: onTap,
              ),
            if (onTap != null && !isEditable)
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }
} 