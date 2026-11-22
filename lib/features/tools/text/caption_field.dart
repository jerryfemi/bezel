import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';

/// A labelled text field that keeps its own controller, so typing is never
/// interrupted by rebuilds. Reports every change, and picks up outside edits
/// (such as typing on the canvas) when it isn't focused.
class CaptionField extends StatefulWidget {
  const CaptionField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.bold = false,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool bold;

  @override
  State<CaptionField> createState() => _CaptionFieldState();
}

class _CaptionFieldState extends State<CaptionField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();

  @override
  void didUpdateWidget(CaptionField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _focus.dispose();
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
        focusNode: _focus,
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
