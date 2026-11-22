import 'package:flutter/material.dart';

/// A small picture of a device, used in the Device picker.
///
/// For now it is drawn: a body in the finish colour, a dark screen and the
/// island. When rendered sprites of each model exist, this is the one place
/// to swap them in.
class DevicePreview extends StatelessWidget {
  const DevicePreview({super.key, required this.bodyColor, this.height = 72});

  final Color bodyColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final width = height * 0.49;
    final radius = height * 0.14;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(height * 0.035),
      decoration: BoxDecoration(
        color: bodyColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: height * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius * 0.8),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B2340), Color(0xFF2A1E4A)],
          ),
        ),
        child: Container(
          width: width * 0.32,
          height: height * 0.045,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(height),
          ),
        ),
      ),
    );
  }
}
