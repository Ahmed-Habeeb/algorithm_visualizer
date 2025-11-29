import 'graph_node_entity.dart';
import 'graph_edge_entity.dart';

class GraphEntity {
  final List<GraphNodeEntity> nodes;
  final List<GraphEdgeEntity> edges;
  final bool isDirected;
  final bool isWeighted;

  const GraphEntity({
    required this.nodes,
    required this.edges,
    this.isDirected = false,
    this.isWeighted = false,
  });

  Map<String, List<MapEntry<String, double>>> get adjacencyList {
    final Map<String, List<MapEntry<String, double>>> adj = {};

    for (final node in nodes) {
      adj[node.id] = [];
    }

    for (final edge in edges) {
      adj[edge.from]?.add(MapEntry(edge.to, edge.weight));
      if (!isDirected) {
        adj[edge.to]?.add(MapEntry(edge.from, edge.weight));
      }
    }

    return adj;
  }

  GraphNodeEntity? getNode(String id) {
    try {
      return nodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  GraphEntity copyWith({
    List<GraphNodeEntity>? nodes,
    List<GraphEdgeEntity>? edges,
    bool? isDirected,
    bool? isWeighted,
  }) {
    return GraphEntity(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      isDirected: isDirected ?? this.isDirected,
      isWeighted: isWeighted ?? this.isWeighted,
    );
  }
}
