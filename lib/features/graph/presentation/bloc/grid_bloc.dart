import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/algorithms/grid_bfs.dart';
import '../../data/algorithms/grid_dfs.dart';
import '../../data/algorithms/grid_dijkstra.dart';
import '../../data/algorithms/grid_a_star.dart';
import '../../domain/entities/grid_entity.dart';
import '../../domain/entities/grid_visualization_frame.dart';
import '../../domain/entities/graph_algorithm_entity.dart';
import '../../domain/interfaces/grid_algorithm.dart';

// Events
sealed class GridEvent {}

class SelectAlgorithm extends GridEvent {
  final String algorithmId;
  SelectAlgorithm(this.algorithmId);
}

class InitializeGrid extends GridEvent {
  final int width;
  final int height;
  InitializeGrid({this.width = 20, this.height = 20});
}

class ToggleObstacle extends GridEvent {
  final int x;
  final int y;
  ToggleObstacle(this.x, this.y);
}

class AddObstacle extends GridEvent {
  final int x;
  final int y;
  AddObstacle(this.x, this.y);
}

class RemoveObstacle extends GridEvent {
  final int x;
  final int y;
  RemoveObstacle(this.x, this.y);
}

class SetGridStart extends GridEvent {
  final int x;
  final int y;
  SetGridStart(this.x, this.y);
}

class SetGridEnd extends GridEvent {
  final int x;
  final int y;
  SetGridEnd(this.x, this.y);
}

class ClearObstacles extends GridEvent {}

class ClearGrid extends GridEvent {}

class ClearVisualization extends GridEvent {}

class RunAlgorithm extends GridEvent {}

class PlayVisualization extends GridEvent {}

class PauseVisualization extends GridEvent {}

class StepForward extends GridEvent {}

class StepBackward extends GridEvent {}

class SetStep extends GridEvent {
  final int step;
  SetStep(this.step);
}

class ResetVisualization extends GridEvent {}

class SetSpeed extends GridEvent {
  final double speed;
  SetSpeed(this.speed);
}

class TickAnimation extends GridEvent {}

// States
sealed class GridState {}

class GridInitial extends GridState {}

class GridReady extends GridState {
  final GraphAlgorithmEntity algorithm;
  final GridEntity grid;
  final List<GridVisualizationFrame> frames;
  final int currentStep;
  final bool isPlaying;
  final double speed;
  final bool hasRun;

  GridReady({
    required this.algorithm,
    required this.grid,
    this.frames = const [],
    this.currentStep = 0,
    this.isPlaying = false,
    this.speed = 1.0,
    this.hasRun = false,
  });

  GridVisualizationFrame? get currentFrame =>
      frames.isNotEmpty && currentStep < frames.length ? frames[currentStep] : null;

  bool get canStepBack => currentStep > 0;
  bool get canStepForward => currentStep < frames.length - 1;
  bool get canRun => grid.start != null && grid.end != null;

  GridReady copyWith({
    GraphAlgorithmEntity? algorithm,
    GridEntity? grid,
    List<GridVisualizationFrame>? frames,
    int? currentStep,
    bool? isPlaying,
    double? speed,
    bool? hasRun,
  }) {
    return GridReady(
      algorithm: algorithm ?? this.algorithm,
      grid: grid ?? this.grid,
      frames: frames ?? this.frames,
      currentStep: currentStep ?? this.currentStep,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      hasRun: hasRun ?? this.hasRun,
    );
  }
}

class GridError extends GridState {
  final String message;
  GridError(this.message);
}

// Bloc
class GridBloc extends Bloc<GridEvent, GridState> {
  Timer? _animationTimer;

  final Map<String, GridAlgorithm> _algorithmMap = {
    'bfs': GridBFS(),
    'dfs': GridDFS(),
    'dijkstra': GridDijkstra(),
    'a_star': GridAStar(),
  };

  GridBloc() : super(GridInitial()) {
    on<SelectAlgorithm>(_onSelectAlgorithm);
    on<InitializeGrid>(_onInitializeGrid);
    on<ToggleObstacle>(_onToggleObstacle);
    on<AddObstacle>(_onAddObstacle);
    on<RemoveObstacle>(_onRemoveObstacle);
    on<SetGridStart>(_onSetGridStart);
    on<SetGridEnd>(_onSetGridEnd);
    on<ClearObstacles>(_onClearObstacles);
    on<ClearGrid>(_onClearGrid);
    on<ClearVisualization>(_onClearVisualization);
    on<RunAlgorithm>(_onRunAlgorithm);
    on<PlayVisualization>(_onPlayVisualization);
    on<PauseVisualization>(_onPauseVisualization);
    on<StepForward>(_onStepForward);
    on<StepBackward>(_onStepBackward);
    on<SetStep>(_onSetStep);
    on<ResetVisualization>(_onResetVisualization);
    on<SetSpeed>(_onSetSpeed);
    on<TickAnimation>(_onTickAnimation);
  }

  @override
  Future<void> close() {
    _animationTimer?.cancel();
    return super.close();
  }

