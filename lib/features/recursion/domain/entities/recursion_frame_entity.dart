import 'package:equatable/equatable.dart';
import 'recursion_tree_node_entity.dart';

class RecursionFrameEntity extends Equatable {
  final Map<String, RecursionNodeState> nodeStates;
  final String? activeNodeId;
  final List<String> callStack;
  final String operation;
  final String explanation;
  final Map<String, String> returnValues;
  final List<HanoiMove>? hanoiMoves;
  final Map<String, List<int>>? hanoiPegs;

  const RecursionFrameEntity({
    required this.nodeStates,
    this.activeNodeId,
    this.callStack = const [],
    required this.operation,
    required this.explanation,
    this.returnValues = const {},
    this.hanoiMoves,
    this.hanoiPegs,
  });

  RecursionFrameEntity copyWith({
    Map<String, RecursionNodeState>? nodeStates,
    String? activeNodeId,
    List<String>? callStack,
    String? operation,
    String? explanation,
    Map<String, String>? returnValues,
    List<HanoiMove>? hanoiMoves,
    Map<String, List<int>>? hanoiPegs,
  }) {
    return RecursionFrameEntity(
      nodeStates: nodeStates ?? this.nodeStates,
      activeNodeId: activeNodeId ?? this.activeNodeId,
      callStack: callStack ?? this.callStack,
      operation: operation ?? this.operation,
      explanation: explanation ?? this.explanation,
      returnValues: returnValues ?? this.returnValues,
      hanoiMoves: hanoiMoves ?? this.hanoiMoves,
      hanoiPegs: hanoiPegs ?? this.hanoiPegs,
    );
  }

  @override
  List<Object?> get props => [
        nodeStates,
        activeNodeId,
        callStack,
        operation,
        explanation,
        returnValues,
        hanoiMoves,
        hanoiPegs,
      ];
}

class HanoiMove extends Equatable {
  final int disk;
  final String from;
  final String to;

  const HanoiMove({
    required this.disk,
    required this.from,
    required this.to,
  });

  @override
  List<Object?> get props => [disk, from, to];
}
