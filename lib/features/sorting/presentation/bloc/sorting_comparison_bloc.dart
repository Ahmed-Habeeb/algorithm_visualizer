import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/algorithms/bubble_sort.dart';
import '../../data/algorithms/heap_sort.dart';
import '../../data/algorithms/insertion_sort.dart';
import '../../data/algorithms/merge_sort.dart';
import '../../data/algorithms/quick_sort.dart';
import '../../data/algorithms/selection_sort.dart';
import '../../domain/entities/sorting_algorithm_entity.dart';
import '../../domain/entities/sorting_comparison_result.dart';
import '../../domain/entities/visualization_frame_entity.dart';
import '../../domain/interfaces/sorting_algorithm.dart';

// Events
abstract class SortingComparisonEvent extends Equatable {
  const SortingComparisonEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSortingComparison extends SortingComparisonEvent {}

class SelectSortingAlgorithm extends SortingComparisonEvent {
  final String algorithmId;
  final bool selected;

  const SelectSortingAlgorithm(this.algorithmId, this.selected);

  @override
  List<Object?> get props => [algorithmId, selected];
}

class RunSortingComparison extends SortingComparisonEvent {}

class PlaySortingComparison extends SortingComparisonEvent {}

class PauseSortingComparison extends SortingComparisonEvent {}

class StepSortingForward extends SortingComparisonEvent {}

class StepSortingBackward extends SortingComparisonEvent {}

class ResetSortingComparison extends SortingComparisonEvent {}

class SetSortingComparisonStep extends SortingComparisonEvent {
  final int step;

  const SetSortingComparisonStep(this.step);

  @override
  List<Object?> get props => [step];
}

class SetSortingComparisonSpeed extends SortingComparisonEvent {
  final double speed;

  const SetSortingComparisonSpeed(this.speed);

  @override
  List<Object?> get props => [speed];
}

class SetSortingArraySize extends SortingComparisonEvent {
  final int size;

  const SetSortingArraySize(this.size);

  @override
  List<Object?> get props => [size];
}

class RandomizeSortingArray extends SortingComparisonEvent {}

class ClearSortingComparison extends SortingComparisonEvent {}

// States
abstract class SortingComparisonState extends Equatable {
  const SortingComparisonState();

  @override
  List<Object?> get props => [];
}

class SortingComparisonInitial extends SortingComparisonState {}

class SortingComparisonReady extends SortingComparisonState {
  final List<SortingAlgorithmEntity> availableAlgorithms;
  final Set<String> selectedAlgorithmIds;
  final List<int> inputData;
  final int arraySize;
  final Map<String, List<VisualizationFrameEntity>> algorithmFrames;
  final Map<String, SortingComparisonResult> results;
  final int currentStep;
  final int maxSteps;
  final bool isPlaying;
  final double speed;
  final bool hasRun;

  const SortingComparisonReady({
    required this.availableAlgorithms,
    required this.selectedAlgorithmIds,
    required this.inputData,
    required this.arraySize,
    required this.algorithmFrames,
    required this.results,
    required this.currentStep,
    required this.maxSteps,
    required this.isPlaying,
    required this.speed,
    required this.hasRun,
  });

  bool get canRun => selectedAlgorithmIds.length >= 2 && inputData.isNotEmpty;
  bool get canStepForward => currentStep < maxSteps - 1;
  bool get canStepBackward => currentStep > 0;

  VisualizationFrameEntity? getFrameForAlgorithm(String algorithmId) {
    final frames = algorithmFrames[algorithmId];
    if (frames == null || frames.isEmpty) return null;
    final frameIndex = currentStep.clamp(0, frames.length - 1);
    return frames[frameIndex];
  }

  SortingComparisonReady copyWith({
    List<SortingAlgorithmEntity>? availableAlgorithms,
    Set<String>? selectedAlgorithmIds,
    List<int>? inputData,
    int? arraySize,
    Map<String, List<VisualizationFrameEntity>>? algorithmFrames,
    Map<String, SortingComparisonResult>? results,
    int? currentStep,
    int? maxSteps,
    bool? isPlaying,
    double? speed,
    bool? hasRun,
  }) {
    return SortingComparisonReady(
      availableAlgorithms: availableAlgorithms ?? this.availableAlgorithms,
      selectedAlgorithmIds: selectedAlgorithmIds ?? this.selectedAlgorithmIds,
      inputData: inputData ?? this.inputData,
      arraySize: arraySize ?? this.arraySize,
      algorithmFrames: algorithmFrames ?? this.algorithmFrames,
      results: results ?? this.results,
      currentStep: currentStep ?? this.currentStep,
      maxSteps: maxSteps ?? this.maxSteps,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      hasRun: hasRun ?? this.hasRun,
    );
  }

