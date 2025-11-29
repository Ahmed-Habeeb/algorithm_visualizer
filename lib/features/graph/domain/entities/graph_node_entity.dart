class GraphNodeEntity {
  final String id;
  final double x;
  final double y;
  final String? label;

  const GraphNodeEntity({
    required this.id,
    required this.x,
    required this.y,
    this.label,
  });

  GraphNodeEntity copyWith({
    String? id,
    double? x,
    double? y,
    String? label,
  }) {
    return GraphNodeEntity(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      label: label ?? this.label,
    );
  }
}
