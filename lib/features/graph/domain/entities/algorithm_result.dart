/// Holds the results and metrics from running a pathfinding algorithm
class AlgorithmResult {
  final String algorithmId;
  final String algorithmName;
  final int totalSteps;
  final int cellsVisited;
  final int pathLength;
  final Duration executionTime;
  final bool pathFound;

  const AlgorithmResult({
    required this.algorithmId,
    required this.algorithmName,
    required this.totalSteps,
    required this.cellsVisited,
    required this.pathLength,
    required this.executionTime,
    required this.pathFound,
  });

  AlgorithmResult copyWith({
    String? algorithmId,
    String? algorithmName,
    int? totalSteps,
    int? cellsVisited,
    int? pathLength,
    Duration? executionTime,
    bool? pathFound,
  }) {
    return AlgorithmResult(
      algorithmId: algorithmId ?? this.algorithmId,
      algorithmName: algorithmName ?? this.algorithmName,
      totalSteps: totalSteps ?? this.totalSteps,
      cellsVisited: cellsVisited ?? this.cellsVisited,
      pathLength: pathLength ?? this.pathLength,
      executionTime: executionTime ?? this.executionTime,
      pathFound: pathFound ?? this.pathFound,
    );
  }

  @override
  String toString() {
    return 'AlgorithmResult(algorithmId: $algorithmId, algorithmName: $algorithmName, '
        'totalSteps: $totalSteps, cellsVisited: $cellsVisited, pathLength: $pathLength, '
        'executionTime: $executionTime, pathFound: $pathFound)';
  }
}
