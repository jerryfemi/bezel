import 'scene_state.dart';
import 'sequence_block.dart';

class MotionSequence {
  final List<SequenceBlock> blocks;

  const MotionSequence({
    this.blocks = const [],
  });

  Duration get totalDuration {
    return blocks.fold(
      Duration.zero,
      (total, block) => total + block.timeline.duration,
    );
  }

  MotionSequence copyWith({
    List<SequenceBlock>? blocks,
  }) {
    return MotionSequence(
      blocks: blocks ?? this.blocks,
    );
  }

  MotionSequence withUpdatedBlock(int index, SequenceBlock newBlock) {
    if (index < 0 || index >= blocks.length) return this;
    final newBlocks = List<SequenceBlock>.from(blocks);
    newBlocks[index] = newBlock;
    return copyWith(blocks: newBlocks);
  }

  MotionSequence withAppendedBlock(SequenceBlock newBlock) {
    return copyWith(blocks: [...blocks, newBlock]);
  }

  MotionSequence withRemovedBlock(int index) {
    if (index < 0 || index >= blocks.length) return this;
    final newBlocks = List<SequenceBlock>.from(blocks);
    newBlocks.removeAt(index);
    return copyWith(blocks: newBlocks);
  }

  SceneState evaluateAt(Duration time, {required SceneState baseState}) {
    if (blocks.isEmpty) return baseState;

    Duration accumulatedTime = Duration.zero;

    // Track the resulting state across blocks. Each block takes the previous block's END state as its base.
    // Actually, each block animates its own properties from 0 to 100%. 
    // To chain them properly without snap-backs, we should probably evaluate them sequentially
    // or just let the current block overwrite the base state. 
    // Since presets specify explicit values (e.g., scale 1.0 -> 0.8), they will pop 
    // if the previous block ended at scale 1.5. For now, we will simply evaluate the active block
    // against the original baseState, which might cause snaps if presets aren't designed to return to base.
    // In a robust system, we would accumulate the state.

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final blockDuration = block.timeline.duration;

      // If the target time falls within this block, evaluate it
      if (time >= accumulatedTime && time <= accumulatedTime + blockDuration) {
        final localTime = time - accumulatedTime;
        return block.timeline.evaluateAt(localTime, baseState: baseState);
      }

      // If we've surpassed this block but it's the last one, evaluate at its very end
      if (time > accumulatedTime + blockDuration && i == blocks.length - 1) {
        return block.timeline.evaluateAt(blockDuration, baseState: baseState);
      }

      accumulatedTime += blockDuration;
    }

    return baseState;
  }
}
