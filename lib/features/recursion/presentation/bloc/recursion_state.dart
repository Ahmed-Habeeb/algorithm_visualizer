import '../../domain/entities/recursion_algorithm_entity.dart';
import '../../domain/entities/recursion_tree_node_entity.dart';
import '../../domain/entities/recursion_frame_entity.dart';

sealed class RecursionState {}

class RecursionInitial extends RecursionState {}

class RecursionLoading extends RecursionState {}

class RecursionReady extends RecursionState {
  final List<RecursionAlgorithmEntity> algorithms;
  final RecursionAlgorithmEntity? selectedAlgorithm;
  final int input;
  final RecursionTreeNodeEntity? tree;
  final List<RecursionFrameEntity> frames;
  final int currentFrameIndex;
  final bool isPlaying;
  final double speed;
  final String? result;

  RecursionReady({
    required this.algorithms,
    this.selectedAlgorithm,
    this.input = 5,
    this.tree,
    this.frames = const [],
    this.currentFrameIndex = 0,
    this.isPlaying = false,
    this.speed = 1.0,
    this.result,
  });

  RecursionFrameEntity? get currentFrame {
    if (frames.isEmpty || currentFrameIndex >= frames.length) return null;
    return frames[currentFrameIndex];
  }

  bool get canStepForward => currentFrameIndex < frames.length - 1;
  bool get canStepBackward => currentFrameIndex > 0;
  bool get isComplete => currentFrameIndex >= frames.length - 1;

  RecursionReady copyWith({
    List<RecursionAlgorithmEntity>? algorithms,
    RecursionAlgorithmEntity? selectedAlgorithm,
    int? input,
    RecursionTreeNodeEntity? tree,
    List<RecursionFrameEntity>? frames,
    int? currentFrameIndex,
    bool? isPlaying,
    double? speed,
    String? result,
  }) {
    return RecursionReady(
      algorithms: algorithms ?? this.algorithms,
      selectedAlgorithm: selectedAlgorithm ?? this.selectedAlgorithm,
      input: input ?? this.input,
      tree: tree ?? this.tree,
      frames: frames ?? this.frames,
      currentFrameIndex: currentFrameIndex ?? this.currentFrameIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      result: result ?? this.result,
    );
  }
}

class RecursionError extends RecursionState {
  final String message;
  RecursionError(this.message);
}
