import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _showBalance = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            // Logo container with icon
            Center(
              child: Image.asset(
                'assets/icons/logo.png',
                height: 24,
                width: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image is not found
                  return Icon(
                    Icons.auto_awesome, 
                    color: Colors.blue.shade300,
                    size: 24,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: const Text(
                'MASTI LOTTIE',
                style: TextStyle(
                  color: Colors.white, // This will be replaced by the gradient
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
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
              border: Border.all(color: Colors.grey.shade700, width: 1),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background wave image
          Positioned.fill(
            top: -100,
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/images/home_wave.png',
                fit: BoxFit.contain,
                height: 20,
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Top section with padding
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting section
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/images/profile_pic.png'),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Morning Rajat,',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Balance Tabs
                      DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              controller: _tabController,
                              indicatorColor: Colors.deepPurple,
                              indicatorWeight: 3,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey,
                              tabs: const [
                                Tab(text: 'Available Balance'),
                                Tab(text: 'Total Winning Price'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Balance amount
                            SizedBox(
                              height: 120,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Available Balance Tab
                                  BalanceDisplay(
                                    amount: '₹41,520.49',
                                    isVisible: _showBalance,
                                    onToggle: () {
                                      setState(() {
                                        _showBalance = !_showBalance;
                                      });
                                    },
                                  ),
                                  // Total Winning Price Tab
                                  BalanceDisplay(
                                    amount: '₹8,325.75',
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
                      
                      const SizedBox(height: 24),
                      
                      // Donate Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Donate 1 Rupee',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                
                // Full-width containers
                // Payment methods section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Choose Payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                            label: Text(
                              'Add Money',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade700),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Payment cards
                      PaymentMethodCard(
                        cardType: 'mastercard',
                        lastFourDigits: '1234',
                      ),
                      const SizedBox(height: 8),
                      PaymentMethodCard(
                        cardType: 'visa',
                        lastFourDigits: '4887',
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add_circle_outline, color: Colors.white, size: 16),
                          label: Text(
                            'Add new payment method',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content below payment section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Withdrawal section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Withdrawal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 16,
                            ),
                            label: Text(
                              'Manage',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade700),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Withdrawal options
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.deepPurple, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'UPI',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  Text(
                                    'Wave Simple',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade800),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Credit',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  Text(
                                    'Wave Fluro',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Weekly withdrawal amount
                      Row(
                        children: [
                          Icon(Icons.history, color: Colors.grey.shade400, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '₹328.88',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'this week',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Main savings
                      Row(
                        children: [
                          Icon(Icons.savings_outlined, color: Colors.grey.shade400, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Main savings',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Options button
                      SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.more_horiz, color: Colors.white, size: 16),
                          label: Text(
                            'Options',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      
                      // Credit card image
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 40,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey.shade900,
                            ),
                            child: Center(
                              child: Icon(Icons.credit_card, color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Transactions section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Translations',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 16,
                            ),
                            label: Text(
                              'Manage',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade700),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Transaction list
                      TransactionItem(
                        title: 'Withdrawal to',
                        subtitle: 'Account',
                        amount: '₹100.00',
                      ),
                      const SizedBox(height: 12),
                      TransactionItem(
                        title: 'Transfer to',
                        subtitle: 'Wallet',
                        amount: '₹400.00',
                      ),
                      const SizedBox(height: 12),
                      TransactionItem(
                        title: 'Withdrawal to',
                        subtitle: 'Account',
                        amount: '₹100.00',
                      ),
                      const SizedBox(height: 16),
                      
                      // Show all button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          label: Text(
                            'Show All',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Manage homepage
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.sync, color: Colors.white),
                          label: Text(
                            'Manage Homepage',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
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

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Always show the actual price
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                wholePart,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '.$decimalPart',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Reduced space
          // Eye icon with "Show" text
          OutlinedButton.icon(
            onPressed: onToggle,
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
              size: 16,
            ),
            label: Text(
              'Show',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              side: BorderSide(color: Colors.grey.shade600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 