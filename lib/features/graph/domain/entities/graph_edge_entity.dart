class GraphEdgeEntity {
  final String from;
  final String to;
  final double weight;
  final bool isDirected;

  const GraphEdgeEntity({
    required this.from,
    required this.to,
    this.weight = 1.0,
    this.isDirected = false,
  });

  GraphEdgeEntity copyWith({
    String? from,
    String? to,
    double? weight,
    bool? isDirected,
  }) {
    return GraphEdgeEntity(
      from: from ?? this.from,
      to: to ?? this.to,
      weight: weight ?? this.weight,
      isDirected: isDirected ?? this.isDirected,
    );
  }
}
