import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
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
                                  // Navigate back if needed
                                  // Usually not needed in bottom nav scenario
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
                    const Center(
                      child: Text(
                        '\$56.085',
                        style: TextStyle(
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
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5030E8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
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
                    
                    // Transaction History - Center aligned
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
                      child: ListView(
                        children: const [
                          TransactionItem(
                            type: 'Withdrawal to',
                            account: 'Account',
                            amount: '₹100.00',
                          ),
                          TransactionItem(
                            type: 'Transfer to',
                            account: 'Wallet',
                            amount: '₹400.00',
                          ),
                          TransactionItem(
                            type: 'Withdrawal to',
                            account: 'Account',
                            amount: '₹100.00',
                          ),
                          TransactionItem(
                            type: 'Withdrawal to',
                            account: 'Account',
                            amount: '₹100.00',
                          ),
                          TransactionItem(
                            type: 'Transfer to',
                            account: 'Wallet',
                            amount: '₹400.00',
                          ),
                          TransactionItem(
                            type: 'Withdrawal to',
                            account: 'Account',
                            amount: '₹100.00',
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
}

class TransactionItem extends StatelessWidget {
  final String type;
  final String account;
  final String amount;

  const TransactionItem({
    Key? key,
    required this.type,
    required this.account,
    required this.amount,
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
                style: const TextStyle(
                  color: Colors.grey,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 