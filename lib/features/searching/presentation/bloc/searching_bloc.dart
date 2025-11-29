import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/algorithms/binary_search.dart';
import '../../data/algorithms/linear_search.dart';
import '../../domain/entities/search_visualization_frame_entity.dart';
import 'searching_event.dart';
import 'searching_state.dart';

class SearchingBloc extends Bloc<SearchingEvent, SearchingState> {
  Timer? _playbackTimer;

  SearchingBloc() : super(const SearchingState()) {
    on<LoadSearchingAlgorithms>(_onLoadAlgorithms);
    on<SelectAlgorithm>(_onSelectAlgorithm);
    on<RunSearch>(_onRunSearch);
    on<PlayVisualization>(_onPlayVisualization);
    on<PauseVisualization>(_onPauseVisualization);
    on<StepForward>(_onStepForward);
    on<StepBackward>(_onStepBackward);
    on<SetSpeed>(_onSetSpeed);
    on<RandomizeInput>(_onRandomizeInput);
    on<SetTarget>(_onSetTarget);
    on<ResetVisualization>(_onResetVisualization);
  }

  void _onLoadAlgorithms(
    LoadSearchingAlgorithms event,
    Emitter<SearchingState> emit,
  ) {
    final algorithms = [
      LinearSearch.algorithm,
      BinarySearch.algorithm,
    ];
    emit(state.copyWith(algorithms: algorithms));
  }

  void _onSelectAlgorithm(
    SelectAlgorithm event,
    Emitter<SearchingState> emit,
  ) {
    final algorithm = state.algorithms.firstWhere(
      (a) => a.id == event.algorithmId,
    );
    emit(state.copyWith(
      selectedAlgorithm: algorithm,
      frames: [],
      currentFrameIndex: 0,
      isPlaying: false,
    ));
    _playbackTimer?.cancel();
  }

  void _onRunSearch(
    RunSearch event,
    Emitter<SearchingState> emit,
  ) {
    if (state.selectedAlgorithm == null) return;

    _playbackTimer?.cancel();

    List<SearchVisualizationFrameEntity> frames;

    switch (state.selectedAlgorithm!.id) {
      case 'linear_search':
        frames = LinearSearch.search(event.input, event.target);
        break;
      case 'binary_search':
        frames = BinarySearch.search(event.input, event.target);
        break;
      default:
        frames = [];
    }

    emit(state.copyWith(
      frames: frames,
      currentFrameIndex: 0,
      isPlaying: false,
      currentInput: event.input,
      target: event.target,
    ));
  }

  void _onPlayVisualization(
    PlayVisualization event,
    Emitter<SearchingState> emit,
  ) {
    if (!state.hasFrames || !state.canStepForward) return;

    emit(state.copyWith(isPlaying: true));
    _startPlaybackTimer();
  }

  void _onPauseVisualization(
    PauseVisualization event,
    Emitter<SearchingState> emit,
  ) {
    _playbackTimer?.cancel();
    emit(state.copyWith(isPlaying: false));
  }

  void _onStepForward(
    StepForward event,
    Emitter<SearchingState> emit,
  ) {
    if (!state.canStepForward) {
      _playbackTimer?.cancel();
      emit(state.copyWith(isPlaying: false));
      return;
    }
    emit(state.copyWith(currentFrameIndex: state.currentFrameIndex + 1));
  }

  void _onStepBackward(
    StepBackward event,
    Emitter<SearchingState> emit,
  ) {
    if (!state.canStepBackward) return;
    _playbackTimer?.cancel();
    emit(state.copyWith(
      currentFrameIndex: state.currentFrameIndex - 1,
      isPlaying: false,
    ));
  }

  void _onSetSpeed(
    SetSpeed event,
    Emitter<SearchingState> emit,
  ) {
    emit(state.copyWith(speed: event.speed));
    if (state.isPlaying) {
      _playbackTimer?.cancel();
      _startPlaybackTimer();
    }
  }

  void _onRandomizeInput(
    RandomizeInput event,
    Emitter<SearchingState> emit,
  ) {
    _playbackTimer?.cancel();
    final random = Random();
    final input = List.generate(event.size, (_) => random.nextInt(100) + 1);
    final target = input[random.nextInt(input.length)];

    emit(state.copyWith(
      currentInput: input,
      target: target,
      frames: [],
      currentFrameIndex: 0,
      isPlaying: false,
    ));
  }

  void _onSetTarget(
    SetTarget event,
    Emitter<SearchingState> emit,
  ) {
    emit(state.copyWith(target: event.target));
  }

  void _onResetVisualization(
    ResetVisualization event,
    Emitter<SearchingState> emit,
  ) {
    _playbackTimer?.cancel();
    emit(state.copyWith(
      currentFrameIndex: 0,
      isPlaying: false,
    ));
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    final interval = Duration(milliseconds: (800 / state.speed).round());
    _playbackTimer = Timer.periodic(interval, (_) {
      add(StepForward());
    });
  }

  @override
  Future<void> close() {
    _playbackTimer?.cancel();
    return super.close();
  }
}
