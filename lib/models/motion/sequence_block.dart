import 'timeline.dart';

class SequenceBlock {
  final String id;
  final String name;
  final Timeline timeline;

  SequenceBlock({String? id, required this.name, required this.timeline})
    : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  SequenceBlock copyWith({String? name, Timeline? timeline}) {
    return SequenceBlock(
      id: id,
      name: name ?? this.name,
      timeline: timeline ?? this.timeline,
    );
  }
}
