import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/wallet_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final WalletService _walletService = WalletService();
  bool _isLoading = false;
  final List<Map<String, dynamic>> _transactions = [];
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactionsData = await _walletService.getAllTransactions();
      if (transactionsData['success'] == true) {
        setState(() {
          _transactions.clear();
          final transactions = transactionsData['transactions'] as List<dynamic>?;
          if (transactions != null) {
            _transactions.addAll(transactions.map((t) => {
              'id': t['_id'] ?? '',
              'transaction_id': t['transactionId'] ?? '',
              'amount': t['amount']?.toDouble() ?? 0.0,
              'type': t['type'] ?? '',
              'status': t['status'] ?? '',
              'created_at': DateTime.parse(t['createdAt'] ?? DateTime.now().toIso8601String()),
              'updated_at': DateTime.parse(t['updatedAt'] ?? DateTime.now().toIso8601String()),
            }).toList());
          }
        });
      }
    } catch (e) {
      if (e.toString().contains('Unauthorized') || 
          e.toString().contains('Authentication token not found')) {
        _handleAuthError();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleAuthError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please login again.'),
        duration: Duration(seconds: 3),
      ),
    );
    // TODO: Navigate to login screen
    // Navigator.of(context).pushReplacementNamed('/login');
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
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD700).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: Color(0xFFFFD700),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  const Text(
                                    'Transaction History',
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
                
                // Transaction list
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                          ),
                        )
                      : _transactions.isEmpty
                          ? const Center(
                              child: Text(
                                'No transactions found',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadTransactions,
                              color: const Color(0xFFFFD700),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = _transactions[index];
                                  return TransactionDetailCard(
                                    transaction: transaction,
                                    currencyFormat: _currencyFormat,
                                  );
                                },
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
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TransactionDetailCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final NumberFormat currencyFormat;

  const TransactionDetailCard({
    Key? key,
    required this.transaction,
    required this.currencyFormat,
  }) : super(key: key);

  void _copyTransactionId(BuildContext context) {
    final transactionId = transaction['transaction_id']?.toString() ?? '';
    Clipboard.setData(ClipboardData(text: transactionId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction ID copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFFFFD700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction['type']?.toString().toLowerCase() == 'credit';
    final status = transaction['status']?.toString() ?? '';
    final createdAt = transaction['created_at'] as DateTime;
    final updatedAt = transaction['updated_at'] as DateTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A70),
            const Color(0xFF0B1D3A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Show transaction details in a dialog
            showDialog(
              context: context,
              builder: (context) => TransactionDetailsDialog(
                transaction: transaction,
                currencyFormat: currencyFormat,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with type and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCredit 
                            ? const Color(0xFF00FF00).withOpacity(0.2)
                            : const Color(0xFFFFD700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        transaction['type']?.toString() ?? '',
                        style: TextStyle(
                          color: isCredit ? const Color(0xFF00FF00) : const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == 'Completed'
                            ? const Color(0xFF00FF00).withOpacity(0.2)
                            : const Color(0xFFFFD700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: status == 'Completed' ? const Color(0xFF00FF00) : const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Amount
                Text(
                  currencyFormat.format(transaction['amount']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Transaction ID
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Transaction ID: ${transaction['transaction_id']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color(0xFFFFD700), size: 20),
                      onPressed: () => _copyTransactionId(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Date
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(createdAt)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final NumberFormat currencyFormat;

  const TransactionDetailsDialog({
    Key? key,
    required this.transaction,
    required this.currencyFormat,
  }) : super(key: key);

  void _copyTransactionId(BuildContext context) {
    final transactionId = transaction['transaction_id']?.toString() ?? '';
    Clipboard.setData(ClipboardData(text: transactionId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction ID copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFFFFD700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction['type']?.toString().toLowerCase() == 'credit';
    final status = transaction['status']?.toString() ?? '';
    final createdAt = transaction['created_at'] as DateTime;
    final updatedAt = transaction['updated_at'] as DateTime;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3A70),
              const Color(0xFF0B1D3A),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD700),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Transaction Type
              _buildDetailRow(
                'Type',
                transaction['type']?.toString() ?? '',
                isCredit ? const Color(0xFF00FF00) : const Color(0xFFFFD700),
              ),
              
              // Status
              _buildDetailRow(
                'Status',
                status,
                status == 'Completed' ? const Color(0xFF00FF00) : const Color(0xFFFFD700),
              ),
              
              // Amount
              _buildDetailRow(
                'Amount',
                currencyFormat.format(transaction['amount']),
                Colors.white,
              ),
              
              // Transaction ID
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Transaction ID',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction['transaction_id']?.toString() ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFFFFD700), size: 20),
                          onPressed: () => _copyTransactionId(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Created At
              _buildDetailRow(
                'Created At',
                DateFormat('MMM dd, yyyy HH:mm:ss').format(createdAt),
                Colors.white70,
              ),
              
              // Updated At
              _buildDetailRow(
                'Updated At',
                DateFormat('MMM dd, yyyy HH:mm:ss').format(updatedAt),
                Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 