  @override
  List<Object?> get props => [
        availableAlgorithms,
        selectedAlgorithmIds,
        inputData,
        arraySize,
        algorithmFrames,
        results,
        currentStep,
        maxSteps,
        isPlaying,
        speed,
        hasRun,
      ];
}

class SortingComparisonError extends SortingComparisonState {
  final String message;

  const SortingComparisonError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class SortingComparisonBloc
    extends Bloc<SortingComparisonEvent, SortingComparisonState> {
  Timer? _playTimer;

  final Map<String, SortingAlgorithm> _algorithmMap = {
    'bubble_sort': BubbleSort(),
    'quick_sort': QuickSort(),
    'merge_sort': MergeSort(),
    'insertion_sort': InsertionSort(),
    'selection_sort': SelectionSort(),
    'heap_sort': HeapSort(),
  };

  SortingComparisonBloc() : super(SortingComparisonInitial()) {
    on<InitializeSortingComparison>(_onInitialize);
    on<SelectSortingAlgorithm>(_onSelectAlgorithm);
    on<RunSortingComparison>(_onRun);
    on<PlaySortingComparison>(_onPlay);
    on<PauseSortingComparison>(_onPause);
    on<StepSortingForward>(_onStepForward);
    on<StepSortingBackward>(_onStepBackward);
    on<ResetSortingComparison>(_onReset);
    on<SetSortingComparisonStep>(_onSetStep);
    on<SetSortingComparisonSpeed>(_onSetSpeed);
    on<SetSortingArraySize>(_onSetArraySize);
    on<RandomizeSortingArray>(_onRandomize);
    on<ClearSortingComparison>(_onClear);

    add(InitializeSortingComparison());
  }

  List<SortingAlgorithmEntity> get _algorithms =>
      _algorithmMap.values.map((a) => a.algorithm).toList();

  void _onInitialize(
    InitializeSortingComparison event,
    Emitter<SortingComparisonState> emit,
  ) {
    final initialSize = 20;
    emit(SortingComparisonReady(
      availableAlgorithms: _algorithms,
      selectedAlgorithmIds: {'bubble_sort', 'quick_sort'},
      inputData: _generateRandomArray(initialSize),
      arraySize: initialSize,
      algorithmFrames: {},
      results: {},
      currentStep: 0,
      maxSteps: 0,
      isPlaying: false,
      speed: 1.0,
      hasRun: false,
    ));
  }

  void _onSelectAlgorithm(
    SelectSortingAlgorithm event,
    Emitter<SortingComparisonState> emit,
  ) {
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      final newSelection = Set<String>.from(currentState.selectedAlgorithmIds);

      if (event.selected) {
        if (newSelection.length < 4) {
          newSelection.add(event.algorithmId);
        }
      } else {
        if (newSelection.length > 2) {
          newSelection.remove(event.algorithmId);
        }
      }

      emit(currentState.copyWith(
        selectedAlgorithmIds: newSelection,
        algorithmFrames: {},
        results: {},
        currentStep: 0,
        maxSteps: 0,
        hasRun: false,
      ));
    }
  }

  void _onRun(
    RunSortingComparison event,
    Emitter<SortingComparisonState> emit,
  ) {
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;

      final Map<String, List<VisualizationFrameEntity>> allFrames = {};
      final Map<String, SortingComparisonResult> allResults = {};
      int maxSteps = 0;

      for (final algorithmId in currentState.selectedAlgorithmIds) {
        final algorithm = _algorithmMap[algorithmId];
        if (algorithm == null) continue;

        final inputCopy = List<int>.from(currentState.inputData);
        final stopwatch = Stopwatch()..start();
        final frames = algorithm.sort(inputCopy);
        stopwatch.stop();

        allFrames[algorithmId] = frames;
        if (frames.length > maxSteps) {
          maxSteps = frames.length;
        }

        // Count comparisons and swaps from frames
        int comparisons = 0;
        int swaps = 0;
        for (final frame in frames) {
          if (frame.operation.toLowerCase().contains('compar')) {
            comparisons++;
          }
          if (frame.operation.toLowerCase().contains('swap')) {
            swaps++;
          }
        }

        allResults[algorithmId] = SortingComparisonResult(
          algorithmId: algorithmId,
          algorithmName: algorithm.algorithm.name,
          totalSteps: frames.length,
          comparisons: comparisons,
          swaps: swaps,
          executionTime: stopwatch.elapsed,
          completed: true,
        );
      }

      emit(currentState.copyWith(
        algorithmFrames: allFrames,
        results: allResults,
        currentStep: 0,
        maxSteps: maxSteps,
        hasRun: true,
      ));
    }
  }

