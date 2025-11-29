/// Represents a 2D grid for pathfinding visualization
class GridEntity {
  final int width;
  final int height;
  final Set<(int, int)> obstacles;
  final (int, int)? start;
  final (int, int)? end;

  const GridEntity({
    required this.width,
    required this.height,
    this.obstacles = const {},
    this.start,
    this.end,
  });

  /// Create a default grid with given dimensions
  factory GridEntity.create({
    int width = 20,
    int height = 20,
  }) {
    return GridEntity(
      width: width,
      height: height,
      obstacles: {},
    );
  }

  /// Check if a cell is within grid bounds
  bool isValidCell(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  /// Check if a cell is walkable (valid and not an obstacle)
  bool isWalkable(int x, int y) {
    return isValidCell(x, y) && !obstacles.contains((x, y));
  }

  /// Get all valid neighboring cells (4 directions: up, down, left, right)
  List<(int, int)> getNeighbors(int x, int y) {
    final neighbors = <(int, int)>[];

    // 4 directions: Up, Down, Left, Right (no diagonals)
    const directions = [
      (0, -1),  // Up
      (0, 1),   // Down
      (-1, 0),  // Left
      (1, 0),   // Right
    ];

    for (final (dx, dy) in directions) {
      final nx = x + dx;
      final ny = y + dy;
      if (isWalkable(nx, ny)) {
        neighbors.add((nx, ny));
      }
    }

    return neighbors;
  }

  /// Get cost for moving to a neighbor (always 1 for 4-directional movement)
  static double getMoveCost(int fromX, int fromY, int toX, int toY) {
    return 1.0;
  }

  /// Copy with modifications
  GridEntity copyWith({
    int? width,
    int? height,
    Set<(int, int)>? obstacles,
    (int, int)? start,
    (int, int)? end,
    bool clearStart = false,
    bool clearEnd = false,
  }) {
    return GridEntity(
      width: width ?? this.width,
      height: height ?? this.height,
      obstacles: obstacles ?? this.obstacles,
      start: clearStart ? null : (start ?? this.start),
      end: clearEnd ? null : (end ?? this.end),
    );
  }

  /// Add an obstacle at position
  GridEntity addObstacle(int x, int y) {
    if (!isValidCell(x, y)) return this;
    if ((x, y) == start || (x, y) == end) return this;

    final newObstacles = Set<(int, int)>.from(obstacles)..add((x, y));
    return copyWith(obstacles: newObstacles);
  }

  /// Remove an obstacle at position
  GridEntity removeObstacle(int x, int y) {
    final newObstacles = Set<(int, int)>.from(obstacles)..remove((x, y));
    return copyWith(obstacles: newObstacles);
  }

  /// Toggle obstacle at position
  GridEntity toggleObstacle(int x, int y) {
    if (obstacles.contains((x, y))) {
      return removeObstacle(x, y);
    } else {
      return addObstacle(x, y);
    }
  }

  /// Clear all obstacles
  GridEntity clearObstacles() {
    return copyWith(obstacles: {});
  }

  /// Clear everything (obstacles, start, end)
  GridEntity clear() {
    return GridEntity(
      width: width,
      height: height,
      obstacles: {},
    );
  }
}
