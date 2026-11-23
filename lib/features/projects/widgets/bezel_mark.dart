import 'package:flutter/material.dart';

/// The Bezel logo mark: a phone outline inside a rounded square.
class BezelMark extends StatelessWidget {
  const BezelMark({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A6CF0), Color(0xFF1E3FA8)],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.34,
        height: size * 0.58,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1.6),
          borderRadius: BorderRadius.circular(size * 0.09),
        ),
      ),
    );
  }
}
