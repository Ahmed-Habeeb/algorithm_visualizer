import 'dart:collection';

import '../../domain/entities/graph_algorithm_entity.dart';
import '../../domain/entities/grid_entity.dart';
import '../../domain/entities/grid_visualization_frame.dart';
import '../../domain/interfaces/grid_algorithm.dart';

/// Breadth-First Search implementation for grid pathfinding
class GridBFS implements GridAlgorithm {
  @override
  GraphAlgorithmEntity get algorithm => const GraphAlgorithmEntity(
        id: 'bfs',
        name: 'Breadth-First Search',
        description:
            'BFS explores all cells at the current distance before moving to cells at the next distance level. '
            'It guarantees finding the shortest path in an unweighted grid.',
        timeComplexity: 'O(V + E)',
        spaceComplexity: 'O(V)',
        pseudocode: [
          'BFS(grid, start, end):',
          '  queue = [start]',
          '  visited = {start}',
          '  parent = {}',
          '  while queue is not empty:',
          '    cell = queue.dequeue()',
          '    if cell == end:',
          '      return reconstructPath(parent)',
          '    for each neighbor of cell:',
          '      if neighbor not visited and walkable:',
          '        visited.add(neighbor)',
          '        parent[neighbor] = cell',
          '        queue.enqueue(neighbor)',
        ],
      );

  @override
  List<GridVisualizationFrame> findPath(
    GridEntity grid,
    (int, int) start,
    (int, int) end,
  ) {
    final frames = <GridVisualizationFrame>[];
    final visited = <(int, int)>{};
    final parent = <(int, int), (int, int)>{};
    final queue = Queue<(int, int)>();

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
      explanation: 'Starting BFS from (${start.$1}, ${start.$2}) to (${end.$1}, ${end.$2})',
      currentCell: start,
      frontier: [start],
    ));

    queue.add(start);
    visited.add(start);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      // Update current cell visualization
      if (current != start && current != end) {
        cellStates[current] = GridCellState.current;
      }

      frames.add(GridVisualizationFrame(
        cellStates: Map.from(cellStates),
        operation: 'Dequeue',
        explanation: 'Processing cell (${current.$1}, ${current.$2})',
        currentCell: current,
        frontier: queue.toList(),
      ));

      // Check if we found the end
      if (current == end) {
        final path = _reconstructPath(parent, start, end);
        _markPath(cellStates, path, start, end);

        frames.add(GridVisualizationFrame(
          cellStates: Map.from(cellStates),
          operation: 'Found',
          explanation: 'Found target! Path length: ${path.length}',
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
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          parent[neighbor] = current;
          queue.add(neighbor);

          if (neighbor != end) {
            cellStates[neighbor] = GridCellState.frontier;
          }

          frames.add(GridVisualizationFrame(
            cellStates: Map.from(cellStates),
            operation: 'Enqueue',
            explanation: 'Discovered cell (${neighbor.$1}, ${neighbor.$2})',
            currentCell: current,
            frontier: queue.toList(),
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
