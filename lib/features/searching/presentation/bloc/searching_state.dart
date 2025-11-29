import 'package:flutter/foundation.dart';

import '../../domain/entities/searching_algorithm_entity.dart';
import '../../domain/entities/search_visualization_frame_entity.dart';

@immutable
class SearchingState {
  final List<SearchingAlgorithmEntity> algorithms;
  final SearchingAlgorithmEntity? selectedAlgorithm;
  final List<SearchVisualizationFrameEntity> frames;
  final int currentFrameIndex;
  final bool isPlaying;
  final double speed;
  final List<int> currentInput;
  final int target;
  final bool isLoading;
  final String? error;

  const SearchingState({
    this.algorithms = const [],
    this.selectedAlgorithm,
    this.frames = const [],
    this.currentFrameIndex = 0,
    this.isPlaying = false,
    this.speed = 1.0,
    this.currentInput = const [],
    this.target = 0,
    this.isLoading = false,
    this.error,
  });

  SearchingState copyWith({
    List<SearchingAlgorithmEntity>? algorithms,
    SearchingAlgorithmEntity? selectedAlgorithm,
    List<SearchVisualizationFrameEntity>? frames,
    int? currentFrameIndex,
    bool? isPlaying,
    double? speed,
    List<int>? currentInput,
    int? target,
    bool? isLoading,
    String? error,
  }) {
    return SearchingState(
      algorithms: algorithms ?? this.algorithms,
      selectedAlgorithm: selectedAlgorithm ?? this.selectedAlgorithm,
      frames: frames ?? this.frames,
      currentFrameIndex: currentFrameIndex ?? this.currentFrameIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      currentInput: currentInput ?? this.currentInput,
      target: target ?? this.target,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  SearchVisualizationFrameEntity? get currentFrame {
    if (frames.isEmpty || currentFrameIndex >= frames.length) return null;
    return frames[currentFrameIndex];
  }

  bool get canStepForward => currentFrameIndex < frames.length - 1;
  bool get canStepBackward => currentFrameIndex > 0;
  bool get hasFrames => frames.isNotEmpty;
}
