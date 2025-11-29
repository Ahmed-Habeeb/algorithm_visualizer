import 'dart:collection';
import 'dart:math' as math;

import '../../domain/entities/graph_algorithm_entity.dart';
import '../../domain/entities/graph_entity.dart';
import '../../domain/entities/graph_visualization_frame_entity.dart';
import '../../domain/interfaces/graph_algorithm.dart';

class AStar implements GraphAlgorithm {
  @override
  GraphAlgorithmEntity get algorithm => const GraphAlgorithmEntity(
        id: 'a_star',
        name: 'A* Algorithm',
        description:
            'A* is an informed search algorithm that finds the shortest path using heuristics. It combines the actual cost from start (g) with an estimated cost to goal (h) to prioritize which nodes to explore. A* is optimal when the heuristic is admissible.',
        timeComplexity: 'O(E log V)',
        spaceComplexity: 'O(V)',
        pseudocode: [
          'A*(graph, start, goal):',
          '  g[start] = 0',
          '  f[start] = h(start, goal)',
          '  open = priority_queue([(f[start], start)])',
          '  while open is not empty:',
          '    current = open.extract_min()',
          '    if current == goal: return path',
          '    for each neighbor of current:',
          '      tentative_g = g[current] + cost(current, neighbor)',
          '      if tentative_g < g[neighbor]:',
          '        g[neighbor] = tentative_g',
          '        f[neighbor] = g[neighbor] + h(neighbor, goal)',
          '        open.insert((f[neighbor], neighbor))',
        ],
        requiresWeightedGraph: true,
        requiresEndNode: true,
      );

