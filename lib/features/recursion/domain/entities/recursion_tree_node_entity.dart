import 'package:equatable/equatable.dart';

enum RecursionNodeState {
  pending,
  active,
  computing,
  returning,
  completed,
}

class RecursionTreeNodeEntity extends Equatable {
  final String id;
  final String label;
  final String? argument;
  final String? returnValue;
  final RecursionNodeState state;
  final List<RecursionTreeNodeEntity> children;
  final int depth;
  final double x;
  final double y;
  final String? parentId;

  const RecursionTreeNodeEntity({
    required this.id,
    required this.label,
    this.argument,
    this.returnValue,
    this.state = RecursionNodeState.pending,
    this.children = const [],
    this.depth = 0,
    this.x = 0,
    this.y = 0,
    this.parentId,
  });

  RecursionTreeNodeEntity copyWith({
    String? id,
    String? label,
    String? argument,
    String? returnValue,
    RecursionNodeState? state,
    List<RecursionTreeNodeEntity>? children,
    int? depth,
    double? x,
    double? y,
    String? parentId,
  }) {
    return RecursionTreeNodeEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      argument: argument ?? this.argument,
      returnValue: returnValue ?? this.returnValue,
      state: state ?? this.state,
      children: children ?? this.children,
      depth: depth ?? this.depth,
      x: x ?? this.x,
      y: y ?? this.y,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        label,
        argument,
        returnValue,
        state,
        children,
        depth,
        x,
        y,
        parentId,
      ];
}
