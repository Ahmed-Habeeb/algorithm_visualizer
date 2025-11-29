import '../entities/grid_entity.dart';
import '../entities/grid_visualization_frame.dart';
import '../entities/graph_algorithm_entity.dart';

/// Interface for grid-based pathfinding algorithms
abstract class GridAlgorithm {
  /// Algorithm metadata
  GraphAlgorithmEntity get algorithm;

  /// Find path from start to end on the grid
  /// Returns a list of visualization frames showing the algorithm's progress
  List<GridVisualizationFrame> findPath(
    GridEntity grid,
    (int, int) start,
    (int, int) end,
  );
}
