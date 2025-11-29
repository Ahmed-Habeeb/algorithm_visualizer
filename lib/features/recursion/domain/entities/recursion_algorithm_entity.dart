import 'package:equatable/equatable.dart';

enum RecursionAlgorithmType {
  fibonacci,
  factorial,
  towerOfHanoi,
  mergeSort,
  nQueens,
}

class RecursionAlgorithmEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final RecursionAlgorithmType type;
  final String timeComplexity;
  final String spaceComplexity;

  const RecursionAlgorithmEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.timeComplexity,
    required this.spaceComplexity,
  });

  @override
  List<Object?> get props => [id, name, description, type, timeComplexity, spaceComplexity];

  static List<RecursionAlgorithmEntity> getAlgorithms() {
    return [
      const RecursionAlgorithmEntity(
        id: 'fibonacci',
        name: 'Fibonacci Sequence',
        description: 'Calculate the nth Fibonacci number using recursion. Visualizes the recursive call tree showing how each call branches into two sub-calls.',
        type: RecursionAlgorithmType.fibonacci,
        timeComplexity: 'O(2^n)',
        spaceComplexity: 'O(n)',
      ),
      const RecursionAlgorithmEntity(
        id: 'factorial',
        name: 'Factorial',
        description: 'Calculate n! (n factorial) using recursion. Shows how recursion builds up a call stack and then unwinds to compute the result.',
        type: RecursionAlgorithmType.factorial,
        timeComplexity: 'O(n)',
        spaceComplexity: 'O(n)',
      ),
      const RecursionAlgorithmEntity(
        id: 'tower_of_hanoi',
        name: 'Tower of Hanoi',
        description: 'Classic puzzle to move disks from one peg to another. Demonstrates recursive problem decomposition by solving smaller subproblems.',
        type: RecursionAlgorithmType.towerOfHanoi,
        timeComplexity: 'O(2^n)',
        spaceComplexity: 'O(n)',
      ),
    ];
  }
}
