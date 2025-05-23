import 'package:flutter/material.dart';
import 'package:smart_eommerce/screens/game_screen.dart';
import 'package:smart_eommerce/screens/settings_screen.dart';
import 'package:smart_eommerce/widgets/game_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_eommerce/services/user_service.dart';
import 'package:smart_eommerce/models/user_model.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:smart_eommerce/services/wallet_service.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _showBalance = true;
  late TabController _tabController;
  String _userName = 'User';
  final UserService _userService = UserService();
  final WalletService _walletService = WalletService();
  UserModel? _userProfile;
  Razorpay? _razorpay;
  bool _isLoading = false;
  double _availableBalance = 0.0;
  double _totalWinnings = 0.0;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  List<dynamic> _todaysDrawEntries = [];
  double _totalDrawAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
    _loadWalletData();
    _initializeRazorpay();
    _fetchTodaysDraw();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar( backgroundColor: Colors.black, content: Text('Thank you for your donation!', style: TextStyle(color: Colors.white))));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: ${response.walletName}')),
    );
  }

  Future<void> _handleDonation() async {
    try {
      setState(() => _isLoading = true);
      
      // Initialize Razorpay payment
      var options = {
        'key': 'rzp_test_NMHJrIP0HgARfE',
        'amount': 100, // Amount in smallest currency unit (paise)
        'name': 'Smart E-commerce',
        'description': '1 Rupee Donation',
        'prefill': {
          'contact': '',
          'email': '',
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay!.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await _userService.getUserProfile();
      
      if (result['success']) {
        setState(() {
          _userProfile = result['user'];
          _userName = _userProfile?.fullname ?? 'User';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _loadWalletData() async {
    try {
      final walletData = await _walletService.getMyWallet();
      if (walletData['success'] == true) {
        setState(() {
          final balance = walletData['wallet']?['balance'];
          _availableBalance = balance is num ? balance.toDouble() : 0.0;
        });
      }
      
      // Fetch total winning amount
      final response = await http.get(
        Uri.parse('https://4sr8mplp-3035.inc1.devtunnels.ms/api/user/total-wining'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalWinnings = (data['totalWinningAmount'] as num).toDouble();
        });
      }
    } catch (e) {
      print('Error loading wallet data: $e');
    }
  }

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> _fetchTodaysDraw() async {
    try {
      final response = await http.get(
        Uri.parse('https://4sr8mplp-3035.inc1.devtunnels.ms/api/user/todays-draw'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['entry'] != null) {
          setState(() {
            _todaysDrawEntries = data['entry']['entries'] ?? [];
            _totalDrawAmount = (data['entry']['totalAmount'] as num?)?.toDouble() ?? 0.0;
          });
        }
      } else {
        print('Failed to fetch today\'s draw: ${response.body}');
      }
    } catch (e) {
      print('Error fetching today\'s draw: $e');
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D3A), // Navy Blue background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            // Logo container with icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFFD700), // Gold background
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/icon/icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Lakhpati Club',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(1, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Settings button with circular border
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD700).withOpacity(0.2),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1),
            ),
            child: Material( // Wrap with Material for ripple effect
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                splashColor: const Color(0xFFFFD700).withOpacity(0.3),
                highlightColor: const Color(0xFFFFD700).withOpacity(0.1),
                onTap: () {
                  Navigator.push(
                    context,
                    FadePageRoute(page: SettingsScreen()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.settings,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background wave image
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/home_wave.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFFFD700).withOpacity(0.1), // Tint the wave with gold
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFFFFD700),
              backgroundColor: const Color(0xFF1E3A70),
              onRefresh: () async {
                await _loadUserProfile();
                await _loadWalletData();
                await _fetchTodaysDraw();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Top section with padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Greeting section
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFD700),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: _userProfile?.profileImage != null
                                    ? Image.network(
                                        _userProfile!.profileImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/profile_pic.png',
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/profile_pic.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _getGreeting(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Balance Tabs
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A70).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: TabBar(
                                  dividerColor: Colors.transparent,
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    color: const Color(0xFFFFD700).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  indicatorColor: Colors.transparent,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.white54,
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                  tabs: [
                                    Tab(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Available Balance',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Total Winning Price',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Balance amount
                              SizedBox(
                                height: 140,
                                child: TabBarView(
                                  clipBehavior: Clip.none,
                                  controller: _tabController,
                                  children: [
                                    // Available Balance Tab
                                    BalanceDisplay(
                                      amount: _currencyFormat.format(_availableBalance),
                                      isVisible: _showBalance,
                                      onToggle: () {
                                        setState(() {
                                          _showBalance = !_showBalance;
                                        });
                                      },
                                    ),
                                    // Total Winning Price Tab
                                    BalanceDisplay(
                                      amount: _currencyFormat.format(_totalWinnings),
                                      isVisible: _showBalance,
                                      onToggle: () {
                                        setState(() {
                                          _showBalance = !_showBalance;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Today's Draw Section
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: const Color(0xFFFFD700),
                                width: 4,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Today\'s Draw Entries',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Today's Draw Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A70),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with total amount
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B1D3A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Total Draw Amount',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _currencyFormat.format(_totalDrawAmount),
                                          style: const TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFFFD700).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '${_todaysDrawEntries.length} Entries',
                                        style: const TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Entries List
                              if (_todaysDrawEntries.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Text(
                                      'No entries for today\'s draw',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _todaysDrawEntries.length,
                                  separatorBuilder: (context, index) => Divider(
                                    color: Colors.white.withOpacity(0.1),
                                    height: 16,
                                  ),
                                  itemBuilder: (context, index) {
                                    final entry = _todaysDrawEntries[index];
                                    final ticket = entry['participationTicket'];
                                    final isWinner = ticket['isWinner'] ?? false;
                                    
                                    return Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isWinner ? Colors.green.withOpacity(0.1) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          // Plan
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Plan ${ticket['plan']}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          // Lucky Number
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFD700).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: const Color(0xFFFFD700).withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                'Lucky #${ticket['luckyNumber']}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color(0xFFFFD700),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Amount
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              _currencyFormat.format(ticket['amount']),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: isWinner ? Colors.green : Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        
                        // Play Now Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const GameScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A70), // Dark blue color
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFFFD700), width: 1),
                              ),
                              elevation: 5,
                              shadowColor: Colors.white.withOpacity(0.3),
                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                Icon(Icons.play_circle_fill, color: Color(0xFFFFD700), size: 24),
                                                SizedBox(width: 8),
                                                Text(
                                  'Play Now',
                                                  style: TextStyle(
                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
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
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    
    return '$greeting,\n$_userName';
  }
}

class PaymentMethodCard extends StatelessWidget {
  final String cardType;
  final String lastFourDigits;

  const PaymentMethodCard({
    Key? key,
    required this.cardType,
    required this.lastFourDigits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cardType == 'mastercard' ? Colors.red : Colors.blue,
              shape: BoxShape.circle,
            ),
            height: 24,
            width: 24,
            child: cardType == 'mastercard'
                ? Icon(Icons.credit_card, color: Colors.white, size: 16)
                : Text(
                    'V',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Text(
            '**** $lastFourDigits',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;

  const TransactionItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class BalanceDisplay extends StatelessWidget {
  final String amount;
  final bool isVisible;
  final VoidCallback onToggle;

  const BalanceDisplay({
    Key? key,
    required this.amount,
    required this.isVisible,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split the amount into whole and decimal parts
    final parts = amount.split('.');
    final wholePart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A70).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show either the actual price or asterisks based on isVisible
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isVisible ? wholePart : '****',
                style: TextStyle(
                  color: const Color(0xFFFFD700),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              if (isVisible)
                Text(
                  '.$decimalPart',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          // Eye icon with "Show/Hide" text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: OutlinedButton.icon(
              key: ValueKey(isVisible),
              onPressed: onToggle,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFFFFD700),
                  size: 20,
                  key: ValueKey(isVisible),
                ),
              ),
              label: Text(
                isVisible ? 'Hide Balance' : 'Show Balance',
                style: TextStyle(
                  color: const Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                side: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add a new custom page route for smooth transitions
class FadePageRoute extends PageRouteBuilder {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
} 