import '../../domain/entities/city_map_entity.dart';
import '../../domain/entities/graph_algorithm_entity.dart';
import '../../domain/entities/graph_entity.dart';
import '../../domain/entities/graph_visualization_frame_entity.dart';
import '../../domain/entities/obstacle_entity.dart';

sealed class GraphState {}

class GraphInitial extends GraphState {}

class GraphLoading extends GraphState {}

class GraphReady extends GraphState {
  final GraphAlgorithmEntity algorithm;
  final GraphEntity graph;
  final String? startNode;
  final String? endNode;
  final List<GraphVisualizationFrameEntity> frames;
  final int currentStep;
  final bool isPlaying;
  final double speed;
  final bool hasRun;

  // City Map fields
  final bool cityMapMode;
  final CityMapEntity? cityMap;
  final ObstacleType? selectedObstacleType;

  GraphReady({
    required this.algorithm,
    required this.graph,
    this.startNode,
    this.endNode,
    this.frames = const [],
    this.currentStep = 0,
    this.isPlaying = false,
    this.speed = 1.0,
    this.hasRun = false,
    this.cityMapMode = false,
    this.cityMap,
    this.selectedObstacleType,
  });

  GraphVisualizationFrameEntity? get currentFrame =>
      frames.isNotEmpty && currentStep < frames.length ? frames[currentStep] : null;

  bool get canStepBack => currentStep > 0;
  bool get canStepForward => currentStep < frames.length - 1;
  bool get canRun => startNode != null && (endNode != null || !algorithm.requiresEndNode);

  GraphReady copyWith({
    GraphAlgorithmEntity? algorithm,
    GraphEntity? graph,
    String? startNode,
    String? endNode,
    List<GraphVisualizationFrameEntity>? frames,
    int? currentStep,
    bool? isPlaying,
    double? speed,
    bool? hasRun,
    bool clearStartNode = false,
    bool clearEndNode = false,
    bool? cityMapMode,
    CityMapEntity? cityMap,
    bool clearCityMap = false,
    ObstacleType? selectedObstacleType,
    bool clearSelectedObstacleType = false,
  }) {
    return GraphReady(
      algorithm: algorithm ?? this.algorithm,
      graph: graph ?? this.graph,
      startNode: clearStartNode ? null : (startNode ?? this.startNode),
      endNode: clearEndNode ? null : (endNode ?? this.endNode),
      frames: frames ?? this.frames,
      currentStep: currentStep ?? this.currentStep,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      hasRun: hasRun ?? this.hasRun,
      cityMapMode: cityMapMode ?? this.cityMapMode,
      cityMap: clearCityMap ? null : (cityMap ?? this.cityMap),
      selectedObstacleType: clearSelectedObstacleType ? null : (selectedObstacleType ?? this.selectedObstacleType),
    );
  }
}

class GraphError extends GraphState {
  final String message;
  GraphError(this.message);
}
