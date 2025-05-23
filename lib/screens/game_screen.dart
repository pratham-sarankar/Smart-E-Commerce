import 'package:flutter/material.dart';
import 'package:smart_eommerce/screens/scratch_card_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:smart_eommerce/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late VideoPlayerController _videoController;
  Razorpay? _razorpay;
  bool _isLoading = false;
  final UserService _userService = UserService();

  // Variables to store current club details
  late int amount;
  late String clubName;
  late int selectedNumber;

  @override
  void initState() {
    super.initState();
    // Initialize video controller with an online video
    _videoController = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', // Example video URL
    )..initialize().then((_) {
      setState(() {});
      _videoController.play();
      _videoController.setLooping(true);
    }).catchError((error) {
      // Handle video loading error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading video: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  Future<void> _createDrawOrder(int amount, String clubName, String tagline, int selectedNumber) async {
    setState(() {
      _isLoading = true;
      // Store the selected number as a class-level variable
      this.selectedNumber = selectedNumber;
    });

    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Validate token
      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token is missing. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create order API call
      final response = await http.post(
        Uri.parse('https://4sr8mplp-3035.inc1.devtunnels.ms/api/draw/create-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount.toString(), // Send as string
          'luckyNumber': selectedNumber.toString(), // Send as string with key 'luckyNumber'
        }),
      );

      // Log the request details for debugging
      print('Request URL: https://4sr8mplp-3035.inc1.devtunnels.ms/api/draw/create-order');
      print('Request Headers: ${{'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}}');
      print('Request Body: ${jsonEncode({'amount': amount.toString(), 'luckyNumber': selectedNumber.toString()})}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (responseData['success']) {
        // Proceed with Razorpay payment
        _initiateRazorpayPayment(
          responseData['orderId'], 
          amount, 
          clubName, 
          tagline,
          selectedNumber
        );
      } else {
        // Handle order creation failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Failed to create order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Log the error for debugging
      print('Error creating order: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initiateRazorpayPayment(String orderId, int amount, String clubName, String tagline, int selectedNumber) {
    var options = {
      'key': 'rzp_test_NMHJrIP0HgARfE',
      'amount': amount * 100, // Amount in smallest currency unit (paise)
      'name': 'Lakhpati Club',
      'description': '$clubName - Number $selectedNumber',
      'order_id': orderId,
      'prefill': {
        'contact': '',
        'email': '',
      },
      'notes': {
        'club': clubName,
        'tagline': tagline,
        'selected_number': selectedNumber,
      }
    };

    _razorpay!.open(options);
  }

  Future<void> _verifyPayment(PaymentSuccessResponse response) async {
    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Verify payment API call
      final verifyResponse = await http.post(
        Uri.parse('https://4sr8mplp-3035.inc1.devtunnels.ms/api/draw/payment-verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'razorpay_payment_id': response.paymentId,
          'razorpay_order_id': response.orderId,
          'razorpay_signature': response.signature,
          // 'amount': amount.toString(), // Use the amount from class variable
          // 'luckyNumber': selectedNumber.toString(), // Use the selected number from class variable
        }),
      );

      final verifyData = json.decode(verifyResponse.body);

      if (verifyData['success']) {
        // Show success message instead of navigating to scratch card
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verifyData['message'] ?? 'Payment verification failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _verifyPayment(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showNumberSelectionDialog(String clubName, int amount, String tagline) {
    final TextEditingController numberController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E3A70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: const Color(0xFFFFD700), width: 2),
          ),
          title: Text(
            'Select Your Number',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$clubName - ₹$amount Entry',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'Enter a number',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFFFFD700), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFFFFD700), width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF0B1D3A),
              ),
              onPressed: () {
                final selectedNumber = int.tryParse(numberController.text);
                if (selectedNumber != null && selectedNumber >= 1 && selectedNumber <= 100) {
                  Navigator.of(context).pop();
                  // Create draw order with the selected number
                  _createDrawOrder(amount, clubName, tagline, selectedNumber);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid number between 1 and 100'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _initiatePayment(int paymentAmount, String selectedClubName, String tagline, int selectedNumber) {
    // Store amount and club name as class variables
    amount = paymentAmount;
    clubName = selectedClubName;

    var options = {
      'key': 'rzp_test_NMHJrIP0HgARfE',
      'amount': paymentAmount * 100, // Amount in smallest currency unit (paise)
      'name': 'Lakhpati Club',
      'description': '$selectedClubName - Number $selectedNumber',
      'prefill': {
        'contact': '',
        'email': '',
      },
      'notes': {
        'club': selectedClubName,
        'tagline': tagline,
        'selected_number': selectedNumber,
      }
    };

    _razorpay!.open(options);
  }

  @override
  void dispose() {
    _videoController.dispose();
    _razorpay?.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D3A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Lakhpati Club Games',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                color: const Color(0xFFFFD700).withOpacity(0.1),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Video Player Section
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _videoController.value.isInitialized
                          ? VideoPlayer(_videoController)
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFD700),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Club Tiers Section
                const Text(
                  'Club Tiers',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Silver Club Tier
                _buildClubTierCard(
                  clubName: 'Silver Club',
                  amount: 1,
                  tagline: 'Chhoti Suruaat, Badi Jeet!',
                  backgroundColor: Colors.grey.shade700,
                  iconColor: Colors.white,
                ),
                const SizedBox(height: 16),

                // Gold Club Tier
                _buildClubTierCard(
                  clubName: 'Gold Club',
                  amount: 5,
                  tagline: 'Zyada Yogdaan, Zyada Mauka!',
                  backgroundColor: Colors.amber.shade700,
                  iconColor: Colors.white,
                ),
                const SizedBox(height: 16),

                // Platinum Club Tier
                _buildClubTierCard(
                  clubName: 'Platinum Club',
                  amount: 10,
                  tagline: 'Top Club for Top Winners!',
                  backgroundColor: Colors.deepPurple.shade700,
                  iconColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubTierCard({
    required String clubName,
    required int amount,
    required String tagline,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading 
            ? null 
            : () {
                // Store current club details
                this.amount = amount;
                this.clubName = clubName;
                
                // Show number selection dialog first
                _showNumberSelectionDialog(clubName, amount, tagline);
              },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      clubName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.stars,
                      color: iconColor,
                      size: 30,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tagline,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹$amount Entry',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                          ),
                        )
                      : const Text(
                          'Tap to Join',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 