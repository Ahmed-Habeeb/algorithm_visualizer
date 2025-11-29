import '../../domain/entities/dp_algorithm_entity.dart';
import '../../domain/entities/dp_frame_entity.dart';

sealed class DPState {}

class DPInitial extends DPState {}

class DPLoading extends DPState {}

class DPReady extends DPState {
  final List<DPAlgorithmEntity> algorithms;
  final DPAlgorithmEntity? selectedAlgorithm;
  final Map<String, dynamic> input;
  final List<DPFrameEntity> frames;
  final int currentFrameIndex;
  final bool isPlaying;
  final double speed;
  final String? result;

  DPReady({
    required this.algorithms,
    this.selectedAlgorithm,
    this.input = const {},
    this.frames = const [],
    this.currentFrameIndex = 0,
    this.isPlaying = false,
    this.speed = 1.0,
    this.result,
  });

  DPFrameEntity? get currentFrame {
    if (frames.isEmpty || currentFrameIndex >= frames.length) return null;
    return frames[currentFrameIndex];
  }

  bool get canStepForward => currentFrameIndex < frames.length - 1;
  bool get canStepBackward => currentFrameIndex > 0;
  bool get isComplete => currentFrameIndex >= frames.length - 1;

  DPReady copyWith({
    List<DPAlgorithmEntity>? algorithms,
    DPAlgorithmEntity? selectedAlgorithm,
    Map<String, dynamic>? input,
    List<DPFrameEntity>? frames,
    int? currentFrameIndex,
    bool? isPlaying,
    double? speed,
    String? result,
  }) {
    return DPReady(
      algorithms: algorithms ?? this.algorithms,
      selectedAlgorithm: selectedAlgorithm ?? this.selectedAlgorithm,
      input: input ?? this.input,
      frames: frames ?? this.frames,
      currentFrameIndex: currentFrameIndex ?? this.currentFrameIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      result: result ?? this.result,
    );
  }
}

class DPError extends DPState {
  final String message;
  DPError(this.message);
}
