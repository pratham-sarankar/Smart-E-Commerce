import 'package:flutter/material.dart';
import 'package:smart_eommerce/screens/main_screen.dart';
import 'package:smart_eommerce/screens/home_screen.dart';
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
  int? _currentPaymentAmount;
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
          // Safely convert balance to double
          final balance = walletData['wallet']?['balance'];
          _balance = balance is num ? balance.toDouble() : 0.0;
          
          // Clear existing transactions
          _transactions.clear();
          
          // Add transactions from the API response
          final transactions = walletData['wallet']?['transactions'] as List<dynamic>?;
          if (transactions != null) {
            _transactions.addAll(transactions.map((t) => {
              'amount': t['amount']?.toDouble() ?? 0.0,
              'type': t['type'] ?? '',
              'status': t['status'] ?? '',
              'created_at': DateTime.parse(t['createdAt'] ?? DateTime.now().toIso8601String()).millisecondsSinceEpoch ~/ 1000,
            }).toList());
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
      if (response.paymentId == null || response.orderId == null || response.signature == null) {
        throw Exception('Invalid payment response from Razorpay');
      }

      if (_currentPaymentAmount == null) {
        throw Exception('Payment amount not found');
      }

      setState(() => _isLoading = true);
      
      // Verify the payment with your backend
      final verifyResponse = await _walletService.verifyWalletTopup(
        paymentId: response.paymentId!,
        orderId: response.orderId!,
        signature: response.signature!,
        amount: _currentPaymentAmount!,
      );
      
      // Reload wallet data to get updated balance and transactions
      await _loadWalletData();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(verifyResponse['message'], style: TextStyle(color: Colors.white),)),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying payment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    final FocusNode amountFocusNode = FocusNode();
    
    // Predefined deposit amounts
    final depositAmounts = [
      100, 500, 1000, 2000, 5000
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E3A70), // Darker Navy Blue
                  const Color(0xFF0B1D3A), // Original Navy Blue
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700), // Gold border
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header with icon
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFFFFD700),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  const Text(
                    'Add Money to Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Amount Input
                  TextField(
                    controller: amountController,
                    focusNode: amountFocusNode,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFFFFD700)),
                      filled: true,
                      fillColor: const Color(0xFF1E3A70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Quick Amount Buttons
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: depositAmounts.map((amount) => 
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            amountController.text = amount.toString();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A70),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFFD700).withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              '₹$amount',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    ).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (amountController.text.isEmpty) return;
                            
                            final amount = double.tryParse(amountController.text);
                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a valid amount')),
                              );
                              return;
                            }

                            // Existing deposit logic
                            Navigator.pop(context);
                            setState(() => _isLoading = true);

                            try {
                              final topupResponse = await _walletService.topupWallet(amount);
                              
                              _currentPaymentAmount = amount.toInt();
                              _initializeRazorpay();
                              
                              var options = {
                                'key': 'rzp_test_NMHJrIP0HgARfE',
                                'amount': _currentPaymentAmount!,
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
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: const Color(0xFF0B1D3A),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Proceed',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleWithdraw() async {
    final TextEditingController amountController = TextEditingController();
    final FocusNode amountFocusNode = FocusNode();
    
    // Predefined withdrawal amounts
    final withdrawAmounts = [
      100, 500, 1000, 2000, 5000
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E3A70), // Darker Navy Blue
                  const Color(0xFF0B1D3A), // Original Navy Blue
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700), // Gold border
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header with icon
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monetization_on_outlined,
                      color: Color(0xFFFFD700),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  const Text(
                    'Withdraw from Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Current Balance Display
                  Text(
                    'Available Balance: ${_currencyFormat.format(_balance)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Amount Input
                  TextField(
                    controller: amountController,
                    focusNode: amountFocusNode,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Enter withdrawal amount',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFFFFD700)),
                      filled: true,
                      fillColor: const Color(0xFF1E3A70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Quick Amount Buttons
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: withdrawAmounts.map((amount) => 
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            amountController.text = amount.toString();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A70),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFFD700).withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              '₹$amount',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    ).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (amountController.text.isEmpty) return;
                            
                            final amount = double.tryParse(amountController.text);
                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a valid amount')),
                              );
                              return;
                            }

                            if (amount > _balance) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Insufficient balance')),
                              );
                              return;
                            }

                            setState(() => _isLoading = true);

                            try {
                              final response = await _walletService.requestWithdrawal(amount);
                              
                              if (!mounted) return;
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response['message'] ?? 'Withdrawal request submitted')),
                              );
                              
                              Navigator.pop(context);
                              
                              await _loadWalletData();
                            } catch (e) {
                              if (!mounted) return;
                              
                              if (e.toString().contains('Unauthorized') || 
                                  e.toString().contains('Authentication token not found')) {
                                _handleAuthError(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                );
                              }
                              Navigator.pop(context);
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: const Color(0xFF0B1D3A),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Withdraw',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D3A), // Navy Blue background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // App bar section
                Container(
                  height: 90,
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
                            children: [
                              // Back button with title next to it
                              Row(
                                children: [
                                  // Back button - with transparent background
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      splashColor: const Color(0xFFFFD700).withOpacity(0.3),
                                      highlightColor: const Color(0xFFFFD700).withOpacity(0.1),
                                      onTap: () {
                                        Navigator.pushAndRemoveUntil(
                                          context, 
                                          FadePageRoute(page: const MainScreen()), 
                                          (route) => false
                                        );
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD700).withOpacity(0.2), // Gold with opacity
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: Color(0xFFFFD700), // Gold
                                        ),
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
                              color: Color(0xFFFFD700), // Gold color
                              fontSize: 18,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Balance amount - Premium Card Style
                        Center(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF1E3A70), // Darker Navy Blue
                                  const Color(0xFF0B1D3A), // Original Navy Blue
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFD700), // Gold border
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.3), // Gold shadow
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Total Balance',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _currencyFormat.format(_balance),
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700), // Gold color
                                    fontSize: 52,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Deposit and Withdraw buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              // Deposit button
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: _isLoading ? null : _handleDeposit,
                                    child: ElevatedButton.icon(
                                      onPressed: _isLoading ? null : _handleDeposit,
                                      icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF0B1D3A)),
                                      label: const Text(
                                        'Add Money',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0B1D3A),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFD700), // Gold
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Withdraw button
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: _isLoading ? null : _handleWithdraw,
                                    child: OutlinedButton.icon(
                                      onPressed: _isLoading ? null : _handleWithdraw,
                                      icon: const Icon(Icons.arrow_circle_down_outlined, size: 20, color: Color(0xFFFFD700)),
                                      label: const Text(
                                        'Withdraw',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFD700),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                                        foregroundColor: const Color(0xFFFFD700),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Transaction History
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Transaction History',
                                style: TextStyle(
                                  color: Color(0xFFFFD700), // Gold color
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: null, // Optional: Add functionality if needed
                                icon: const Icon(Icons.history, color: Colors.white54),
                                label: const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Transaction list
                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)), // Gold color
                                  ),
                                )
                              : _transactions.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No transactions yet',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _transactions.length,
                                      itemBuilder: (context, index) {
                                        final transaction = _transactions[index];
                                        final amount = (transaction['amount'] ?? 0.0).toDouble();
                                        final type = transaction['type'] ?? '';
                                        final status = transaction['status'] ?? '';
                                        final date = DateTime.fromMillisecondsSinceEpoch(
                                          (transaction['created_at'] ?? 0) * 1000,
                                        );
                                        
                                        return TransactionItem(
                                          type: type,
                                          account: DateFormat('MMM dd, yyyy').format(date),
                                          amount: _currencyFormat.format(amount),
                                          isDeposit: type.toLowerCase() == 'credit',
                                          status: status,
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
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)), // Gold color
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
  final String status;

  const TransactionItem({
    Key? key,
    required this.type,
    required this.account,
    required this.amount,
    this.isDeposit = false,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Optional: Add transaction details view or action
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A70), // Darker Navy Blue
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.3), // Gold border
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isDeposit ? const Color(0xFF00FF00) : const Color(0xFFFFD700),
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: status == 'Completed' 
                              ? const Color(0xFF00FF00).withOpacity(0.2) 
                              : const Color(0xFFFFD700).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: status == 'Completed' ? const Color(0xFF00FF00) : const Color(0xFFFFD700),
                              fontSize: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                amount,
                style: TextStyle(
                  color: isDeposit ? const Color(0xFF00FF00) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 