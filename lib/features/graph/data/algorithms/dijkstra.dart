import 'dart:collection';

import '../../domain/entities/graph_algorithm_entity.dart';
import '../../domain/entities/graph_entity.dart';
import '../../domain/entities/graph_visualization_frame_entity.dart';
import '../../domain/interfaces/graph_algorithm.dart';

class Dijkstra implements GraphAlgorithm {
  @override
  GraphAlgorithmEntity get algorithm => const GraphAlgorithmEntity(
        id: 'dijkstra',
        name: "Dijkstra's Algorithm",
        description:
            "Dijkstra's algorithm finds the shortest path from a source node to all other nodes in a weighted graph with non-negative edge weights. It uses a priority queue to always process the node with the smallest known distance.",
        timeComplexity: 'O((V + E) log V)',
        spaceComplexity: 'O(V)',
        pseudocode: [
          'Dijkstra(graph, start):',
          '  dist[start] = 0',
          '  dist[v] = ∞ for all other v',
          '  pq = priority_queue([(0, start)])',
          '  while pq is not empty:',
          '    (d, u) = pq.extract_min()',
          '    for each neighbor v of u:',
          '      if dist[u] + weight(u,v) < dist[v]:',
          '        dist[v] = dist[u] + weight(u,v)',
          '        pq.insert((dist[v], v))',
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
    final frames = <GraphVisualizationFrameEntity>[];
    final adjacencyList = graph.adjacencyList;

    final Map<String, GraphNodeState> nodeStates = {
      for (final node in graph.nodes) node.id: GraphNodeState.unvisited
    };
    final Map<String, GraphEdgeState> edgeStates = {};
    final Map<String, double> distances = {
      for (final node in graph.nodes) node.id: double.infinity
    };
    final Map<String, String?> parents = {};
    final Set<String> visited = {};

    // Priority queue: (distance, nodeId)
    final pq = SplayTreeSet<MapEntry<double, String>>((a, b) {
      final cmp = a.key.compareTo(b.key);
      if (cmp != 0) return cmp;
      return a.value.compareTo(b.value);
    });

    // Initialize
    distances[startNode] = 0;
    nodeStates[startNode] = GraphNodeState.start;
    if (endNode != null) {
      nodeStates[endNode] = GraphNodeState.end;
    }

    frames.add(GraphVisualizationFrameEntity(
      nodeStates: Map.from(nodeStates),
      edgeStates: Map.from(edgeStates),
      operation: 'Initialize',
      explanation:
          'Starting Dijkstra from node $startNode. Set distance to start as 0, all others as ∞.',
      currentNode: startNode,
      distances: Map.from(distances),
      parents: Map.from(parents),
    ));

    pq.add(MapEntry(0, startNode));

    while (pq.isNotEmpty) {
      final entry = pq.first;
      pq.remove(entry);
      final currentDist = entry.key;
      final current = entry.value;

      if (visited.contains(current)) {
        continue;
      }
      visited.add(current);

      // Mark as current
      final prevState = nodeStates[current];
      if (prevState != GraphNodeState.start && prevState != GraphNodeState.end) {
        nodeStates[current] = GraphNodeState.current;
      }

      frames.add(GraphVisualizationFrameEntity(
        nodeStates: Map.from(nodeStates),
        edgeStates: Map.from(edgeStates),
        operation: 'Extract Min',
        explanation:
            'Extract node $current with distance ${currentDist.toStringAsFixed(1)} from priority queue.',
        currentNode: current,
        distances: Map.from(distances),
        parents: Map.from(parents),
      ));

      // Check if we found the end
      if (endNode != null && current == endNode) {
        // Reconstruct path
        final path = _reconstructPath(parents, startNode, endNode);
        _markPath(nodeStates, edgeStates, path, startNode, endNode);

        frames.add(GraphVisualizationFrameEntity(
          nodeStates: Map.from(nodeStates),
          edgeStates: Map.from(edgeStates),
          operation: 'Found',
          explanation:
              'Found shortest path to $endNode! Distance: ${distances[endNode]?.toStringAsFixed(1)}. Path: ${path.join(" → ")}',
          currentNode: current,
          distances: Map.from(distances),
          parents: Map.from(parents),
          path: path,
        ));

        return frames;
      }

      // Explore neighbors
      final neighbors = adjacencyList[current] ?? [];
      for (final neighbor in neighbors) {
        final neighborId = neighbor.key;
        final weight = neighbor.value;
        final edgeKey = '$current-$neighborId';
        final reverseEdgeKey = '$neighborId-$current';

        if (visited.contains(neighborId)) {
          continue;
        }

        final newDist = currentDist + weight;
        final currentNeighborDist = distances[neighborId] ?? double.infinity;

        edgeStates[edgeKey] = GraphEdgeState.considering;
        if (!graph.isDirected) {
          edgeStates[reverseEdgeKey] = GraphEdgeState.considering;
        }

        if (newDist < currentNeighborDist) {
          // Remove old entry if exists
          pq.removeWhere((e) => e.value == neighborId);

          distances[neighborId] = newDist;
          parents[neighborId] = current;
          pq.add(MapEntry(newDist, neighborId));

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
            operation: 'Relax',
            explanation:
                'Relaxed edge to $neighborId. New distance: ${newDist.toStringAsFixed(1)} (was ${currentNeighborDist == double.infinity ? "∞" : currentNeighborDist.toStringAsFixed(1)}).',
            currentNode: current,
            distances: Map.from(distances),
            parents: Map.from(parents),
          ));
        } else {
          edgeStates[edgeKey] = GraphEdgeState.rejected;
          if (!graph.isDirected) {
            edgeStates[reverseEdgeKey] = GraphEdgeState.rejected;
          }

          frames.add(GraphVisualizationFrameEntity(
            nodeStates: Map.from(nodeStates),
            edgeStates: Map.from(edgeStates),
            operation: 'Skip',
            explanation:
                'No improvement for $neighborId. Current: ${currentNeighborDist.toStringAsFixed(1)}, via $current: ${newDist.toStringAsFixed(1)}.',
            currentNode: current,
            distances: Map.from(distances),
            parents: Map.from(parents),
          ));
        }
      }

      // Mark current as visited
      if (current == startNode) {
        nodeStates[current] = GraphNodeState.start;
      } else if (current == endNode) {
        nodeStates[current] = GraphNodeState.end;
      } else {
        nodeStates[current] = GraphNodeState.visited;
      }
    }

    frames.add(GraphVisualizationFrameEntity(
      nodeStates: Map.from(nodeStates),
      edgeStates: Map.from(edgeStates),
      operation: 'Complete',
      explanation: endNode != null
          ? 'Dijkstra complete. Target node $endNode was not reachable from $startNode.'
          : 'Dijkstra complete. Shortest paths to all reachable nodes have been found.',
      distances: Map.from(distances),
      parents: Map.from(parents),
    ));

    return frames;
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
