import 'package:flutter/material.dart';
import 'package:smart_eommerce/screens/main_screen.dart';
import '../services/wallet_service.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();
  Razorpay? _razorpay;
  bool _isLoading = false;
  double _balance = 0.0;
  final List<Map<String, dynamic>> _transactions = [];
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    try {
      final walletData = await _walletService.getMyWallet();
      if (walletData['success'] == true) {
        setState(() {
          _balance = (walletData['wallet']['balance'] ?? 0).toDouble();
          // Add transactions from the wallet data if available
          if (walletData['wallet']['transactions'] != null) {
            _transactions.clear();
            _transactions.addAll(
              (walletData['wallet']['transactions'] as List).map((t) => {
                'amount': t['amount'] ?? 0.0,
                'type': t['type'] ?? 'Deposit',
                'created_at': t['createdAt'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
              }).toList(),
            );
          }
        });
      }
    } catch (e) {
      if (e.toString().contains('Unauthorized') || 
          e.toString().contains('Authentication token not found')) {
        _handleAuthError(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading wallet: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Verify the payment with your backend
      final verifyResponse = await _walletService.verifyWalletTopup(double.parse(response.paymentId!));
      
      // Reload wallet data to get updated balance and transactions
      await _loadWalletData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying payment: ${e.toString()}')),
      );
    }
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

  void _addTransaction(double amount, String type) {
    setState(() {
      _transactions.insert(0, {
        'amount': amount,
        'type': type,
        'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
      
      // Update balance
      if (type.toLowerCase().contains('deposit')) {
        _balance += amount;
      } else if (type.toLowerCase().contains('withdrawal')) {
        _balance -= amount;
      }
    });
  }

  void _handleAuthError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please login again.'),
        duration: Duration(seconds: 3),
      ),
    );
    // TODO: Navigate to login screen
    // Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _handleDeposit() async {
    final TextEditingController amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Deposit Amount',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter amount in INR',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5030E8)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (amountController.text.isEmpty) return;
              
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                // First initiate the topup to get order details
                final topupResponse = await _walletService.topupWallet(amount);
                
                // Initialize Razorpay only when needed
                _initializeRazorpay();
                
                // Initialize Razorpay payment
                var options = {
                  'key': 'rzp_test_NMHJrIP0HgARfE',
                  'amount': (amount * 100).toInt(), // Amount in smallest currency unit
                  'name': 'Smart E-commerce',
                  'description': 'Wallet Top-up',
                  'order_id': topupResponse['id'],
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
                if (e.toString().contains('Unauthorized') || 
                    e.toString().contains('Authentication token not found')) {
                  _handleAuthError(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5030E8),
            ),
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // App bar section as Stack with line behind transparent app bar
                Container(
                  height: 90, // Reduced from 70 to 60
                  child: Stack(
                    children: [
                      // App bar line as the base layer
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/appbar_line.png',
                          fit: BoxFit.fill,
                          width: double.infinity,
                        ),
                      ),
                      
                      // Transparent app bar overlaying the line
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button with title next to it
                              Row(
                                children: [
                                  // Back button - with transparent background
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen()), (route) => false);
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF5030E8).withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  // Wallet title - positioned next to back button
                                  const SizedBox(width: 15),
                                  const Text(
                                    'Wallet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Scan button - with transparent background
                              GestureDetector(
                                onTap: () {
                                  // Handle QR scanner tap
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5030E8).withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [                    
                        // Current Balance section
                        const Center(
                          child: Text(
                            'Current Balance',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Balance amount
                        Center(
                          child: Text(
                            _currencyFormat.format(_balance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Deposit and Withdraw buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            children: [
                              // Deposit button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleDeposit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5030E8),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Deposit',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Withdraw button
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.grey, width: 1.0),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Withdraw',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Transaction History
                        const Center(
                          child: Text(
                            'Transaction History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Transaction list
                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5030E8)),
                                  ),
                                )
                              : _transactions.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No transactions yet',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _transactions.length,
                                      itemBuilder: (context, index) {
                                        final transaction = _transactions[index];
                                        final amount = (transaction['amount'] ?? 0.0).toDouble();
                                        final type = transaction['type'] ?? 'Deposit';
                                        final date = DateTime.fromMillisecondsSinceEpoch(
                                          (transaction['created_at'] ?? 0) * 1000,
                                        );
                                        
                                        return TransactionItem(
                                          type: type,
                                          account: DateFormat('MMM dd, yyyy').format(date),
                                          amount: _currencyFormat.format(amount),
                                          isDeposit: type.toLowerCase().contains('deposit'),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5030E8)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String type;
  final String account;
  final String amount;
  final bool isDeposit;

  const TransactionItem({
    Key? key,
    required this.type,
    required this.account,
    required this.amount,
    this.isDeposit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: TextStyle(
                  color: isDeposit ? Colors.green : Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                account,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              color: isDeposit ? Colors.green : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 