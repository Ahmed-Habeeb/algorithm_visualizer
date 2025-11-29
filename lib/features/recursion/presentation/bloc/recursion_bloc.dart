import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recursion_algorithm_entity.dart';
import '../../domain/interfaces/recursion_algorithm.dart';
import '../../data/algorithms/fibonacci_algorithm.dart';
import '../../data/algorithms/factorial_algorithm.dart';
import '../../data/algorithms/tower_of_hanoi_algorithm.dart';
import 'recursion_event.dart';
import 'recursion_state.dart';

class RecursionBloc extends Bloc<RecursionEvent, RecursionState> {
  Timer? _playbackTimer;
  final Map<String, RecursionAlgorithm> _algorithmImplementations = {
    'fibonacci': FibonacciAlgorithm(),
    'factorial': FactorialAlgorithm(),
    'tower_of_hanoi': TowerOfHanoiAlgorithm(),
  };

  RecursionBloc() : super(RecursionInitial()) {
    on<LoadAlgorithms>(_onLoadAlgorithms);
    on<SelectAlgorithm>(_onSelectAlgorithm);
    on<SetInput>(_onSetInput);
    on<BuildTree>(_onBuildTree);
    on<StartVisualization>(_onStartVisualization);
    on<PauseVisualization>(_onPauseVisualization);
    on<ResumeVisualization>(_onResumeVisualization);
    on<StopVisualization>(_onStopVisualization);
    on<StepForward>(_onStepForward);
    on<StepBackward>(_onStepBackward);
    on<SetSpeed>(_onSetSpeed);
    on<GoToFrame>(_onGoToFrame);
    on<ResetVisualization>(_onResetVisualization);
  }

  void _onLoadAlgorithms(LoadAlgorithms event, Emitter<RecursionState> emit) {
    emit(RecursionLoading());
    final algorithms = RecursionAlgorithmEntity.getAlgorithms();
    emit(RecursionReady(algorithms: algorithms));
  }

  void _onSelectAlgorithm(SelectAlgorithm event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady) {
      _cancelPlayback();
      final algorithm = currentState.algorithms.firstWhere(
        (a) => a.id == event.algorithmId,
      );

      // Set appropriate default input based on algorithm
      int defaultInput;
      switch (event.algorithmId) {
        case 'fibonacci':
          defaultInput = 5;
          break;
        case 'factorial':
          defaultInput = 5;
          break;
        case 'tower_of_hanoi':
          defaultInput = 3;
          break;
        default:
          defaultInput = 5;
      }

      emit(currentState.copyWith(
        selectedAlgorithm: algorithm,
        input: defaultInput,
        tree: null,
        frames: [],
        currentFrameIndex: 0,
        isPlaying: false,
        result: null,
      ));
    }
  }

  void _onSetInput(SetInput event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady) {
      _cancelPlayback();
      emit(currentState.copyWith(
        input: event.input,
        tree: null,
        frames: [],
        currentFrameIndex: 0,
        isPlaying: false,
        result: null,
      ));
    }
  }

  void _onBuildTree(BuildTree event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady && currentState.selectedAlgorithm != null) {
      _cancelPlayback();

      final algorithmId = currentState.selectedAlgorithm!.id;
      final implementation = _algorithmImplementations[algorithmId];

      if (implementation != null) {
        final tree = implementation.buildTree(currentState.input);
        final frames = implementation.generateFrames(tree);

        // Calculate final result
        String? result;
        if (frames.isNotEmpty) {
          final lastFrame = frames.last;
          if (lastFrame.returnValues.isNotEmpty) {
            result = lastFrame.returnValues.values.first;
          }
        }

        emit(currentState.copyWith(
          tree: tree,
          frames: frames,
          currentFrameIndex: 0,
          isPlaying: false,
          result: result,
        ));
      }
    }
  }

  void _onStartVisualization(StartVisualization event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady && currentState.frames.isNotEmpty) {
      emit(currentState.copyWith(isPlaying: true));
      _startPlayback();
    }
  }

  void _onPauseVisualization(PauseVisualization event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady) {
      _cancelPlayback();
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  void _onResumeVisualization(ResumeVisualization event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady && !currentState.isComplete) {
      emit(currentState.copyWith(isPlaying: true));
      _startPlayback();
    }
  }

  void _onStopVisualization(StopVisualization event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady) {
      _cancelPlayback();
      emit(currentState.copyWith(
        currentFrameIndex: 0,
        isPlaying: false,
      ));
    }
  }

  void _onStepForward(StepForward event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady && currentState.canStepForward) {
      _cancelPlayback();
      emit(currentState.copyWith(
        currentFrameIndex: currentState.currentFrameIndex + 1,
        isPlaying: false,
      ));
    }
  }

  void _onStepBackward(StepBackward event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady && currentState.canStepBackward) {
      _cancelPlayback();
      emit(currentState.copyWith(
        currentFrameIndex: currentState.currentFrameIndex - 1,
        isPlaying: false,
      ));
    }
  }

  void _onSetSpeed(SetSpeed event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady) {
      emit(currentState.copyWith(speed: event.speed));
      if (currentState.isPlaying) {
        _cancelPlayback();
        _startPlayback();
      }
    }
  }

  void _onGoToFrame(GoToFrame event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady) {
      final index = event.frameIndex.clamp(0, currentState.frames.length - 1);
      emit(currentState.copyWith(currentFrameIndex: index));
    }
  }

  void _onResetVisualization(ResetVisualization event, Emitter<RecursionState> emit) {
    final currentState = state;
    if (currentState is RecursionReady) {
      _cancelPlayback();
      emit(currentState.copyWith(
        tree: null,
        frames: [],
        currentFrameIndex: 0,
        isPlaying: false,
        result: null,
      ));
    }
  }

  void _startPlayback() {
    final currentState = state;
    if (currentState is RecursionReady) {
      final interval = Duration(milliseconds: (1000 / currentState.speed).round());
      _playbackTimer = Timer.periodic(interval, (_) {
        if (state is RecursionReady) {
          final s = state as RecursionReady;
          if (s.canStepForward) {
            add(StepForward());
          } else {
            add(PauseVisualization());
          }
        }
      });
    }
  }

  void _cancelPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  @override
  Future<void> close() {
    _cancelPlayback();
    return super.close();
  }
}
