import 'package:equatable/equatable.dart';

enum DPAlgorithmType {
  fibonacci,
  longestCommonSubsequence,
  knapsack,
  editDistance,
}

class DPAlgorithmEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final DPAlgorithmType type;
  final String timeComplexity;
  final String spaceComplexity;

  const DPAlgorithmEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.timeComplexity,
    required this.spaceComplexity,
  });

  @override
  List<Object?> get props => [id, name, description, type, timeComplexity, spaceComplexity];

  static List<DPAlgorithmEntity> getAlgorithms() {
    return [
      const DPAlgorithmEntity(
        id: 'fibonacci_dp',
        name: 'Fibonacci (DP)',
        description: 'Calculate Fibonacci using dynamic programming with memoization. Compare with the exponential recursive approach.',
        type: DPAlgorithmType.fibonacci,
        timeComplexity: 'O(n)',
        spaceComplexity: 'O(n)',
      ),
      const DPAlgorithmEntity(
        id: 'lcs',
        name: 'Longest Common Subsequence',
        description: 'Find the longest subsequence common to two sequences. Builds a 2D table to track optimal substructure.',
        type: DPAlgorithmType.longestCommonSubsequence,
        timeComplexity: 'O(m × n)',
        spaceComplexity: 'O(m × n)',
      ),
      const DPAlgorithmEntity(
        id: 'knapsack',
        name: '0/1 Knapsack',
        description: 'Maximize value while staying within weight capacity. Classic optimization problem solved with DP table.',
        type: DPAlgorithmType.knapsack,
        timeComplexity: 'O(n × W)',
        spaceComplexity: 'O(n × W)',
      ),
      const DPAlgorithmEntity(
        id: 'edit_distance',
        name: 'Edit Distance',
        description: 'Find minimum operations to transform one string to another. Uses insert, delete, and replace operations.',
        type: DPAlgorithmType.editDistance,
        timeComplexity: 'O(m × n)',
        spaceComplexity: 'O(m × n)',
      ),
    ];
  }
}
