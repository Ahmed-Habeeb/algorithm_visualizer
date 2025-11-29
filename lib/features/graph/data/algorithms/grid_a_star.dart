import 'dart:collection';
import 'dart:math';

import '../../domain/entities/graph_algorithm_entity.dart';
import '../../domain/entities/grid_entity.dart';
import '../../domain/entities/grid_visualization_frame.dart';
import '../../domain/interfaces/grid_algorithm.dart';

/// A* algorithm implementation for grid pathfinding
class GridAStar implements GridAlgorithm {
  @override
  GraphAlgorithmEntity get algorithm => const GraphAlgorithmEntity(
        id: 'a_star',
        name: 'A* Search',
        description:
            'A* combines Dijkstra with a heuristic to guide the search toward the goal. '
            'Uses Euclidean distance as heuristic. Guarantees shortest path with admissible heuristic.',
        timeComplexity: 'O((V + E) log V)',
        spaceComplexity: 'O(V)',
        pseudocode: [
          'AStar(grid, start, end):',
          '  g[start] = 0',
          '  f[start] = h(start, end)',
          '  openSet = [(f[start], start)]',
          '  while openSet is not empty:',
          '    cell = openSet.extractMin()',
          '    if cell == end:',
          '      return reconstructPath()',
          '    for each neighbor of cell:',
          '      tentative_g = g[cell] + cost(cell, neighbor)',
          '      if tentative_g < g[neighbor]:',
          '        g[neighbor] = tentative_g',
          '        f[neighbor] = g[neighbor] + h(neighbor, end)',
          '        openSet.insert(neighbor)',
        ],
      );

  @override
  List<GridVisualizationFrame> findPath(
    GridEntity grid,
    (int, int) start,
    (int, int) end,
  ) {
    final frames = <GridVisualizationFrame>[];
    final gScore = <(int, int), double>{}; // Cost from start to cell
    final fScore = <(int, int), double>{}; // gScore + heuristic
    final parent = <(int, int), (int, int)>{};
    final closedSet = <(int, int)>{};

    // Priority queue: (fScore, cell)
    final openSet = SplayTreeSet<(double, int, int)>((a, b) {
      final cmp = a.$1.compareTo(b.$1);
      if (cmp != 0) return cmp;
      final cmpX = a.$2.compareTo(b.$2);
      if (cmpX != 0) return cmpX;
      return a.$3.compareTo(b.$3);
    });

    // Initialize cell states
    Map<(int, int), GridCellState> cellStates = {};
    for (final obstacle in grid.obstacles) {
      cellStates[obstacle] = GridCellState.obstacle;
    }
    cellStates[start] = GridCellState.start;
    cellStates[end] = GridCellState.end;

    // Initial frame
    frames.add(GridVisualizationFrame(
      cellStates: Map.from(cellStates),
      operation: 'Initialize',
      explanation: 'Starting A* from (${start.$1}, ${start.$2}) to (${end.$1}, ${end.$2})',
      currentCell: start,
      frontier: [start],
    ));

    gScore[start] = 0;
    fScore[start] = _heuristic(start, end);
    openSet.add((fScore[start]!, start.$1, start.$2));

    while (openSet.isNotEmpty) {
      final entry = openSet.first;
      openSet.remove(entry);
      final current = (entry.$2, entry.$3);

      if (closedSet.contains(current)) continue;
      closedSet.add(current);

      // Update current cell visualization
      if (current != start && current != end) {
        cellStates[current] = GridCellState.current;
      }

      final currentG = gScore[current]!;
      final currentF = fScore[current]!;

      frames.add(GridVisualizationFrame(
        cellStates: Map.from(cellStates),
        operation: 'Extract Min',
        explanation: 'Processing (${current.$1}, ${current.$2}) - g: ${currentG.toStringAsFixed(2)}, f: ${currentF.toStringAsFixed(2)}',
        currentCell: current,
        frontier: openSet.map((e) => (e.$2, e.$3)).toList(),
      ));

      // Check if we found the end
      if (current == end) {
        final path = _reconstructPath(parent, start, end);
        _markPath(cellStates, path, start, end);

        frames.add(GridVisualizationFrame(
          cellStates: Map.from(cellStates),
          operation: 'Found',
          explanation: 'Found optimal path! Total cost: ${currentG.toStringAsFixed(2)}',
          currentCell: end,
          path: path,
          frontier: [],
        ));

        return frames;
      }

      // Mark current as visited
      if (current != start) {
        cellStates[current] = GridCellState.visited;
      }

      // Explore neighbors
      final neighbors = grid.getNeighbors(current.$1, current.$2);
      for (final neighbor in neighbors) {
        if (closedSet.contains(neighbor)) continue;

        // Calculate edge cost (1 for cardinal, sqrt(2) for diagonal)
        final dx = (neighbor.$1 - current.$1).abs();
        final dy = (neighbor.$2 - current.$2).abs();
        final edgeCost = (dx == 1 && dy == 1) ? sqrt(2) : 1.0;
        final tentativeG = currentG + edgeCost;

        if (!gScore.containsKey(neighbor) || tentativeG < gScore[neighbor]!) {
          parent[neighbor] = current;
          gScore[neighbor] = tentativeG;
          fScore[neighbor] = tentativeG + _heuristic(neighbor, end);
          openSet.add((fScore[neighbor]!, neighbor.$1, neighbor.$2));

          if (neighbor != end) {
            cellStates[neighbor] = GridCellState.frontier;
          }

          frames.add(GridVisualizationFrame(
            cellStates: Map.from(cellStates),
            operation: 'Update',
            explanation: 'Updated (${neighbor.$1}, ${neighbor.$2}) - g: ${tentativeG.toStringAsFixed(2)}, h: ${_heuristic(neighbor, end).toStringAsFixed(2)}',
            currentCell: current,
            frontier: openSet.map((e) => (e.$2, e.$3)).toList(),
          ));
        }
      }
    }

    // No path found
    frames.add(GridVisualizationFrame(
      cellStates: Map.from(cellStates),
      operation: 'No Path',
      explanation: 'No path exists from start to end',
      frontier: [],
    ));

    return frames;
  }

  /// Euclidean distance heuristic
  double _heuristic((int, int) a, (int, int) b) {
    final dx = (a.$1 - b.$1).toDouble();
    final dy = (a.$2 - b.$2).toDouble();
    return sqrt(dx * dx + dy * dy);
  }

  List<(int, int)> _reconstructPath(
    Map<(int, int), (int, int)> parent,
    (int, int) start,
    (int, int) end,
  ) {
    final path = <(int, int)>[];
    (int, int)? current = end;

    while (current != null) {
      path.add(current);
      current = parent[current];
    }

    return path.reversed.toList();
  }

  void _markPath(
    Map<(int, int), GridCellState> cellStates,
    List<(int, int)> path,
    (int, int) start,
    (int, int) end,
  ) {
    for (final cell in path) {
      if (cell == start) {
        cellStates[cell] = GridCellState.start;
      } else if (cell == end) {
        cellStates[cell] = GridCellState.end;
      } else {
        cellStates[cell] = GridCellState.path;
      }
    }
  }
}
