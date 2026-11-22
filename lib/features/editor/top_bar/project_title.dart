import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../state/project_title_provider.dart';

/// The project name. Click to rename; Enter or clicking away saves.
class ProjectTitle extends ConsumerStatefulWidget {
  const ProjectTitle({super.key});

  @override
  ConsumerState<ProjectTitle> createState() => _ProjectTitleState();
}

class _ProjectTitleState extends ConsumerState<ProjectTitle> {
  late final _controller = TextEditingController(text: ref.read(projectTitleProvider));
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() { if (!_focus.hasFocus) _save(); });
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) _controller.text = ref.read(projectTitleProvider);
    ref.read(projectTitleProvider.notifier).state = _controller.text.trim();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Opening another project changes the title from outside.
    ref.listen(projectTitleProvider, (_, next) {
      if (!_focus.hasFocus && _controller.text != next) _controller.text = next;
    });
    return SizedBox(
      width: 200,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        style: BezelType.body.copyWith(fontWeight: FontWeight.w500),
        cursorColor: BezelColors.accentLine,
        onSubmitted: (_) => _focus.unfocus(),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'Untitled clip',
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }
}