  void _onSelectAlgorithm(SelectAlgorithm event, Emitter<GridState> emit) {
    final algorithm = _algorithmMap[event.algorithmId];
    if (algorithm == null) {
      emit(GridError('Algorithm not found: ${event.algorithmId}'));
      return;
    }

    emit(GridReady(
      algorithm: algorithm.algorithm,
      grid: GridEntity.create(),
    ));
  }

  void _onInitializeGrid(InitializeGrid event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    _animationTimer?.cancel();

    emit(currentState.copyWith(
      grid: GridEntity.create(width: event.width, height: event.height),
      frames: [],
      currentStep: 0,
      isPlaying: false,
      hasRun: false,
    ));
  }

  void _onToggleObstacle(ToggleObstacle event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    emit(currentState.copyWith(
      grid: currentState.grid.toggleObstacle(event.x, event.y),
      frames: [],
      hasRun: false,
    ));
  }

  void _onAddObstacle(AddObstacle event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    emit(currentState.copyWith(
      grid: currentState.grid.addObstacle(event.x, event.y),
      frames: [],
      hasRun: false,
    ));
  }

  void _onRemoveObstacle(RemoveObstacle event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    emit(currentState.copyWith(
      grid: currentState.grid.removeObstacle(event.x, event.y),
      frames: [],
      hasRun: false,
    ));
  }

  void _onSetGridStart(SetGridStart event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    _animationTimer?.cancel();

    // Don't set start on an obstacle
    if (currentState.grid.obstacles.contains((event.x, event.y))) return;

    emit(currentState.copyWith(
      grid: currentState.grid.copyWith(start: (event.x, event.y)),
      frames: [],
      currentStep: 0,
      isPlaying: false,
      hasRun: false,
    ));
  }

  void _onSetGridEnd(SetGridEnd event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    _animationTimer?.cancel();

    // Don't set end on an obstacle
    if (currentState.grid.obstacles.contains((event.x, event.y))) return;

    emit(currentState.copyWith(
      grid: currentState.grid.copyWith(end: (event.x, event.y)),
      frames: [],
      currentStep: 0,
      isPlaying: false,
      hasRun: false,
    ));
  }

  void _onClearObstacles(ClearObstacles event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    _animationTimer?.cancel();

    emit(currentState.copyWith(
      grid: currentState.grid.clearObstacles(),
      frames: [],
      currentStep: 0,
      isPlaying: false,
      hasRun: false,
    ));
  }

  void _onClearGrid(ClearGrid event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    _animationTimer?.cancel();

    emit(currentState.copyWith(
      grid: currentState.grid.clear(),
      frames: [],
      currentStep: 0,
      isPlaying: false,
      hasRun: false,
    ));
  }

  void _onClearVisualization(ClearVisualization event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    _animationTimer?.cancel();

    emit(currentState.copyWith(
      frames: [],
      currentStep: 0,
      isPlaying: false,
      hasRun: false,
    ));
  }

  void _onRunAlgorithm(RunAlgorithm event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;
    if (!currentState.canRun) return;

    final algorithm = _algorithmMap[currentState.algorithm.id];
    if (algorithm == null) return;

    _animationTimer?.cancel();

    final frames = algorithm.findPath(
      currentState.grid,
      currentState.grid.start!,
      currentState.grid.end!,
    );

    emit(currentState.copyWith(
      frames: frames,
      currentStep: 0,
      isPlaying: false,
      hasRun: true,
    ));
  }

  void _onPlayVisualization(PlayVisualization event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;
    if (currentState.frames.isEmpty) return;

    _startAnimation(currentState.speed);
    emit(currentState.copyWith(isPlaying: true));
  }

  void _onPauseVisualization(PauseVisualization event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    _animationTimer?.cancel();
    emit(currentState.copyWith(isPlaying: false));
  }

  void _onStepForward(StepForward event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    if (currentState.canStepForward) {
      emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
    }
  }

  void _onStepBackward(StepBackward event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    if (currentState.canStepBack) {
      emit(currentState.copyWith(currentStep: currentState.currentStep - 1));
    }
  }

  void _onSetStep(SetStep event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    if (event.step >= 0 && event.step < currentState.frames.length) {
      emit(currentState.copyWith(currentStep: event.step));
    }
  }

  void _onResetVisualization(ResetVisualization event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    _animationTimer?.cancel();
    emit(currentState.copyWith(
      currentStep: 0,
      isPlaying: false,
    ));
  }

  void _onSetSpeed(SetSpeed event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    emit(currentState.copyWith(speed: event.speed));

    if (currentState.isPlaying) {
      _animationTimer?.cancel();
      _startAnimation(event.speed);
    }
  }

  void _onTickAnimation(TickAnimation event, Emitter<GridState> emit) {
    final currentState = state;
    if (currentState is! GridReady) return;

    if (currentState.canStepForward) {
      emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
    } else {
      _animationTimer?.cancel();
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  void _startAnimation(double speed) {
    _animationTimer?.cancel();
    final duration = Duration(milliseconds: (500 / speed).round());
    _animationTimer = Timer.periodic(duration, (_) {
      add(TickAnimation());
    });
  }
}
