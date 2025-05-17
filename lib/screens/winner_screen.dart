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
  List<WinnerData> _pastWinners = [];
  bool _isLoading = true;
  Razorpay? _razorpay;
  bool _isDonationLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _fetchTodayWinner();
    _fetchPastWinners();
    _initializeRazorpay();
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
      final response = await _winnerService.getTodayWinner();
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
      final response = await _winnerService.getPastWinners();
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

  Future<void> _handleInviteFromContacts() async {
    try {
      // Request contacts permission
      final status = await Permission.contacts.request();
      
      if (status.isGranted) {
        // Get all contacts
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        );
        
        if (!mounted) return;

        // Show contact picker dialog
        final selectedContact = await showDialog<Contact>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                'Select Contact',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      leading: contact.photo != null
                          ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
                          : CircleAvatar(
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission denied')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
      backgroundColor: const Color(0xFF0B1D3A), // Navy Blue background
      body: SafeArea(
        child: Column(
          children: [
            // App bar section as Stack with line behind transparent app bar
            Container(
              height: 56, // Standard app bar height
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/appbar_line.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      color: const Color(0xFFFFD700).withOpacity(0.2), // Gold tint
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
            
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    )
                  : SingleChildScrollView(
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
                          
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            color: _winnerResponse?.data != null 
                              ? const Color(0xFF1E3A70) 
                              : const Color(0xFF1E3A70).withOpacity(0.5),
                            child: Text(
                              _winnerResponse?.message ?? 'Loading...',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
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
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                              padding: const EdgeInsets.all(20.0),
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
                            ..._pastWinners.map((winner) => _buildPastWinnerItem(
                              'assets/images/avatar.png',
                              winner.name,
                              winner.location,
                              winner.amount,
                            )).toList(),
                          
                          const SizedBox(height: 24),
                          
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
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
                                
                                const SizedBox(height: 16),
                                
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _isDonationLoading ? null : _handleDonation,
                                    icon: _isDonationLoading 
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                                          ),
                                        )
                                      : const Icon(Icons.favorite_border),
                                    label: Text(_isDonationLoading ? 'Processing...' : 'Donate 1 rupee'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFFFD700),
                                      side: const BorderSide(color: Color(0xFFFFD700)),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      splashFactory: InkRipple.splashFactory,
                                      elevation: 2,
                                      animationDuration: const Duration(milliseconds: 300),
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
      ),
    );
  }

  Widget _buildPastWinnerItem(String imagePath, String name, String location, String amount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD700).withOpacity(0.2),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5030E8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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