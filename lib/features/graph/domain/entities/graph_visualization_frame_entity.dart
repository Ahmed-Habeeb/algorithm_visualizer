enum GraphNodeState {
  unvisited,
  current,
  visiting,
  visited,
  inQueue,
  inStack,
  path,
  start,
  end,
}

enum GraphEdgeState {
  unvisited,
  considering,
  visited,
  path,
  rejected,
}

class GraphVisualizationFrameEntity {
  final Map<String, GraphNodeState> nodeStates;
  final Map<String, GraphEdgeState> edgeStates;
  final String operation;
  final String explanation;
  final String? currentNode;
  final List<String> queue;
  final List<String> stack;
  final Map<String, double> distances;
  final Map<String, String?> parents;
  final List<String> path;

  const GraphVisualizationFrameEntity({
    required this.nodeStates,
    required this.edgeStates,
    required this.operation,
    required this.explanation,
    this.currentNode,
    this.queue = const [],
    this.stack = const [],
    this.distances = const {},
    this.parents = const {},
    this.path = const [],
  });

  String getEdgeKey(String from, String to) {
    return '$from-$to';
  }

  GraphVisualizationFrameEntity copyWith({
    Map<String, GraphNodeState>? nodeStates,
    Map<String, GraphEdgeState>? edgeStates,
    String? operation,
    String? explanation,
    String? currentNode,
    List<String>? queue,
    List<String>? stack,
    Map<String, double>? distances,
    Map<String, String?>? parents,
    List<String>? path,
  }) {
    return GraphVisualizationFrameEntity(
      nodeStates: nodeStates ?? this.nodeStates,
      edgeStates: edgeStates ?? this.edgeStates,
      operation: operation ?? this.operation,
      explanation: explanation ?? this.explanation,
      currentNode: currentNode ?? this.currentNode,
      queue: queue ?? this.queue,
      stack: stack ?? this.stack,
      distances: distances ?? this.distances,
      parents: parents ?? this.parents,
      path: path ?? this.path,
    );
  }
}
