import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

class ScratchCardScreen extends StatefulWidget {
  const ScratchCardScreen({Key? key}) : super(key: key);

  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _scratchCards = [];
  String _error = '';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;
  Map<int, bool> _revealedCards = {};
  late AnimationController _scratchGuideController;
  late Animation<double> _scratchGuideAnimation;
  int? _activeCardIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _canScratch = false;
  String _timeUntilScratch = '8 PM';
  Map<String, dynamic>? _scratchResult;

  @override
  void initState() {
    super.initState();
    _checkScratchTime();
    _fetchTodaysDraw();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _scratchGuideController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _scratchGuideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scratchGuideController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    _scratchGuideController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  void _checkScratchTime() {
    final now = DateTime.now();
    final eightPM = DateTime(now.year, now.month, now.day, 11, 0); // 8 PM
    setState(() {
      _canScratch = now.isAfter(eightPM);
    });
  }

  Future<void> _fetchTodaysDraw() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final response = await http.get(
        Uri.parse('https://4sr8mplp-3035.inc1.devtunnels.ms/api/user/todays-draw'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['entry'] != null) {
          setState(() {
            _scratchCards = data['entry']['entries'] ?? [];
          });
        } else {
          setState(() {
            _error = 'No scratch cards available';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load scratch cards';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading scratch cards';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scratchCard(String scratchCardId) async {
    if (!_canScratch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scratch cards can only be scratched after 8 PM'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://4sr8mplp-3035.inc1.devtunnels.ms/api/draw/scratch-card/$scratchCardId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _scratchResult = data;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Card scratched successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to scratch card. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error scratching card. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _playWinningAnimation(int index) async {
    if (!_revealedCards[index]!) {
      _revealedCards[index] = true;
      _confettiController.play();
      _animationController.forward();
      
      // Play winning sound with error handling
      try {
        // Using a more reliable sound URL from a CDN
        await _audioPlayer.play(UrlSource('https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0c6ff1bab.mp3?filename=winning-chimes-2015-143438.mp3'));
      } catch (e) {
        // If sound fails to play, just continue without sound
        print('Sound playback skipped: $e');
        // You can add a visual feedback here if needed
      }
    }
  }

  String _generateReward(String plan) {
    final rewards = [
      'Maza Aa Gaya! 🎉',
      'Lakhpati Banne Ke Karib! 💰',
      'Aaj Ki Bumper Offer! 🎊',
      'Khushi Ke Dhamake! 🎈',
      'Luck Aa Raha Hai! 🍀',
    ];

    final bonusRewards = {
      'silver': [
        '10% Cashback',
        'Extra Spin Chance',
        'Surprise Bonus',
      ],
      'gold': [
        '20% Cashback',
        'Double Spin Chance',
        'Premium Bonus',
      ],
      'diamond': [
        '50% Cashback',
        'Triple Spin Chance',
        'Mega Bonus',
      ],
    };

    final random = Random();
    final baseReward = rewards[random.nextInt(rewards.length)];
    final clubSpecificReward = bonusRewards[plan.toLowerCase()]?[random.nextInt(bonusRewards[plan.toLowerCase()]!.length)] ?? '';

    return '$baseReward\n$clubSpecificReward';
  }

  Widget _buildScratchGuide() {
    return AnimatedBuilder(
      animation: _scratchGuideAnimation,
      builder: (context, child) {
        // Calculate zigzag movement
        final baseX = _scratchGuideAnimation.value * 280;
        final zigzagY = sin(_scratchGuideAnimation.value * 4 * pi) * 20; // Zigzag amplitude

        return Stack(
          children: [
            // Main circular effect
            Positioned(
              left: baseX - 25,
              top: 140 + zigzagY - 25, // Center vertically and add zigzag
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.4),
                      const Color(0xFFFFD700).withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            // Trail effect
            Positioned(
              left: baseX - 40,
              top: 140 + zigzagY - 15,
              child: Container(
                width: 80,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      const Color(0xFFFFD700).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconPattern() {
    return Container(
      width: double.infinity,
      height: 100, // Fixed height for top section
      color: const Color(0xFFFFD700),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        padding: const EdgeInsets.all(10),
        itemCount: 9,
        itemBuilder: (context, i) {
          final icons = [
            Icons.star,
            Icons.card_giftcard,
            Icons.celebration,
            Icons.emoji_events,
            Icons.diamond,
            Icons.workspace_premium,
          ];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 2,
              ),
            ),
            child: Icon(
              icons[i % icons.length],
              color: Colors.white,
              size: 24,
            ),
          );
        },
      ),
    );
  }

  Widget _buildScratchCard(dynamic entry, String reward, int index) {
    _revealedCards[index] = _revealedCards[index] ?? false;
    final ticket = entry['participationTicket'];
    
    return SizedBox(
      height: 260,
      width: MediaQuery.of(context).size.width - 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          children: [
            if (!_canScratch)
              // Show locked card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A70),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_clock,
                        color: Color(0xFFFFD700),
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _timeUntilScratch,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              // Show scratchable card
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Scratcher(
                  color: const Color(0xFFFFD700),
                  accuracy: ScratchAccuracy.high,
                  threshold: 25,
                  brushSize: 30,
                  image: Image.asset('assets/images/trophy-removebg-preview.png',
                    width: 10,
                    alignment: Alignment.center,
                    height: 10,
                    fit: BoxFit.contain,
                  ),
                  onChange: (value) {
                    if (value >= 25 && !_revealedCards[index]!) {
                      _playWinningAnimation(index);
                      _scratchCard(ticket['scratchCard']);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          setState(() {
                            _revealedCards[index] = true;
                            _activeCardIndex = null;
                          });
                        }
                      });
                    }
                  },
                  onThreshold: () {
                    if (!_revealedCards[index]!) {
                      _playWinningAnimation(index);
                    }
                  },
                  onScratchStart: () {
                    setState(() {
                      _activeCardIndex = index;
                      _scratchGuideController.repeat(reverse: true);
                    });
                  },
                  onScratchEnd: () {
                    setState(() {
                      _activeCardIndex = null;
                      _scratchGuideController.stop();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    ),
                    child: Stack(
                      children: [
                        // Content to be revealed
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_revealedCards[index]! && _scratchResult != null)
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Column(
                                      children: [
                                        Icon(
                                          _scratchResult!['winningAmount'] > 0 
                                              ? Icons.emoji_events
                                              : Icons.sentiment_dissatisfied,
                                          color: _scratchResult!['winningAmount'] > 0 
                                              ? const Color(0xFFFFD700)
                                              : Colors.grey,
                                          size: 50,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _scratchResult!['message'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Winning Amount: ₹${_scratchResult!['winningAmount']}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Wallet Balance: ₹${_scratchResult!['walletBalance']}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
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
            if (_revealedCards[index]! && _scratchResult != null && _scratchResult!['winningAmount'] > 0)
              Positioned.fill(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFFFFD700),
                    Colors.white,
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D3A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Scratch Cards',
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
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFD700),
                  ),
                )
              : _error.isNotEmpty
                  ? Center(
                      child: Text(
                        _error,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : _scratchCards.isEmpty
                      ? const Center(
                          child: Text(
                            'No scratch cards available',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchTodaysDraw,
                          color: const Color(0xFFFFD700),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            itemCount: _scratchCards.length,
                            itemBuilder: (context, index) {
                              final entry = _scratchCards[index];
                              final reward = _generateReward(entry['participationTicket']['plan']);
                              return _buildScratchCard(entry, reward, index);
                            },
                          ),
                        ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Color(0xFFFFD700),
                Colors.white,
                Colors.blue,
                Colors.red,
                Colors.green,
              ],
            ),
          ),
        ],
      ),
    );
  }
} 