import '../../domain/entities/graph_algorithm_entity.dart';
import '../../domain/entities/graph_entity.dart';
import '../../domain/entities/graph_visualization_frame_entity.dart';
import '../../domain/interfaces/graph_algorithm.dart';

class DFS implements GraphAlgorithm {
  @override
  GraphAlgorithmEntity get algorithm => const GraphAlgorithmEntity(
        id: 'dfs',
        name: 'Depth-First Search',
        description:
            'DFS explores as far as possible along each branch before backtracking. It uses a stack data structure (or recursion) and is useful for topological sorting, detecting cycles, and solving puzzles.',
        timeComplexity: 'O(V + E)',
        spaceComplexity: 'O(V)',
        pseudocode: [
          'DFS(graph, start):',
          '  stack = [start]',
          '  visited = {}',
          '  while stack is not empty:',
          '    node = stack.pop()',
          '    if node not in visited:',
          '      visited.add(node)',
          '      for each neighbor of node:',
          '        stack.push(neighbor)',
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

    final List<String> stack = [];
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
      explanation: 'Starting DFS from node $startNode. Initialize stack with start node.',
      currentNode: startNode,
      stack: [startNode],
      parents: Map.from(parents),
    ));

    stack.add(startNode);

    while (stack.isNotEmpty) {
      final current = stack.removeLast();

      if (visited.contains(current)) {
        continue;
      }

      visited.add(current);

      // Mark as current
      if (current != startNode || endNode == null) {
        nodeStates[current] = GraphNodeState.current;
      }

      frames.add(GraphVisualizationFrameEntity(
        nodeStates: Map.from(nodeStates),
        edgeStates: Map.from(edgeStates),
        operation: 'Pop',
        explanation: 'Pop node $current from the stack and mark as visited.',
        currentNode: current,
        stack: List.from(stack),
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
          stack: List.from(stack),
          parents: Map.from(parents),
          path: path,
        ));

        return frames;
      }

      // Explore neighbors (in reverse order to match typical DFS order)
      final neighbors = (adjacencyList[current] ?? []).reversed.toList();
      for (final entry in neighbors) {
        final neighbor = entry.key;
        final edgeKey = '$current-$neighbor';
        final reverseEdgeKey = '$neighbor-$current';

        if (!visited.contains(neighbor)) {
          stack.add(neighbor);
          if (!parents.containsKey(neighbor)) {
            parents[neighbor] = current;
          }

          edgeStates[edgeKey] = GraphEdgeState.considering;
          if (!graph.isDirected) {
            edgeStates[reverseEdgeKey] = GraphEdgeState.considering;
          }

          final prevState = nodeStates[neighbor];
          if (prevState != GraphNodeState.end) {
            nodeStates[neighbor] = GraphNodeState.inStack;
          }

          frames.add(GraphVisualizationFrameEntity(
            nodeStates: Map.from(nodeStates),
            edgeStates: Map.from(edgeStates),
            operation: 'Push',
            explanation: 'Push neighbor $neighbor onto the stack.',
            currentNode: current,
            stack: List.from(stack),
            parents: Map.from(parents),
          ));
        } else {
          if (edgeStates[edgeKey] != GraphEdgeState.visited) {
            edgeStates[edgeKey] = GraphEdgeState.rejected;
            if (!graph.isDirected) {
              edgeStates[reverseEdgeKey] = GraphEdgeState.rejected;
            }
          }
        }
      }

      // Mark current as visited
      if (current == startNode) {
        nodeStates[current] = GraphNodeState.start;
      } else {
        nodeStates[current] = GraphNodeState.visited;
      }

      // Mark edges from parent as visited
      final parent = parents[current];
      if (parent != null) {
        edgeStates['$parent-$current'] = GraphEdgeState.visited;
        if (!graph.isDirected) {
          edgeStates['$current-$parent'] = GraphEdgeState.visited;
        }
      }
    }

    frames.add(GraphVisualizationFrameEntity(
      nodeStates: Map.from(nodeStates),
      edgeStates: Map.from(edgeStates),
      operation: 'Complete',
      explanation: endNode != null
          ? 'DFS complete. Target node $endNode was not reachable from $startNode.'
          : 'DFS traversal complete. All reachable nodes have been visited.',
      stack: [],
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