  @override
  List<GraphVisualizationFrameEntity> traverse(
    GraphEntity graph,
    String startNode, {
    String? endNode,
  }) {
    if (endNode == null) {
      return _traverseWithoutEnd(graph, startNode);
    }

    final frames = <GraphVisualizationFrameEntity>[];
    final adjacencyList = graph.adjacencyList;

    final Map<String, GraphNodeState> nodeStates = {
      for (final node in graph.nodes) node.id: GraphNodeState.unvisited
    };
    final Map<String, GraphEdgeState> edgeStates = {};
    final Map<String, double> gScore = {
      for (final node in graph.nodes) node.id: double.infinity
    };
    final Map<String, double> fScore = {
      for (final node in graph.nodes) node.id: double.infinity
    };
    final Map<String, String?> parents = {};
    final Set<String> closedSet = {};

    // Get node positions for heuristic
    final nodePositions = <String, (double, double)>{};
    for (final node in graph.nodes) {
      nodePositions[node.id] = (node.x, node.y);
    }

    double heuristic(String from, String to) {
      final fromPos = nodePositions[from];
      final toPos = nodePositions[to];
      if (fromPos == null || toPos == null) return 0;
      return math.sqrt(
        math.pow(fromPos.$1 - toPos.$1, 2) + math.pow(fromPos.$2 - toPos.$2, 2),
      );
    }

    // Priority queue: (fScore, nodeId)
    final openSet = SplayTreeSet<MapEntry<double, String>>((a, b) {
      final cmp = a.key.compareTo(b.key);
      if (cmp != 0) return cmp;
      return a.value.compareTo(b.value);
    });

    // Initialize
    gScore[startNode] = 0;
    fScore[startNode] = heuristic(startNode, endNode);
    nodeStates[startNode] = GraphNodeState.start;
    nodeStates[endNode] = GraphNodeState.end;

    frames.add(GraphVisualizationFrameEntity(
      nodeStates: Map.from(nodeStates),
      edgeStates: Map.from(edgeStates),
      operation: 'Initialize',
      explanation:
          'Starting A* from $startNode to $endNode. g($startNode) = 0, h = ${heuristic(startNode, endNode).toStringAsFixed(1)}, f = ${fScore[startNode]?.toStringAsFixed(1)}',
      currentNode: startNode,
      distances: Map.from(fScore),
      parents: Map.from(parents),
    ));

    openSet.add(MapEntry(fScore[startNode]!, startNode));

    while (openSet.isNotEmpty) {
      final entry = openSet.first;
      openSet.remove(entry);
      final current = entry.value;

      if (closedSet.contains(current)) {
        continue;
      }

      // Mark as current
      final prevState = nodeStates[current];
      if (prevState != GraphNodeState.start && prevState != GraphNodeState.end) {
        nodeStates[current] = GraphNodeState.current;
      }

      final g = gScore[current] ?? double.infinity;
      final f = fScore[current] ?? double.infinity;
      final h = f - g;

      frames.add(GraphVisualizationFrameEntity(
        nodeStates: Map.from(nodeStates),
        edgeStates: Map.from(edgeStates),
        operation: 'Extract Min',
        explanation:
            'Processing node $current: g=${g.toStringAsFixed(1)}, h=${h.toStringAsFixed(1)}, f=${f.toStringAsFixed(1)}',
        currentNode: current,
        distances: Map.from(fScore),
        parents: Map.from(parents),
      ));

      // Check if we found the end
      if (current == endNode) {
        final path = _reconstructPath(parents, startNode, endNode);
        _markPath(nodeStates, edgeStates, path, startNode, endNode);

        frames.add(GraphVisualizationFrameEntity(
          nodeStates: Map.from(nodeStates),
          edgeStates: Map.from(edgeStates),
          operation: 'Found',
          explanation:
              'Found optimal path to $endNode! Total cost: ${gScore[endNode]?.toStringAsFixed(1)}. Path: ${path.join(" → ")}',
          currentNode: current,
          distances: Map.from(fScore),
          parents: Map.from(parents),
          path: path,
        ));

        return frames;
      }

      closedSet.add(current);

      // Explore neighbors
      final neighbors = adjacencyList[current] ?? [];
      for (final neighbor in neighbors) {
        final neighborId = neighbor.key;
        final weight = neighbor.value;
        final edgeKey = '$current-$neighborId';
        final reverseEdgeKey = '$neighborId-$current';

        if (closedSet.contains(neighborId)) {
          continue;
        }

        final tentativeG = g + weight;
        final currentG = gScore[neighborId] ?? double.infinity;

        edgeStates[edgeKey] = GraphEdgeState.considering;
        if (!graph.isDirected) {
          edgeStates[reverseEdgeKey] = GraphEdgeState.considering;
        }

        if (tentativeG < currentG) {
          parents[neighborId] = current;
          gScore[neighborId] = tentativeG;
          final h = heuristic(neighborId, endNode);
          fScore[neighborId] = tentativeG + h;

          // Remove old entry if exists
          openSet.removeWhere((e) => e.value == neighborId);
          openSet.add(MapEntry(fScore[neighborId]!, neighborId));

          final neighborState = nodeStates[neighborId];
          if (neighborState != GraphNodeState.end) {
            nodeStates[neighborId] = GraphNodeState.inQueue;
          }

          edgeStates[edgeKey] = GraphEdgeState.visited;
          if (!graph.isDirected) {
            edgeStates[reverseEdgeKey] = GraphEdgeState.visited;
          }

          frames.add(GraphVisualizationFrameEntity(
            nodeStates: Map.from(nodeStates),
            edgeStates: Map.from(edgeStates),
            operation: 'Update',
            explanation:
                'Updated $neighborId: g=${tentativeG.toStringAsFixed(1)}, h=${h.toStringAsFixed(1)}, f=${fScore[neighborId]?.toStringAsFixed(1)}',
            currentNode: current,
            distances: Map.from(fScore),
            parents: Map.from(parents),
          ));
        } else {
          edgeStates[edgeKey] = GraphEdgeState.rejected;
          if (!graph.isDirected) {
            edgeStates[reverseEdgeKey] = GraphEdgeState.rejected;
          }
        }
      }

      // Mark current as visited
      if (current == startNode) {
        nodeStates[current] = GraphNodeState.start;
      } else {
        nodeStates[current] = GraphNodeState.visited;
      }
    }

    frames.add(GraphVisualizationFrameEntity(
      nodeStates: Map.from(nodeStates),
      edgeStates: Map.from(edgeStates),
      operation: 'No Path',
      explanation: 'A* complete. No path exists from $startNode to $endNode.',
      distances: Map.from(fScore),
      parents: Map.from(parents),
    ));

    return frames;
  }

  List<GraphVisualizationFrameEntity> _traverseWithoutEnd(
    GraphEntity graph,
    String startNode,
  ) {
    return [
      GraphVisualizationFrameEntity(
        nodeStates: {startNode: GraphNodeState.start},
        edgeStates: const {},
        operation: 'Error',
        explanation: 'A* requires both a start and end node to find a path.',
      ),
    ];
  }

  List<String> _reconstructPath(
    Map<String, String?> parents,
    String start,
    String end,
  ) {
    final path = <String>[];
    String? current = end;

    while (current != null) {
      path.add(current);
      if (current == start) break;
      current = parents[current];
    }

    return path.reversed.toList();
  }

  void _markPath(
    Map<String, GraphNodeState> nodeStates,
    Map<String, GraphEdgeState> edgeStates,
    List<String> path,
    String start,
    String end,
  ) {
    for (int i = 0; i < path.length; i++) {
      final node = path[i];
      if (node == start) {
        nodeStates[node] = GraphNodeState.start;
      } else if (node == end) {
        nodeStates[node] = GraphNodeState.end;
      } else {
        nodeStates[node] = GraphNodeState.path;
      }

      if (i < path.length - 1) {
        final next = path[i + 1];
        edgeStates['$node-$next'] = GraphEdgeState.path;
        edgeStates['$next-$node'] = GraphEdgeState.path;
      }
    }
  }
}
