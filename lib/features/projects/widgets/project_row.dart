import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/pressable.dart';
import '../../scene3d/device_catalog.dart';
import '../model/project_doc.dart';

/// One saved project: thumbnail, name, device and when it was last edited.
/// Duplicate and delete appear on hover; delete asks once more before acting.
class ProjectRow extends StatefulWidget {
  const ProjectRow({
    super.key,
    required this.doc,
    required this.current,
    required this.onOpen,
    required this.onDuplicate,
    required this.onDelete,
  });

  final ProjectDoc doc;
  final bool current;
  final VoidCallback onOpen;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  State<ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<ProjectRow> {
  bool _hover = false;
  bool _confirmDelete = false;

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final device = deviceCatalog.where((e) => e.id == doc.deviceId).map((e) => e.label);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() { _hover = false; _confirmDelete = false; }),
      child: Pressable(
        onTap: widget.onOpen,
        label: 'Open ${doc.title}',
        selected: widget.current,
        pressedScale: 0.99,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: widget.current ? BezelColors.selected : _hover ? BezelColors.hover : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            _Thumb(dataUrl: doc.thumbnail),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: BezelType.body.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('${device.isEmpty ? 'Device' : device.first} · ${_ago(doc.updatedAt)}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: BezelType.label.copyWith(color: BezelColors.textSecondary)),
              ]),
            ),
            if (_hover || _confirmDelete) ...[
              _IconAction(icon: Icons.copy_outlined, tip: 'Duplicate', onTap: widget.onDuplicate),
              _IconAction(
                icon: _confirmDelete ? Icons.delete_forever : Icons.delete_outline,
                tip: _confirmDelete ? 'Click again to delete' : 'Delete',
                danger: _confirmDelete,
                onTap: () => _confirmDelete ? widget.onDelete() : setState(() => _confirmDelete = true),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes} min ago';
    if (d.inDays < 1) return '${d.inHours} h ago';
    if (d.inDays < 7) return '${d.inDays} d ago';
    return '${t.day}/${t.month}/${t.year}';
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.dataUrl});

  final String? dataUrl;

  @override
  Widget build(BuildContext context) {
    final bytes = dataUrl == null ? null : UriData.tryParse(dataUrl!)?.contentAsBytes();
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 64,
        height: 40,
        color: const Color(0xFF18181C),
        child: bytes == null
            ? const Icon(Icons.smartphone_outlined, size: 16, color: BezelColors.textTertiary)
            : Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.tip, required this.onTap, this.danger = false});

  final IconData icon;
  final String tip;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      child: Pressable(
        onTap: onTap,
        label: tip,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 16, color: danger ? BezelColors.danger : BezelColors.textSecondary),
        ),
      ),
    );
  }
}
