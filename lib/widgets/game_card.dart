import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final VoidCallback onPlay;
  final String? title;
  final String? description;
  final Color backgroundColor;

  const GameCard({
    Key? key,
    required this.onPlay,
    this.title,
    this.description,
    this.backgroundColor = const Color(0xFF19173A),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Game image
          const SizedBox(
            height: 200,
            width: 200,
            child: GameImageWidget(),
          ),
          
          // Optional title and description
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF19173A),
                ),
              ),
            ),
            
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            
          // Play Now button
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onPlay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5F67EE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Play Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A dialog wrapper for the GameCard
class GameCardDialog extends StatelessWidget {
  final VoidCallback onPlay;
  final String? title;
  final String? description;
  final Color backgroundColor;

  const GameCardDialog({
    Key? key,
    required this.onPlay,
    this.title,
    this.description,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPlay,
    String? title,
    String? description,
    Color backgroundColor = Colors.white,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Game Card',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: GameCardDialog(
              onPlay: onPlay,
              title: title,
              description: description,
              backgroundColor: backgroundColor,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.close, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Game Card
          GameCard(
            onPlay: () {
              Navigator.of(context).pop();
              onPlay();
            },
            title: title,
            description: description,
            backgroundColor: backgroundColor,
          ),
        ],
      ),
    );
  }
}

// Game image widget with fallback if asset not found
class GameImageWidget extends StatelessWidget {
  const GameImageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/game.png',
      width: 150,
      height: 150,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to a placeholder image
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.games,
            size: 80,
            color: Colors.blue,
          ),
        );
      },
    );
  }
} 