import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';
import 'winner_screen.dart';
import 'home_screen.dart';
import 'dart:math';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Create placeholder screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const WinnerScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B1D3A), // Navy Blue background
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.2), // Gold shadow
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavBarItem(
                icon: Icons.home,
                label: 'Home',
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              NavBarItem(
                icon: Icons.emoji_events,
                label: 'Winner',
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              NavBarItem(
                icon: Icons.account_balance_wallet,
                label: 'Wallet',
                isSelected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              NavBarItem(
                icon: Icons.person,
                label: 'Profile',
                isSelected: _selectedIndex == 3,
                profileImage: _selectedIndex == 3 ? 'assets/images/profile_pic.png' : null,
                onTap: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? profileImage;
  final VoidCallback onTap;

  const NavBarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    this.profileImage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFFFFD700); // Gold for selected
    final unselectedColor = Colors.white54; // Light white for unselected
    
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          profileImage != null && isSelected
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(profileImage!),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: selectedColor, width: 2),
                ),
              )
            : Icon(
                icon,
                color: isSelected ? selectedColor : unselectedColor,
              ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }
} 