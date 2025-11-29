import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dp_algorithm_entity.dart';
import '../../domain/entities/dp_frame_entity.dart';
import '../../domain/interfaces/dp_algorithm.dart';
import '../../data/algorithms/fibonacci_dp_algorithm.dart';
import '../../data/algorithms/lcs_algorithm.dart';
import '../../data/algorithms/knapsack_algorithm.dart';
import '../../data/algorithms/edit_distance_algorithm.dart';
import 'dp_event.dart';
import 'dp_state.dart';

class DPBloc extends Bloc<DPEvent, DPState> {
  Timer? _playbackTimer;
  final Map<String, DPAlgorithm> _algorithmImplementations = {
    'fibonacci_dp': FibonacciDPAlgorithm(),
    'lcs': LCSAlgorithm(),
    'knapsack': KnapsackAlgorithm(),
    'edit_distance': EditDistanceAlgorithm(),
  };

  DPBloc() : super(DPInitial()) {
    on<LoadAlgorithms>(_onLoadAlgorithms);
    on<SelectAlgorithm>(_onSelectAlgorithm);
    on<SetInput>(_onSetInput);
    on<RunAlgorithm>(_onRunAlgorithm);
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

  void _onLoadAlgorithms(LoadAlgorithms event, Emitter<DPState> emit) {
    emit(DPLoading());
    final algorithms = DPAlgorithmEntity.getAlgorithms();
    emit(DPReady(algorithms: algorithms));
  }

  void _onSelectAlgorithm(SelectAlgorithm event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady) {
      _cancelPlayback();
      final algorithm = currentState.algorithms.firstWhere(
        (a) => a.id == event.algorithmId,
      );

      // Set default input based on algorithm
      Map<String, dynamic> defaultInput;
      switch (event.algorithmId) {
        case 'fibonacci_dp':
          defaultInput = {'n': 8};
          break;
        case 'lcs':
          defaultInput = {'str1': 'ABCD', 'str2': 'AEBD'};
          break;
        case 'knapsack':
          defaultInput = {
            'items': [
              const KnapsackItem(name: 'A', weight: 2, value: 3),
              const KnapsackItem(name: 'B', weight: 3, value: 4),
              const KnapsackItem(name: 'C', weight: 4, value: 5),
              const KnapsackItem(name: 'D', weight: 5, value: 6),
            ],
            'capacity': 8,
          };
          break;
        case 'edit_distance':
          defaultInput = {'str1': 'CAT', 'str2': 'CUT'};
          break;
        default:
          defaultInput = {};
      }

      emit(currentState.copyWith(
        selectedAlgorithm: algorithm,
        input: defaultInput,
        frames: [],
        currentFrameIndex: 0,
        isPlaying: false,
        result: null,
      ));
    }
  }

  void _onSetInput(SetInput event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady) {
      _cancelPlayback();
      emit(currentState.copyWith(
        input: event.input,
        frames: [],
        currentFrameIndex: 0,
        isPlaying: false,
        result: null,
      ));
    }
  }

  void _onRunAlgorithm(RunAlgorithm event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady && currentState.selectedAlgorithm != null) {
      _cancelPlayback();

      final algorithmId = currentState.selectedAlgorithm!.id;
      final implementation = _algorithmImplementations[algorithmId];

      if (implementation != null) {
        final frames = implementation.generateFrames(currentState.input);

        String? result;
        if (frames.isNotEmpty) {
          final lastFrame = frames.last;
          result = lastFrame.explanation;
        }

        emit(currentState.copyWith(
          frames: frames,
          currentFrameIndex: 0,
          isPlaying: false,
          result: result,
        ));
      }
    }
  }

  void _onStartVisualization(StartVisualization event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady && currentState.frames.isNotEmpty) {
      emit(currentState.copyWith(isPlaying: true));
      _startPlayback();
    }
  }

  void _onPauseVisualization(PauseVisualization event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady) {
      _cancelPlayback();
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  void _onResumeVisualization(ResumeVisualization event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady && !currentState.isComplete) {
      emit(currentState.copyWith(isPlaying: true));
      _startPlayback();
    }
  }

  void _onStopVisualization(StopVisualization event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady) {
      _cancelPlayback();
      emit(currentState.copyWith(
        currentFrameIndex: 0,
        isPlaying: false,
      ));
    }
  }

  void _onStepForward(StepForward event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady && currentState.canStepForward) {
      _cancelPlayback();
      emit(currentState.copyWith(
        currentFrameIndex: currentState.currentFrameIndex + 1,
        isPlaying: false,
      ));
    }
  }

  void _onStepBackward(StepBackward event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady && currentState.canStepBackward) {
      _cancelPlayback();
      emit(currentState.copyWith(
        currentFrameIndex: currentState.currentFrameIndex - 1,
        isPlaying: false,
      ));
    }
  }

  void _onSetSpeed(SetSpeed event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady) {
      emit(currentState.copyWith(speed: event.speed));
      if (currentState.isPlaying) {
        _cancelPlayback();
        _startPlayback();
      }
    }
  }

  void _onGoToFrame(GoToFrame event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady) {
      final index = event.frameIndex.clamp(0, currentState.frames.length - 1);
      emit(currentState.copyWith(currentFrameIndex: index));
    }
  }

  void _onResetVisualization(ResetVisualization event, Emitter<DPState> emit) {
    final currentState = state;
    if (currentState is DPReady) {
      _cancelPlayback();
      emit(currentState.copyWith(
        frames: [],
        currentFrameIndex: 0,
        isPlaying: false,
        result: null,
      ));
    }
  }

  void _startPlayback() {
    final currentState = state;
    if (currentState is DPReady) {
      final interval = Duration(milliseconds: (800 / currentState.speed).round());
      _playbackTimer = Timer.periodic(interval, (_) {
        if (state is DPReady) {
          final s = state as DPReady;
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
