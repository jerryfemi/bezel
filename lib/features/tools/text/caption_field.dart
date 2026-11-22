import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';

/// A labelled text field that keeps its own controller, so typing is never
/// interrupted by rebuilds. Reports every change.
class CaptionField extends StatefulWidget {
  const CaptionField({
    super.key,
    required this.label,
    required this.initial,
    required this.onChanged,
    this.bold = false,
  });

  final String label;
  final String initial;
  final ValueChanged<String> onChanged;
  final bool bold;

  @override
  State<CaptionField> createState() => _CaptionFieldState();
}

class _CaptionFieldState extends State<CaptionField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(widget.label, style: BezelType.section),
      const SizedBox(height: 6),
      TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        maxLines: null,
        style: BezelType.body.copyWith(fontWeight: widget.bold ? FontWeight.w600 : FontWeight.w400),
        cursorColor: BezelColors.accentLine,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFF18181C),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: _border(BezelColors.strokeStrong),
          enabledBorder: _border(BezelColors.strokeStrong),
          focusedBorder: _border(BezelColors.accentLine),
        ),
      ),
    ]);
  }

  static OutlineInputBorder _border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: c));
}
