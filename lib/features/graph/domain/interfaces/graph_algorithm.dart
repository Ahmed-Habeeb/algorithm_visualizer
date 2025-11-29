import '../entities/graph_algorithm_entity.dart';
import '../entities/graph_entity.dart';
import '../entities/graph_visualization_frame_entity.dart';

abstract class GraphAlgorithm {
  GraphAlgorithmEntity get algorithm;

  List<GraphVisualizationFrameEntity> traverse(
    GraphEntity graph,
    String startNode, {
    String? endNode,
  });
}
