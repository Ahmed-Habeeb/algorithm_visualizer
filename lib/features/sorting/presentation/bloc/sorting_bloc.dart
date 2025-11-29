import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/algorithms/bubble_sort.dart';
import '../../data/algorithms/heap_sort.dart';
import '../../data/algorithms/insertion_sort.dart';
import '../../data/algorithms/merge_sort.dart';
import '../../data/algorithms/quick_sort.dart';
import '../../data/algorithms/selection_sort.dart';
import '../../domain/entities/sorting_algorithm_entity.dart';
import '../../domain/interfaces/sorting_algorithm.dart';
import 'sorting_event.dart';
import 'sorting_state.dart';

class SortingBloc extends Bloc<SortingEvent, SortingState> {
  Timer? _playTimer;

  // Map of algorithm id to SortingAlgorithm implementation
  final Map<String, SortingAlgorithm> _algorithmMap = {
    'bubble_sort': BubbleSort(),
    'quick_sort': QuickSort(),
    'merge_sort': MergeSort(),
    'insertion_sort': InsertionSort(),
    'selection_sort': SelectionSort(),
    'heap_sort': HeapSort(),
  };

  SortingBloc() : super(SortingInitial()) {
    on<LoadSortingAlgorithms>(_onLoadAlgorithms);
    on<SelectAlgorithm>(_onSelectAlgorithm);
    on<RunAlgorithm>(_onRunAlgorithm);
    on<PlayVisualization>(_onPlay);
    on<PauseVisualization>(_onPause);
    on<StepForward>(_onStepForward);
    on<StepBackward>(_onStepBackward);
    on<ResetVisualization>(_onReset);
    on<SetSpeed>(_onSetSpeed);
    on<SetStep>(_onSetStep);
    on<RandomizeInput>(_onRandomizeInput);
  }

  List<SortingAlgorithmEntity> get _algorithms =>
      _algorithmMap.values.map((a) => a.algorithm).toList();

  void _onLoadAlgorithms(
    LoadSortingAlgorithms event,
    Emitter<SortingState> emit,
  ) {
    emit(SortingAlgorithmsLoaded(_algorithms));
  }

  void _onSelectAlgorithm(
    SelectAlgorithm event,
    Emitter<SortingState> emit,
  ) {
    final sortingAlgorithm = _algorithmMap[event.algorithmId];
    if (sortingAlgorithm == null) return;

    final inputData = _generateRandomArray(100);
    final frames = sortingAlgorithm.sort(inputData);

    emit(SortingVisualizationReady(
      algorithm: sortingAlgorithm.algorithm,
      frames: frames,
      currentStep: 0,
      isPlaying: false,
      speed: 1.0,
      inputData: inputData,
    ));
  }

  void _onRunAlgorithm(
    RunAlgorithm event,
    Emitter<SortingState> emit,
  ) {
    if (state is SortingVisualizationReady) {
      final currentState = state as SortingVisualizationReady;
      final sortingAlgorithm = _algorithmMap[currentState.algorithm.id];
      if (sortingAlgorithm == null) return;

      final frames = sortingAlgorithm.sort(event.input);

      emit(currentState.copyWith(
        frames: frames,
        currentStep: 0,
        isPlaying: false,
        inputData: event.input,
      ));
    }
  }

  void _onPlay(
    PlayVisualization event,
    Emitter<SortingState> emit,
  ) {
    if (state is SortingVisualizationReady) {
      final currentState = state as SortingVisualizationReady;

      if (currentState.isComplete) {
        // Reset to beginning if at the end
        emit(currentState.copyWith(currentStep: 0, isPlaying: true));
      } else {
        emit(currentState.copyWith(isPlaying: true));
      }

      _startPlayTimer();
    }
  }

  void _onPause(
    PauseVisualization event,
    Emitter<SortingState> emit,
  ) {
    _stopPlayTimer();
    if (state is SortingVisualizationReady) {
      final currentState = state as SortingVisualizationReady;
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  void _onStepForward(
    StepForward event,
    Emitter<SortingState> emit,
  ) {
    if (state is SortingVisualizationReady) {
      final currentState = state as SortingVisualizationReady;
      if (currentState.canStepForward) {
        emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
      } else {
        _stopPlayTimer();
        emit(currentState.copyWith(isPlaying: false));
      }
    }
  }

  void _onStepBackward(
    StepBackward event,
    Emitter<SortingState> emit,
  ) {
    if (state is SortingVisualizationReady) {
      final currentState = state as SortingVisualizationReady;
      if (currentState.canStepBack) {
        emit(currentState.copyWith(currentStep: currentState.currentStep - 1));
      }
    }
  }

  void _onReset(
    ResetVisualization event,
    Emitter<SortingState> emit,
  ) {
    _stopPlayTimer();
    if (state is SortingVisualizationReady) {
      final currentState = state as SortingVisualizationReady;
      emit(currentState.copyWith(currentStep: 0, isPlaying: false));
    }
  }

  void _onSetSpeed(
    SetSpeed event,
    Emitter<SortingState> emit,
  ) {
    if (state is SortingVisualizationReady) {
      final currentState = state as SortingVisualizationReady;
      emit(currentState.copyWith(speed: event.speed));

      if (currentState.isPlaying) {
        _stopPlayTimer();
        _startPlayTimer();
      }
    }
  }

  void _onSetStep(
    SetStep event,
    Emitter<SortingState> emit,
  ) {
    if (state is SortingVisualizationReady) {
      final currentState = state as SortingVisualizationReady;
      final step = event.step.clamp(0, currentState.frames.length - 1);
      emit(currentState.copyWith(currentStep: step));
    }
  }

  void _onRandomizeInput(
    RandomizeInput event,
    Emitter<SortingState> emit,
  ) {
    if (state is SortingVisualizationReady) {
      final currentState = state as SortingVisualizationReady;
      final sortingAlgorithm = _algorithmMap[currentState.algorithm.id];
      if (sortingAlgorithm == null) return;

      final newInput = _generateRandomArray(event.size);
      final frames = sortingAlgorithm.sort(newInput);

      _stopPlayTimer();
      emit(currentState.copyWith(
        frames: frames,
        currentStep: 0,
        isPlaying: false,
        inputData: newInput,
      ));
    }
  }

  void _startPlayTimer() {
    _stopPlayTimer();
    if (state is SortingVisualizationReady) {
      final currentState = state as SortingVisualizationReady;
      final interval = Duration(
        milliseconds: (500 / currentState.speed).round(),
      );

      _playTimer = Timer.periodic(interval, (_) {
        add(StepForward());
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
