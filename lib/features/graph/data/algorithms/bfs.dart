import 'dart:collection';

import '../../domain/entities/graph_algorithm_entity.dart';
import '../../domain/entities/graph_entity.dart';
import '../../domain/entities/graph_visualization_frame_entity.dart';
import '../../domain/interfaces/graph_algorithm.dart';

class BFS implements GraphAlgorithm {
  @override
  GraphAlgorithmEntity get algorithm => const GraphAlgorithmEntity(
        id: 'bfs',
        name: 'Breadth-First Search',
        description:
            'BFS explores all vertices at the current depth before moving to vertices at the next depth level. It uses a queue data structure and is optimal for finding the shortest path in unweighted graphs.',
        timeComplexity: 'O(V + E)',
        spaceComplexity: 'O(V)',
        pseudocode: [
          'BFS(graph, start):',
          '  queue = [start]',
          '  visited = {start}',
          '  while queue is not empty:',
          '    node = queue.dequeue()',
          '    for each neighbor of node:',
          '      if neighbor not in visited:',
          '        visited.add(neighbor)',
          '        queue.enqueue(neighbor)',
        ],
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
    final Map<String, String?> parents = {startNode: null};

    final Queue<String> queue = Queue();
    final Set<String> visited = {};

    // Initialize
    nodeStates[startNode] = GraphNodeState.start;
    if (endNode != null) {
      nodeStates[endNode] = GraphNodeState.end;
    }

    frames.add(GraphVisualizationFrameEntity(
      nodeStates: Map.from(nodeStates),
      edgeStates: Map.from(edgeStates),
      operation: 'Initialize',
      explanation: 'Starting BFS from node $startNode. Initialize queue with start node.',
      currentNode: startNode,
      queue: [startNode],
      parents: Map.from(parents),
    ));

    queue.add(startNode);
    visited.add(startNode);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      // Mark as current
      if (current != startNode || endNode == null) {
        nodeStates[current] = GraphNodeState.current;
      }

      frames.add(GraphVisualizationFrameEntity(
        nodeStates: Map.from(nodeStates),
        edgeStates: Map.from(edgeStates),
        operation: 'Dequeue',
        explanation: 'Dequeue node $current from the queue and explore its neighbors.',
        currentNode: current,
        queue: queue.toList(),
        parents: Map.from(parents),
      ));

      // Check if we found the end
      if (endNode != null && current == endNode) {
        nodeStates[current] = GraphNodeState.end;

        // Reconstruct path
        final path = _reconstructPath(parents, startNode, endNode);
        _markPath(nodeStates, edgeStates, path, startNode, endNode);

        frames.add(GraphVisualizationFrameEntity(
          nodeStates: Map.from(nodeStates),
          edgeStates: Map.from(edgeStates),
          operation: 'Found',
          explanation: 'Found target node $endNode! Path: ${path.join(" → ")}',
          currentNode: current,
          queue: queue.toList(),
          parents: Map.from(parents),
          path: path,
        ));

        return frames;
      }

      // Explore neighbors
      final neighbors = adjacencyList[current] ?? [];
      for (final entry in neighbors) {
        final neighbor = entry.key;
        final edgeKey = '$current-$neighbor';
        final reverseEdgeKey = '$neighbor-$current';

        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(neighbor);
          parents[neighbor] = current;

          edgeStates[edgeKey] = GraphEdgeState.visited;
          if (!graph.isDirected) {
            edgeStates[reverseEdgeKey] = GraphEdgeState.visited;
          }

          final prevState = nodeStates[neighbor];
          if (prevState != GraphNodeState.end) {
            nodeStates[neighbor] = GraphNodeState.inQueue;
          }

          frames.add(GraphVisualizationFrameEntity(
            nodeStates: Map.from(nodeStates),
            edgeStates: Map.from(edgeStates),
            operation: 'Enqueue',
            explanation: 'Discovered node $neighbor via node $current. Adding to queue.',
            currentNode: current,
            queue: queue.toList(),
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
      operation: 'Complete',
      explanation: endNode != null
          ? 'BFS complete. Target node $endNode was not reachable from $startNode.'
          : 'BFS traversal complete. All reachable nodes have been visited.',
      queue: [],
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
