import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/algorithms/grid_a_star.dart';
import '../../data/algorithms/grid_bfs.dart';
import '../../data/algorithms/grid_dfs.dart';
import '../../data/algorithms/grid_dijkstra.dart';
import '../../domain/entities/algorithm_result.dart';
import '../../domain/entities/graph_algorithm_entity.dart';
import '../../domain/entities/grid_entity.dart';
import '../../domain/entities/grid_visualization_frame.dart';
import '../../domain/interfaces/grid_algorithm.dart';

// ==================== EVENTS ====================

abstract class ComparisonEvent {}

class InitializeComparison extends ComparisonEvent {}

class SelectAlgorithm extends ComparisonEvent {
  final String algorithmId;
  final bool selected;

  SelectAlgorithm(this.algorithmId, this.selected);
}

class UpdateComparisonGrid extends ComparisonEvent {
  final GridEntity grid;

  UpdateComparisonGrid(this.grid);
}

class ToggleComparisonObstacle extends ComparisonEvent {
  final int x;
  final int y;

  ToggleComparisonObstacle(this.x, this.y);
}

class AddComparisonObstacle extends ComparisonEvent {
  final int x;
  final int y;

  AddComparisonObstacle(this.x, this.y);
}

class RemoveComparisonObstacle extends ComparisonEvent {
  final int x;
  final int y;

  RemoveComparisonObstacle(this.x, this.y);
}

class SetComparisonStart extends ComparisonEvent {
  final int x;
  final int y;

  SetComparisonStart(this.x, this.y);
}

class SetComparisonEnd extends ComparisonEvent {
  final int x;
  final int y;

  SetComparisonEnd(this.x, this.y);
}

class ClearComparisonGrid extends ComparisonEvent {}

class ClearComparisonVisualization extends ComparisonEvent {}

class RunComparison extends ComparisonEvent {}

class PlayComparison extends ComparisonEvent {}

class PauseComparison extends ComparisonEvent {}

class StepComparisonForward extends ComparisonEvent {}

class StepComparisonBackward extends ComparisonEvent {}

class SetComparisonStep extends ComparisonEvent {
  final int step;

  SetComparisonStep(this.step);
}

class ResetComparison extends ComparisonEvent {}

class SetComparisonSpeed extends ComparisonEvent {
  final double speed;

  SetComparisonSpeed(this.speed);
}

class TickComparisonAnimation extends ComparisonEvent {}

class ResizeComparisonGrid extends ComparisonEvent {
  final int width;
  final int height;

  ResizeComparisonGrid(this.width, this.height);
}

// ==================== STATE ====================

abstract class ComparisonState {}

class ComparisonInitial extends ComparisonState {}

class ComparisonReady extends ComparisonState {
  final GridEntity grid;
  final List<GraphAlgorithmEntity> availableAlgorithms;
  final Set<String> selectedAlgorithmIds;
  final Map<String, List<GridVisualizationFrame>> algorithmFrames;
  final Map<String, AlgorithmResult> results;
  final int currentStep;
  final int maxSteps;
  final bool isPlaying;
  final bool hasRun;
  final double speed;

  ComparisonReady({
    required this.grid,
    required this.availableAlgorithms,
    required this.selectedAlgorithmIds,
    required this.algorithmFrames,
    required this.results,
    this.currentStep = 0,
    this.maxSteps = 0,
    this.isPlaying = false,
    this.hasRun = false,
    this.speed = 1.0,
  });

  ComparisonReady copyWith({
    GridEntity? grid,
    List<GraphAlgorithmEntity>? availableAlgorithms,
    Set<String>? selectedAlgorithmIds,
    Map<String, List<GridVisualizationFrame>>? algorithmFrames,
    Map<String, AlgorithmResult>? results,
    int? currentStep,
    int? maxSteps,
    bool? isPlaying,
    bool? hasRun,
    double? speed,
  }) {
    return ComparisonReady(
      grid: grid ?? this.grid,
      availableAlgorithms: availableAlgorithms ?? this.availableAlgorithms,
      selectedAlgorithmIds: selectedAlgorithmIds ?? this.selectedAlgorithmIds,
      algorithmFrames: algorithmFrames ?? this.algorithmFrames,
      results: results ?? this.results,
      currentStep: currentStep ?? this.currentStep,
      maxSteps: maxSteps ?? this.maxSteps,
      isPlaying: isPlaying ?? this.isPlaying,
      hasRun: hasRun ?? this.hasRun,
      speed: speed ?? this.speed,
    );
  }

  bool get canRun =>
      grid.start != null &&
      grid.end != null &&
      selectedAlgorithmIds.length >= 2;

  bool get canStepForward => currentStep < maxSteps - 1;

  bool get canStepBackward => currentStep > 0;

