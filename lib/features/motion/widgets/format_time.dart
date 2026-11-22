/// 1.25 → "0:01.2"
String formatClipTime(double seconds) {
  final s = seconds.clamp(0, 5999).toDouble();
  final minutes = s ~/ 60;
  final rest = s - minutes * 60;
  return '$minutes:${rest.toStringAsFixed(1).padLeft(4, '0')}';
}
