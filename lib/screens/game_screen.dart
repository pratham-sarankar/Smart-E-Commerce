import 'package:flutter/material.dart';
import 'package:smart_eommerce/screens/scratch_card_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late VideoPlayerController _videoController;
  Razorpay? _razorpay;
  late int amount;
  late String clubName;

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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Navigate to Scratch Card Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScratchCardScreen(
          amount: amount, 
          clubName: clubName,
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getClubName(int? amount) {
    if (amount == 100) return 'Silver Club';
    if (amount == 500) return 'Gold Club';
    if (amount == 1000) return 'Platinum Club';
    return 'Club';
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
                  _initiatePayment(amount, clubName, tagline, selectedNumber);
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
          onTap: () => _showNumberSelectionDialog(clubName, amount, tagline),
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
                    const Text(
                      'Select Number & Play',
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