  GridVisualizationFrame? getFrameForAlgorithm(String algorithmId) {
    final frames = algorithmFrames[algorithmId];
    if (frames == null || frames.isEmpty) return null;
    if (currentStep >= frames.length) return frames.last;
    return frames[currentStep];
  }
}

class ComparisonError extends ComparisonState {
  final String message;

  ComparisonError(this.message);
}

// ==================== BLOC ====================

class ComparisonGridBloc extends Bloc<ComparisonEvent, ComparisonState> {
  final Map<String, GridAlgorithm> _algorithms = {
    'bfs': GridBFS(),
    'dfs': GridDFS(),
    'dijkstra': GridDijkstra(),
    'a_star': GridAStar(),
  };

  Timer? _animationTimer;

  ComparisonGridBloc() : super(ComparisonInitial()) {
    on<InitializeComparison>(_onInitialize);
    on<SelectAlgorithm>(_onSelectAlgorithm);
    on<UpdateComparisonGrid>(_onUpdateGrid);
    on<ToggleComparisonObstacle>(_onToggleObstacle);
    on<AddComparisonObstacle>(_onAddObstacle);
    on<RemoveComparisonObstacle>(_onRemoveObstacle);
    on<SetComparisonStart>(_onSetStart);
    on<SetComparisonEnd>(_onSetEnd);
    on<ClearComparisonGrid>(_onClearGrid);
    on<ClearComparisonVisualization>(_onClearVisualization);
    on<RunComparison>(_onRunComparison);
    on<PlayComparison>(_onPlayComparison);
    on<PauseComparison>(_onPauseComparison);
    on<StepComparisonForward>(_onStepForward);
    on<StepComparisonBackward>(_onStepBackward);
    on<SetComparisonStep>(_onSetStep);
    on<ResetComparison>(_onReset);
    on<SetComparisonSpeed>(_onSetSpeed);
    on<TickComparisonAnimation>(_onTickAnimation);
    on<ResizeComparisonGrid>(_onResizeGrid);

    // Initialize on creation
    add(InitializeComparison());
  }

  @override
  Future<void> close() {
    _animationTimer?.cancel();
    return super.close();
  }

  void _onInitialize(
    InitializeComparison event,
    Emitter<ComparisonState> emit,
  ) {
    final algorithms =
        _algorithms.values.map((a) => a.algorithm).toList();

    emit(ComparisonReady(
      grid: GridEntity.create(width: 15, height: 15),
      availableAlgorithms: algorithms,
      selectedAlgorithmIds: {'bfs', 'a_star'}, // Default: BFS and A*
      algorithmFrames: {},
      results: {},
    ));
  }

  void _onSelectAlgorithm(
    SelectAlgorithm event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    final newSelected = Set<String>.from(currentState.selectedAlgorithmIds);

    if (event.selected) {
      newSelected.add(event.algorithmId);
    } else {
      // Don't allow deselecting if only 2 algorithms remain
      if (newSelected.length > 2) {
        newSelected.remove(event.algorithmId);
      }
    }

    emit(currentState.copyWith(
      selectedAlgorithmIds: newSelected,
      hasRun: false,
      algorithmFrames: {},
      results: {},
    ));
  }

  void _onUpdateGrid(
    UpdateComparisonGrid event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    emit(currentState.copyWith(
      grid: event.grid,
      hasRun: false,
      algorithmFrames: {},
      results: {},
    ));
  }

  void _onToggleObstacle(
    ToggleComparisonObstacle event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    emit(currentState.copyWith(
      grid: currentState.grid.toggleObstacle(event.x, event.y),
      hasRun: false,
      algorithmFrames: {},
      results: {},
    ));
  }

  void _onAddObstacle(
    AddComparisonObstacle event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    emit(currentState.copyWith(
      grid: currentState.grid.addObstacle(event.x, event.y),
      hasRun: false,
      algorithmFrames: {},
      results: {},
    ));
  }

  void _onRemoveObstacle(
    RemoveComparisonObstacle event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    emit(currentState.copyWith(
      grid: currentState.grid.removeObstacle(event.x, event.y),
      hasRun: false,
      algorithmFrames: {},
      results: {},
    ));
  }

  void _onSetStart(
    SetComparisonStart event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    // Don't set start on obstacle
    if (currentState.grid.obstacles.contains((event.x, event.y))) return;

    emit(currentState.copyWith(
      grid: currentState.grid.copyWith(start: (event.x, event.y)),
      hasRun: false,
      algorithmFrames: {},
      results: {},
    ));
  }

  void _onSetEnd(
    SetComparisonEnd event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    // Don't set end on obstacle
    if (currentState.grid.obstacles.contains((event.x, event.y))) return;

    emit(currentState.copyWith(
      grid: currentState.grid.copyWith(end: (event.x, event.y)),
      hasRun: false,
      algorithmFrames: {},
      results: {},
    ));
  }