  void _onPlay(
    PlaySortingComparison event,
    Emitter<SortingComparisonState> emit,
  ) {
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;

      if (currentState.currentStep >= currentState.maxSteps - 1) {
        emit(currentState.copyWith(currentStep: 0, isPlaying: true));
      } else {
        emit(currentState.copyWith(isPlaying: true));
      }

      _startPlayTimer();
    }
  }

  void _onPause(
    PauseSortingComparison event,
    Emitter<SortingComparisonState> emit,
  ) {
    _stopPlayTimer();
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  void _onStepForward(
    StepSortingForward event,
    Emitter<SortingComparisonState> emit,
  ) {
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      if (currentState.canStepForward) {
        emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
      } else {
        _stopPlayTimer();
        emit(currentState.copyWith(isPlaying: false));
      }
    }
  }

  void _onStepBackward(
    StepSortingBackward event,
    Emitter<SortingComparisonState> emit,
  ) {
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      if (currentState.canStepBackward) {
        emit(currentState.copyWith(currentStep: currentState.currentStep - 1));
      }
    }
  }

  void _onReset(
    ResetSortingComparison event,
    Emitter<SortingComparisonState> emit,
  ) {
    _stopPlayTimer();
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      emit(currentState.copyWith(currentStep: 0, isPlaying: false));
    }
  }

  void _onSetStep(
    SetSortingComparisonStep event,
    Emitter<SortingComparisonState> emit,
  ) {
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      final step = event.step.clamp(0, currentState.maxSteps - 1);
      emit(currentState.copyWith(currentStep: step));
    }
  }

  void _onSetSpeed(
    SetSortingComparisonSpeed event,
    Emitter<SortingComparisonState> emit,
  ) {
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      emit(currentState.copyWith(speed: event.speed));

      if (currentState.isPlaying) {
        _stopPlayTimer();
        _startPlayTimer();
      }
    }
  }

  void _onSetArraySize(
    SetSortingArraySize event,
    Emitter<SortingComparisonState> emit,
  ) {
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      emit(currentState.copyWith(
        arraySize: event.size,
        inputData: _generateRandomArray(event.size),
        algorithmFrames: {},
        results: {},
        currentStep: 0,
        maxSteps: 0,
        hasRun: false,
      ));
    }
  }

  void _onRandomize(
    RandomizeSortingArray event,
    Emitter<SortingComparisonState> emit,
  ) {
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      _stopPlayTimer();
      emit(currentState.copyWith(
        inputData: _generateRandomArray(currentState.arraySize),
        algorithmFrames: {},
        results: {},
        currentStep: 0,
        maxSteps: 0,
        hasRun: false,
        isPlaying: false,
      ));
    }
  }

  void _onClear(
    ClearSortingComparison event,
    Emitter<SortingComparisonState> emit,
  ) {
    _stopPlayTimer();
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      emit(currentState.copyWith(
        algorithmFrames: {},
        results: {},
        currentStep: 0,
        maxSteps: 0,
        hasRun: false,
        isPlaying: false,
      ));
    }
  }

  void _startPlayTimer() {
    _stopPlayTimer();
    if (state is SortingComparisonReady) {
      final currentState = state as SortingComparisonReady;
      final interval = Duration(
        milliseconds: (300 / currentState.speed).round(),
      );

      _playTimer = Timer.periodic(interval, (_) {
        add(StepSortingForward());
      });
    }
  }

  void _stopPlayTimer() {
    _playTimer?.cancel();
    _playTimer = null;
  }

  List<int> _generateRandomArray(int size) {
    final random = Random();
    return List.generate(size, (_) => random.nextInt(100) + 1);
  }

  @override
  Future<void> close() {
    _stopPlayTimer();
    return super.close();
  }
}

/// Get color for each sorting algorithm
Color getSortingAlgorithmColor(String algorithmId) {
  switch (algorithmId) {
    case 'bubble_sort':
      return Colors.blue;
    case 'quick_sort':
      return Colors.green;
    case 'merge_sort':
      return Colors.orange;
    case 'insertion_sort':
      return Colors.purple;
    case 'selection_sort':
      return Colors.red;
    case 'heap_sort':
      return Colors.teal;
    default:
      return Colors.grey;
  }
}
