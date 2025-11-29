class GraphAlgorithmEntity {
  final String id;
  final String name;
  final String description;
  final String timeComplexity;
  final String spaceComplexity;
  final List<String> pseudocode;
  final bool requiresWeightedGraph;
  final bool requiresStartNode;
  final bool requiresEndNode;

  const GraphAlgorithmEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.pseudocode,
    this.requiresWeightedGraph = false,
    this.requiresStartNode = true,
    this.requiresEndNode = false,
  });
}
