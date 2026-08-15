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

    SceneState currentState = baseState;
    Duration accumulatedTime = Duration.zero;

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final blockDuration = block.timeline.duration;

      // The raw state if we evaluate this block at t=0
      final initialRawState = block.timeline.evaluateAt(Duration.zero, baseState: baseState);
      
      // Calculate offsets between where we are (currentState) and where this block WANTS to start
      final offsetX = currentState.positionX - initialRawState.positionX;
      final offsetY = currentState.positionY - initialRawState.positionY;
      final offsetScale = currentState.scale - initialRawState.scale;
      final offsetRotation = currentState.rotation - initialRawState.rotation;
      final offsetOpacity = currentState.opacity - initialRawState.opacity;

      if (time >= accumulatedTime && time <= accumulatedTime + blockDuration) {
        final localTime = time - accumulatedTime;
        final rawState = block.timeline.evaluateAt(localTime, baseState: baseState);
        
        return SceneState(
          positionX: rawState.positionX + offsetX,
          positionY: rawState.positionY + offsetY,
          scale: rawState.scale + offsetScale,
          rotation: rawState.rotation + offsetRotation,
          opacity: (rawState.opacity + offsetOpacity).clamp(0.0, 1.0),
        );
      }

      // If we've surpassed this block, its final state becomes the new currentState
      final finalRawState = block.timeline.evaluateAt(blockDuration, baseState: baseState);
      currentState = SceneState(
        positionX: finalRawState.positionX + offsetX,
        positionY: finalRawState.positionY + offsetY,
        scale: finalRawState.scale + offsetScale,
        rotation: finalRawState.rotation + offsetRotation,
        opacity: (finalRawState.opacity + offsetOpacity).clamp(0.0, 1.0),
      );

      accumulatedTime += blockDuration;
    }

    return currentState;
  }
}
