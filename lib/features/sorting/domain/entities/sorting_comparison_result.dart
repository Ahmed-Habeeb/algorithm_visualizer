import 'package:equatable/equatable.dart';

/// Result of running a sorting algorithm for comparison
class SortingComparisonResult extends Equatable {
  final String algorithmId;
  final String algorithmName;
  final int totalSteps;
  final int comparisons;
  final int swaps;
  final Duration executionTime;
  final bool completed;

  const SortingComparisonResult({
    required this.algorithmId,
    required this.algorithmName,
    required this.totalSteps,
    required this.comparisons,
    required this.swaps,
    required this.executionTime,
    required this.completed,
  });

  @override
  List<Object?> get props => [
        algorithmId,
        algorithmName,
        totalSteps,
        comparisons,
        swaps,
        executionTime,
        completed,
      ];
}