  void _onClearGrid(
    ClearComparisonGrid event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    _animationTimer?.cancel();

    emit(currentState.copyWith(
      grid: currentState.grid.clear(),
      hasRun: false,
      isPlaying: false,
      currentStep: 0,
      maxSteps: 0,
      algorithmFrames: {},
      results: {},
    ));
  }

  void _onClearVisualization(
    ClearComparisonVisualization event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    _animationTimer?.cancel();

    emit(currentState.copyWith(
      hasRun: false,
      isPlaying: false,
      currentStep: 0,
      maxSteps: 0,
      algorithmFrames: {},
      results: {},
    ));
  }

  void _onRunComparison(
    RunComparison event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    final grid = currentState.grid;
    if (grid.start == null || grid.end == null) return;
    if (currentState.selectedAlgorithmIds.length < 2) return;

    final newFrames = <String, List<GridVisualizationFrame>>{};
    final newResults = <String, AlgorithmResult>{};
    int maxSteps = 0;

    for (final algorithmId in currentState.selectedAlgorithmIds) {
      final algorithm = _algorithms[algorithmId];
      if (algorithm == null) continue;

      final stopwatch = Stopwatch()..start();
      final frames = algorithm.findPath(grid, grid.start!, grid.end!);
      stopwatch.stop();

      newFrames[algorithmId] = frames;

      if (frames.length > maxSteps) {
        maxSteps = frames.length;
      }

      // Calculate metrics
      final lastFrame = frames.isNotEmpty ? frames.last : null;
      final visitedCount = lastFrame?.cellStates.entries
              .where((e) =>
                  e.value == GridCellState.visited ||
                  e.value == GridCellState.path ||
                  e.value == GridCellState.current)
              .length ??
          0;

      newResults[algorithmId] = AlgorithmResult(
        algorithmId: algorithmId,
        algorithmName: algorithm.algorithm.name,
        totalSteps: frames.length,
        cellsVisited: visitedCount,
        pathLength: lastFrame?.path?.length ?? 0,
        executionTime: stopwatch.elapsed,
        pathFound: lastFrame?.path?.isNotEmpty ?? false,
      );
    }

    emit(currentState.copyWith(
      algorithmFrames: newFrames,
      results: newResults,
      currentStep: 0,
      maxSteps: maxSteps,
      hasRun: true,
      isPlaying: false,
    ));
  }

  void _onPlayComparison(
    PlayComparison event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;
    if (!currentState.hasRun) return;

    _startAnimation(currentState.speed);

    emit(currentState.copyWith(isPlaying: true));
  }

  void _onPauseComparison(
    PauseComparison event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    _animationTimer?.cancel();

    emit(currentState.copyWith(isPlaying: false));
  }

  void _onStepForward(
    StepComparisonForward event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;
    if (!currentState.canStepForward) return;

    emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
  }

  void _onStepBackward(
    StepComparisonBackward event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;
    if (!currentState.canStepBackward) return;

    emit(currentState.copyWith(currentStep: currentState.currentStep - 1));
  }

  void _onSetStep(
    SetComparisonStep event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    final newStep = event.step.clamp(0, currentState.maxSteps - 1);
    emit(currentState.copyWith(currentStep: newStep));
  }

  void _onReset(
    ResetComparison event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    _animationTimer?.cancel();

    emit(currentState.copyWith(
      currentStep: 0,
      isPlaying: false,
    ));
  }

  void _onSetSpeed(
    SetComparisonSpeed event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    emit(currentState.copyWith(speed: event.speed));

    // Restart animation with new speed if playing
    if (currentState.isPlaying) {
      _startAnimation(event.speed);
    }
  }

  void _onTickAnimation(
    TickComparisonAnimation event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    if (currentState.currentStep >= currentState.maxSteps - 1) {
      _animationTimer?.cancel();
      emit(currentState.copyWith(isPlaying: false));
      return;
    }

    emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
  }

  void _onResizeGrid(
    ResizeComparisonGrid event,
    Emitter<ComparisonState> emit,
  ) {
    final currentState = state;
    if (currentState is! ComparisonReady) return;

    _animationTimer?.cancel();

    emit(currentState.copyWith(
      grid: GridEntity.create(width: event.width, height: event.height),
      hasRun: false,
      isPlaying: false,
      currentStep: 0,
      maxSteps: 0,
      algorithmFrames: {},
      results: {},
    ));
  }

  void _startAnimation(double speed) {
    _animationTimer?.cancel();
    final interval = Duration(milliseconds: (500 / speed).round());
    _animationTimer = Timer.periodic(interval, (_) {
      add(TickComparisonAnimation());
    });
  }
}
