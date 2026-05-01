import 'package:flutter/material.dart';

class PremiumBadge extends StatelessWidget {
  final double size;

  const PremiumBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: size * 0.75, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.65,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
