import 'package:equatable/equatable.dart';

class VisualizationFrameEntity extends Equatable {
  final List<int> data;
  final Set<int> activeIndices;
  final Set<int> comparedIndices;
  final Set<int> sortedIndices;
  final String operation;
  final String explanation;
  final Map<String, dynamic>? metadata;

  const VisualizationFrameEntity({
    required this.data,
    required this.activeIndices,
    required this.comparedIndices,
    required this.sortedIndices,
    required this.operation,
    required this.explanation,
    this.metadata,
  });

  VisualizationFrameEntity copyWith({
    List<int>? data,
    Set<int>? activeIndices,
    Set<int>? comparedIndices,
    Set<int>? sortedIndices,
    String? operation,
    String? explanation,
    Map<String, dynamic>? metadata,
  }) {
    return VisualizationFrameEntity(
      data: data ?? this.data,
      activeIndices: activeIndices ?? this.activeIndices,
      comparedIndices: comparedIndices ?? this.comparedIndices,
      sortedIndices: sortedIndices ?? this.sortedIndices,
      operation: operation ?? this.operation,
      explanation: explanation ?? this.explanation,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        data,
        activeIndices,
        comparedIndices,
        sortedIndices,
        operation,
        explanation,
        metadata,
      ];
}
