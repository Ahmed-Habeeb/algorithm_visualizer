import 'package:equatable/equatable.dart';

class SearchVisualizationFrameEntity extends Equatable {
  final List<int> data;
  final int? currentIndex;
  final int? leftBound;
  final int? rightBound;
  final int? midIndex;
  final Set<int> checkedIndices;
  final int? foundIndex;
  final int target;
  final String operation;
  final String explanation;

  const SearchVisualizationFrameEntity({
    required this.data,
    this.currentIndex,
    this.leftBound,
    this.rightBound,
    this.midIndex,
    required this.checkedIndices,
    this.foundIndex,
    required this.target,
    required this.operation,
    required this.explanation,
  });

  bool get isFound => foundIndex != null;

  SearchVisualizationFrameEntity copyWith({
    List<int>? data,
    int? currentIndex,
    int? leftBound,
    int? rightBound,
    int? midIndex,
    Set<int>? checkedIndices,
    int? foundIndex,
    int? target,
    String? operation,
    String? explanation,
  }) {
    return SearchVisualizationFrameEntity(
      data: data ?? this.data,
      currentIndex: currentIndex ?? this.currentIndex,
      leftBound: leftBound ?? this.leftBound,
      rightBound: rightBound ?? this.rightBound,
      midIndex: midIndex ?? this.midIndex,
      checkedIndices: checkedIndices ?? this.checkedIndices,
      foundIndex: foundIndex ?? this.foundIndex,
      target: target ?? this.target,
      operation: operation ?? this.operation,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  List<Object?> get props => [
        data,
        currentIndex,
        leftBound,
        rightBound,
        midIndex,
        checkedIndices,
        foundIndex,
        target,
        operation,
        explanation,
      ];
}
