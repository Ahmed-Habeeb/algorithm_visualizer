import '../../domain/entities/data_structure_entity.dart';
import '../../domain/entities/ds_visualization_frame_entity.dart';

sealed class DSState {}

class DSInitial extends DSState {}

class DSLoading extends DSState {}

class DSReady extends DSState {
  final DataStructureEntity structure;
  final List<int> data;
  final List<DSVisualizationFrameEntity> frames;
  final int currentStep;
  final bool isPlaying;
  final double speed;
  final String? lastOperation;

  DSReady({
    required this.structure,
    this.data = const [],
    this.frames = const [],
    this.currentStep = 0,
    this.isPlaying = false,
    this.speed = 1.0,
    this.lastOperation,
  });

  DSVisualizationFrameEntity? get currentFrame =>
      frames.isNotEmpty && currentStep < frames.length ? frames[currentStep] : null;

  bool get canStepBack => currentStep > 0;
  bool get canStepForward => currentStep < frames.length - 1;

  DSReady copyWith({
    DataStructureEntity? structure,
    List<int>? data,
    List<DSVisualizationFrameEntity>? frames,
    int? currentStep,
    bool? isPlaying,
    double? speed,
    String? lastOperation,
  }) {
    return DSReady(
      structure: structure ?? this.structure,
      data: data ?? this.data,
      frames: frames ?? this.frames,
      currentStep: currentStep ?? this.currentStep,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      lastOperation: lastOperation ?? this.lastOperation,
    );
  }
}

class DSError extends DSState {
  final String message;
  DSError(this.message);
}
