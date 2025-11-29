/// States a grid cell can be in during visualization
enum GridCellState {
  empty,     // Default - white
  obstacle,  // Blocked - dark gray
  start,     // Start point - green
  end,       // End point - red
  visited,   // Already explored - light blue
  current,   // Currently processing - orange
  path,      // Part of final path - bright green
  frontier,  // In queue to explore - light purple
}

/// A single frame of the grid pathfinding visualization
class GridVisualizationFrame {
  /// State of each cell at this frame
  final Map<(int, int), GridCellState> cellStates;

  /// Short operation name (e.g., "Dequeue", "Visit", "Found")
  final String operation;

  /// Detailed explanation of what's happening
  final String explanation;

  /// Currently processing cell
  final (int, int)? currentCell;

  /// Final path (only set when path is found)
  final List<(int, int)>? path;

  /// Cells currently in the queue/frontier
  final List<(int, int)> frontier;

  const GridVisualizationFrame({
    required this.cellStates,
    required this.operation,
    required this.explanation,
    this.currentCell,
    this.path,
    this.frontier = const [],
  });

  /// Create initial frame from grid
  factory GridVisualizationFrame.initial({
    required Set<(int, int)> obstacles,
    required (int, int) start,
    required (int, int) end,
  }) {
    final cellStates = <(int, int), GridCellState>{};

    // Mark obstacles
    for (final obstacle in obstacles) {
      cellStates[obstacle] = GridCellState.obstacle;
    }

    // Mark start and end
    cellStates[start] = GridCellState.start;
    cellStates[end] = GridCellState.end;

    return GridVisualizationFrame(
      cellStates: cellStates,
      operation: 'Initialize',
      explanation: 'Starting pathfinding from (${start.$1}, ${start.$2}) to (${end.$1}, ${end.$2})',
      currentCell: start,
      frontier: [start],
    );
  }

  /// Create a copy with updated values
  GridVisualizationFrame copyWith({
    Map<(int, int), GridCellState>? cellStates,
    String? operation,
    String? explanation,
    (int, int)? currentCell,
    List<(int, int)>? path,
    List<(int, int)>? frontier,
    bool clearCurrentCell = false,
  }) {
    return GridVisualizationFrame(
      cellStates: cellStates ?? this.cellStates,
      operation: operation ?? this.operation,
      explanation: explanation ?? this.explanation,
      currentCell: clearCurrentCell ? null : (currentCell ?? this.currentCell),
      path: path ?? this.path,
      frontier: frontier ?? this.frontier,
    );
  }
}
