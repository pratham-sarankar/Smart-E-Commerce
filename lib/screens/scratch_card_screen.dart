import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';
import 'dart:math';

class ScratchCardScreen extends StatefulWidget {
  final int amount;
  final String clubName;

  const ScratchCardScreen({
    Key? key, 
    required this.amount, 
    required this.clubName,
  }) : super(key: key);

  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen> {
  bool _canScratch = false;
  String _reward = '';
  
  @override
  void initState() {
    super.initState();
    _checkScratchEligibility();
  }

  void _checkScratchEligibility() {
    final now = DateTime.now();
    final isAfter8PM = now.hour >= 20;

    setState(() {
      _canScratch = isAfter8PM;
      _generateReward();
    });
  }

  void _generateReward() {
    final rewards = [
      'Maza Aa Gaya! 🎉',
      'Lakhpati Banne Ke Karib! 💰',
      'Aaj Ki Bumper Offer! 🎊',
      'Khushi Ke Dhamake! 🎈',
      'Luck Aa Raha Hai! 🍀',
    ];

    final bonusRewards = {
      'Silver Club': [
        '10% Cashback',
        'Extra Spin Chance',
        'Surprise Bonus',
      ],
      'Gold Club': [
        '20% Cashback',
        'Double Spin Chance',
        'Premium Bonus',
      ],
      'Platinum Club': [
        '50% Cashback',
        'Triple Spin Chance',
        'Mega Bonus',
      ],
    };

    final random = Random();
    final baseReward = rewards[random.nextInt(rewards.length)];
    final clubSpecificReward = bonusRewards[widget.clubName]?[random.nextInt(bonusRewards[widget.clubName]!.length)] ?? '';

    _reward = '$baseReward\n$clubSpecificReward';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D3A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${widget.clubName} Scratch Card',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _canScratch 
                ? _buildScratchCard() 
                : _buildLockedCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A70),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.lock_clock,
            color: Color(0xFFFFD700),
            size: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Scratch Card Locked',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Come back after 8 PM to reveal your scratch card!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScratchCard() {
    return Scratcher(
      accuracy: ScratchAccuracy.low,
      threshold: 30,
      brushSize: 30,
      color: const Color(0xFFFFD700),
      image: Image.asset('assets/images/scratch_overlay.png'),
      onChange: (value) {
        // Optional: Add some logic when scratching progresses
      },
      onThreshold: () {
        // Optional: Add celebration or additional logic when fully scratched
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A70),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
        ),
        child: Column(
          children: [
            Text(
              '${widget.clubName} Reward',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.card_giftcard,
              color: Color(0xFFFFD700),
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              _reward,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 