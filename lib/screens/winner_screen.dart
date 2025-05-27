import 'package:flutter/material.dart';
import 'package:smart_eommerce/screens/main_screen.dart';
import 'package:smart_eommerce/models/winner_model.dart';
import 'package:smart_eommerce/services/winner_service.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class WinnerScreen extends StatefulWidget {
  const WinnerScreen({Key? key}) : super(key: key);

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final WinnerService _winnerService = WinnerService();
  WinnerResponse? _winnerResponse;
  List<PastWinnerData> _pastWinners = [];
  bool _isLoading = true;
  Razorpay? _razorpay;
  bool _isDonationLoading = false;
  String _selectedPlan = 'silver'; // Default to silver

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _initializeRazorpay();
    _fetchTodayWinner();
    _fetchPastWinners();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your donation!')),
    );
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
      setState(() => _isDonationLoading = true);
      
      // Initialize Razorpay payment
      var options = {
        'key': 'rzp_test_NMHJrIP0HgARfE',
        'amount': 100, 
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
      setState(() => _isDonationLoading = false);
    }
  }

  Future<void> _fetchTodayWinner() async {
    try {
      setState(() => _isLoading = true);
      final response = await _winnerService.getTodayWinner(plan: _selectedPlan);
      if (mounted) {
        setState(() {
          _winnerResponse = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _fetchPastWinners() async {
    try {
      final response = await _winnerService.getPastWinners(plan: _selectedPlan);
      if (mounted) {
        setState(() {
          _pastWinners = response.pastWinners;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading past winners: $e')),
        );
      }
    }
  }

  Widget _buildPlanTab(String plan, String label) {
    final isSelected = _selectedPlan == plan;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedPlan = plan;
            _isLoading = true;
          });
          _fetchTodayWinner();
          _fetchPastWinners();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD700),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0B1D3A) : const Color(0xFFFFD700),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _razorpay?.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D3A),
      body: SafeArea(
        child: Column(
          children: [
            // App bar section
            Container(
              height: 56,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/appbar_line.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                    ),
                  ),
                  
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                    context, 
                                    FadePageRoute(page: MainScreen()), 
                                    (route) => false
                                  );
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFFFFD700),
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Daily Winner',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 18,
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

            // Plan selection tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPlanTab('gold', 'Gold'),
                  _buildPlanTab('silver', 'Silver'),
                  _buildPlanTab('diamond', 'Diamond'),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    )
                  : SingleChildScrollView(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 280,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0B1D3A),
                                      image: DecorationImage(
                                        image: AssetImage('assets/images/winners.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                    child: const Text(
                                      'Today Winner',
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  
                                  if (_winnerResponse?.data != null) ...[
                                    _buildWinnerCard(
                                      _winnerResponse!.data!.firstWinner,
                                      'First Winner',
                                      const Color(0xFFFFD700),
                                    ),
                                    _buildWinnerCard(
                                      _winnerResponse!.data!.secondWinner,
                                      'Second Winner',
                                      const Color(0xFFC0C0C0),
                                    ),
                                    _buildWinnerCard(
                                      _winnerResponse!.data!.thirdWinner,
                                      'Third Winner',
                                      const Color(0xFFCD7F32),
                                    ),
                                  ] else
                                    Container(
                                      margin: const EdgeInsets.all(24),
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E3A70),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Text(
                                        'No winners announced yet. Check back later!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                                    child: Text(
                                      _winnerResponse?.data != null 
                                        ? 'Congratulations to our winner!'
                                        : 'Check back later to see who won today\'s draw!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),

                                  // Countdown timer
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: CircularCountdownTimer(
                                      targetTime: DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day,
                                        20,
                                        0,
                                        0,
                                      ),
                                    ),
                                  ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                                    child: const Text(
                                      'Past Winners',
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  
                                  if (_pastWinners.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        'No past winners yet',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  else
                                    ..._pastWinners.map((winner) => _buildPastWinnerItem(winner)).toList(),
                                  
                                  const SizedBox(height: 24),
                                  
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: _handleInviteFromContacts,
                                            icon: const Icon(Icons.people_alt_outlined),
                                            label: const Text('Invite from Contacts'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFFFD700),
                                              foregroundColor: const Color(0xFF0B1D3A),
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              elevation: 3,
                                              splashFactory: InkRipple.splashFactory,
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
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerCard(WinnerInfo winner, String position, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              position,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    winner.user.fullname[0].toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      winner.user.fullname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ticket: ${winner.ticket}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₹${winner.winningAmount}',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastWinnerItem(PastWinnerData winner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  winner.plan.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(winner.date),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWinnerRow(winner.firstWinner, 'First', const Color(0xFFFFD700)),
          const SizedBox(height: 8),
          _buildWinnerRow(winner.secondWinner, 'Second', const Color(0xFFC0C0C0)),
          const SizedBox(height: 8),
          _buildWinnerRow(winner.thirdWinner, 'Third', const Color(0xFFCD7F32)),
        ],
      ),
    );
  }

  Widget _buildWinnerRow(UserInfo user, String position, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
          ),
          child: Center(
            child: Text(
              user.fullname[0].toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                position,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.fullname,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleInviteFromContacts() async {
    try {
      // Show loading indicator immediately
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          );
        },
      );

      // Request contacts permission
      final status = await Permission.contacts.request();
      
      if (status.isGranted) {
        // Get contacts with limited properties for faster loading
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false, // Don't load photos initially for faster loading
        );
        
        if (!mounted) return;
        
        // Close loading dialog
        Navigator.of(context).pop();

        // Show contact picker dialog with search
        final selectedContact = await showDialog<Contact>(
          context: context,
          builder: (BuildContext context) {
            return _ContactSearchDialog(contacts: contacts);
          },
        );

        if (selectedContact != null) {
          // Get the first phone number or email
          String? contactInfo;
          if (selectedContact.phones.isNotEmpty) {
            contactInfo = selectedContact.phones.first.number;
          } else if (selectedContact.emails.isNotEmpty) {
            contactInfo = selectedContact.emails.first.address;
          }

          if (contactInfo != null) {
            // Share the app with the selected contact
            await Share.share(
              'Join me on Lakhpati! Download the app and start winning big prizes!',
              subject: 'Join Lakhpati App',
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No contact information found')),
            );
          }
        }
      } else {
        if (!mounted) return;
        // Close loading dialog
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission denied')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Close loading dialog if it's open
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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

// Add a custom page route for smooth transitions
class FadePageRoute extends PageRouteBuilder {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}

// Add this new widget before the FadePageRoute class
class CircularCountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  final VoidCallback? onCountdownComplete;

  const CircularCountdownTimer({
    Key? key, 
    required this.targetTime, 
    this.onCountdownComplete
  }) : super(key: key);

  @override
  _CircularCountdownTimerState createState() => _CircularCountdownTimerState();
}

class _CircularCountdownTimerState extends State<CircularCountdownTimer> {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;
  bool _isCountdownComplete = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        _remainingTime = widget.targetTime.difference(now);
        
        // Check if countdown is complete
        if (_remainingTime.isNegative) {
          _remainingTime = Duration.zero;
          _isCountdownComplete = true;
          timer.cancel(); // Stop the timer
          
          // Call the optional callback
          widget.onCountdownComplete?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the target time is for today at 8 PM
    final targetTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      20, // 8 PM
      0,
      0
    );

    final totalSeconds = 24 * 60 * 60; // Total seconds in a day
    final remainingSeconds = _remainingTime.inSeconds > totalSeconds 
        ? totalSeconds 
        : _remainingTime.inSeconds;
    final progress = 1 - (remainingSeconds / totalSeconds);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.5),
          width: 8,
        ),
        gradient: RadialGradient(
          colors: [
            const Color(0xFF1E3A70),
            const Color(0xFF0B1D3A),
          ],
          stops: const [0.3, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Circular progress indicator
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFFFFD700).withOpacity(0.5),
            ),
            strokeWidth: 8,
          ),
          // Timer text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isCountdownComplete 
                    ? 'Draw Time!' 
                    : '${_remainingTime.inHours.toString().padLeft(2, '0')}:'
                      '${(_remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:'
                      '${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isCountdownComplete ? 'Completed' : 'Draw at 8 PM',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add this new widget class for the contact search dialog
class _ContactSearchDialog extends StatefulWidget {
  final List<Contact> contacts;

  const _ContactSearchDialog({
    Key? key,
    required this.contacts,
  }) : super(key: key);

  @override
  State<_ContactSearchDialog> createState() => _ContactSearchDialogState();
}

class _ContactSearchDialogState extends State<_ContactSearchDialog> {
  late List<Contact> filteredContacts;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredContacts = List.from(widget.contacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredContacts = List.from(widget.contacts);
      } else {
        filteredContacts = widget.contacts
            .where((contact) =>
                contact.displayName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Column(
        children: [
          const Text(
            'Select Contact',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _filterContacts,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: filteredContacts.isEmpty
            ? Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'No contacts found'
                      : 'No contacts match your search',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF5030E8),
                      child: Text(
                        contact.displayName.isNotEmpty 
                            ? contact.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.of(context).pop(contact),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
} 