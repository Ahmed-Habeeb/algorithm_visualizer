import 'dart:collection';
import 'dart:math';

import '../../domain/entities/graph_algorithm_entity.dart';
import '../../domain/entities/grid_entity.dart';
import '../../domain/entities/grid_visualization_frame.dart';
import '../../domain/interfaces/grid_algorithm.dart';

/// Dijkstra's algorithm implementation for grid pathfinding
class GridDijkstra implements GridAlgorithm {
  @override
  GraphAlgorithmEntity get algorithm => const GraphAlgorithmEntity(
        id: 'dijkstra',
        name: "Dijkstra's Algorithm",
        description:
            "Dijkstra's algorithm finds the shortest path by always expanding the cell with the smallest distance. "
            'Diagonal moves cost √2 ≈ 1.41, cardinal moves cost 1.',
        timeComplexity: 'O((V + E) log V)',
        spaceComplexity: 'O(V)',
        pseudocode: [
          'Dijkstra(grid, start, end):',
          '  dist[start] = 0',
          '  pq = [(0, start)]',
          '  while pq is not empty:',
          '    (d, cell) = pq.extractMin()',
          '    if cell == end:',
          '      return reconstructPath()',
          '    if d > dist[cell]: continue',
          '    for each neighbor of cell:',
          '      cost = d + edgeCost(cell, neighbor)',
          '      if cost < dist[neighbor]:',
          '        dist[neighbor] = cost',
          '        pq.insert((cost, neighbor))',
        ],
      );

  @override
  List<GridVisualizationFrame> findPath(
    GridEntity grid,
    (int, int) start,
    (int, int) end,
  ) {
    final frames = <GridVisualizationFrame>[];
    final dist = <(int, int), double>{};
    final parent = <(int, int), (int, int)>{};
    final visited = <(int, int)>{};

    // Priority queue: (distance, cell)
    final pq = SplayTreeSet<(double, int, int)>((a, b) {
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
      explanation: 'Starting Dijkstra from (${start.$1}, ${start.$2}) to (${end.$1}, ${end.$2})',
      currentCell: start,
      frontier: [start],
    ));

    dist[start] = 0;
    pq.add((0.0, start.$1, start.$2));

    while (pq.isNotEmpty) {
      final entry = pq.first;
      pq.remove(entry);
      final currentDist = entry.$1;
      final current = (entry.$2, entry.$3);

      if (visited.contains(current)) continue;
      visited.add(current);

      // Update current cell visualization
      if (current != start && current != end) {
        cellStates[current] = GridCellState.current;
      }

      frames.add(GridVisualizationFrame(
        cellStates: Map.from(cellStates),
        operation: 'Extract Min',
        explanation: 'Processing (${current.$1}, ${current.$2}) with distance ${currentDist.toStringAsFixed(2)}',
        currentCell: current,
        frontier: pq.map((e) => (e.$2, e.$3)).toList(),
      ));

      // Check if we found the end
      if (current == end) {
        final path = _reconstructPath(parent, start, end);
        _markPath(cellStates, path, start, end);

        frames.add(GridVisualizationFrame(
          cellStates: Map.from(cellStates),
          operation: 'Found',
          explanation: 'Found shortest path! Total distance: ${currentDist.toStringAsFixed(2)}',
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
        if (visited.contains(neighbor)) continue;

        // Calculate edge cost (1 for cardinal, sqrt(2) for diagonal)
        final dx = (neighbor.$1 - current.$1).abs();
        final dy = (neighbor.$2 - current.$2).abs();
        final edgeCost = (dx == 1 && dy == 1) ? sqrt(2) : 1.0;
        final newDist = currentDist + edgeCost;

        if (!dist.containsKey(neighbor) || newDist < dist[neighbor]!) {
          dist[neighbor] = newDist;
          parent[neighbor] = current;
          pq.add((newDist, neighbor.$1, neighbor.$2));

          if (neighbor != end) {
            cellStates[neighbor] = GridCellState.frontier;
          }

          frames.add(GridVisualizationFrame(
            cellStates: Map.from(cellStates),
            operation: 'Relax',
            explanation: 'Updated distance to (${neighbor.$1}, ${neighbor.$2}): ${newDist.toStringAsFixed(2)}',
            currentCell: current,
            frontier: pq.map((e) => (e.$2, e.$3)).toList(),
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
