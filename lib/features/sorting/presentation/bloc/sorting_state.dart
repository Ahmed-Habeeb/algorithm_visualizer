import 'package:equatable/equatable.dart';

import '../../domain/entities/sorting_algorithm_entity.dart';
import '../../domain/entities/visualization_frame_entity.dart';

sealed class SortingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SortingInitial extends SortingState {}

class SortingLoading extends SortingState {}

class SortingAlgorithmsLoaded extends SortingState {
  final List<SortingAlgorithmEntity> algorithms;

  SortingAlgorithmsLoaded(this.algorithms);

  @override
  List<Object?> get props => [algorithms];
}

class SortingVisualizationReady extends SortingState {
  final SortingAlgorithmEntity algorithm;
  final List<VisualizationFrameEntity> frames;
  final int currentStep;
  final bool isPlaying;
  final double speed;
  final List<int> inputData;

  SortingVisualizationReady({
    required this.algorithm,
    required this.frames,
    required this.currentStep,
    required this.isPlaying,
    required this.speed,
    required this.inputData,
  });

  VisualizationFrameEntity get currentFrame => frames[currentStep];

  bool get canStepBack => currentStep > 0;
  bool get canStepForward => currentStep < frames.length - 1;
  bool get isComplete => currentStep >= frames.length - 1;

  SortingVisualizationReady copyWith({
    SortingAlgorithmEntity? algorithm,
    List<VisualizationFrameEntity>? frames,
    int? currentStep,
    bool? isPlaying,
    double? speed,
    List<int>? inputData,
  }) {
    return SortingVisualizationReady(
      algorithm: algorithm ?? this.algorithm,
      frames: frames ?? this.frames,
      currentStep: currentStep ?? this.currentStep,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      inputData: inputData ?? this.inputData,
    );
  }

  @override
  List<Object?> get props =>
      [algorithm, frames, currentStep, isPlaying, speed, inputData];
}

class SortingError extends SortingState {
  final String message;

  SortingError(this.message);

  @override
  List<Object?> get props => [message];
}
