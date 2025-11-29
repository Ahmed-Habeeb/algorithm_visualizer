enum DSNodeState {
  normal,
  highlighted,
  current,
  comparing,
  found,
  inserted,
  deleted,
  visited,
}

class DSVisualizationFrameEntity {
  final String operation;
  final String explanation;
  final List<DSNodeData> nodes;
  final List<DSEdgeData> edges;
  final List<int>? arrayData;
  final int? headIndex;
  final int? tailIndex;
  final int? topIndex;
  final int? currentIndex;

  const DSVisualizationFrameEntity({
    required this.operation,
    required this.explanation,
    this.nodes = const [],
    this.edges = const [],
    this.arrayData,
    this.headIndex,
    this.tailIndex,
    this.topIndex,
    this.currentIndex,
  });
}

class DSNodeData {
  final String id;
  final int value;
  final double x;
  final double y;
  final DSNodeState state;
  final String? label;

  const DSNodeData({
    required this.id,
    required this.value,
    required this.x,
    required this.y,
    this.state = DSNodeState.normal,
    this.label,
  });

  DSNodeData copyWith({
    String? id,
    int? value,
    double? x,
    double? y,
    DSNodeState? state,
    String? label,
  }) {
    return DSNodeData(
      id: id ?? this.id,
      value: value ?? this.value,
      x: x ?? this.x,
      y: y ?? this.y,
      state: state ?? this.state,
      label: label ?? this.label,
    );
  }
}

class DSEdgeData {
  final String fromId;
  final String toId;
  final bool isHighlighted;

  const DSEdgeData({
    required this.fromId,
    required this.toId,
    this.isHighlighted = false,
  });
}
