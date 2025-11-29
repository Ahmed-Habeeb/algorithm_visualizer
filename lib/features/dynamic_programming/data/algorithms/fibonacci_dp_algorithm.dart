import '../../domain/entities/dp_frame_entity.dart';
import '../../domain/interfaces/dp_algorithm.dart';

class FibonacciDPAlgorithm implements DPAlgorithm {
  @override
  String get name => 'Fibonacci (DP)';

  @override
  String get description =>
      'Calculate Fibonacci using dynamic programming with O(n) time complexity';

  @override
  List<DPFrameEntity> generateFrames(Map<String, dynamic> input) {
    final n = input['n'] as int;
    final frames = <DPFrameEntity>[];

    // Initialize DP table (1D array displayed as single row)
    final dp = List<int>.filled(n + 1, 0);
    final cellStates = <String, DPCellState>{};

    // Initial state
    frames.add(DPFrameEntity(
      table: [List<int>.from(dp)],
      cellStates: Map.from(cellStates),
      operation: 'Initialize',
      explanation: 'Create a DP table of size ${n + 1} to store Fibonacci values',
      formula: 'dp[i] = Fibonacci(i)',
    ));

    // Base cases
    dp[0] = 0;
    cellStates['0,0'] = DPCellState.computed;
    frames.add(DPFrameEntity(
      table: [List<int>.from(dp)],
      cellStates: Map.from(cellStates),
      activeRow: 0,
      activeCol: 0,
      operation: 'Base case: dp[0] = 0',
      explanation: 'The 0th Fibonacci number is 0',
      formula: 'F(0) = 0',
    ));

    if (n >= 1) {
      dp[1] = 1;
      cellStates['0,1'] = DPCellState.computed;
      frames.add(DPFrameEntity(
        table: [List<int>.from(dp)],
        cellStates: Map.from(cellStates),
        activeRow: 0,
        activeCol: 1,
        operation: 'Base case: dp[1] = 1',
        explanation: 'The 1st Fibonacci number is 1',
        formula: 'F(1) = 1',
      ));
    }

    // Fill the table
    for (int i = 2; i <= n; i++) {
      cellStates['0,$i'] = DPCellState.computing;
      frames.add(DPFrameEntity(
        table: [List<int>.from(dp)],
        cellStates: Map.from(cellStates),
        activeRow: 0,
        activeCol: i,
        operation: 'Computing dp[$i]',
        explanation: 'Calculate F($i) = F(${i - 1}) + F(${i - 2}) = ${dp[i - 1]} + ${dp[i - 2]}',
        formula: 'dp[$i] = dp[${i - 1}] + dp[${i - 2}]',
      ));

      dp[i] = dp[i - 1] + dp[i - 2];
      cellStates['0,$i'] = DPCellState.computed;

      frames.add(DPFrameEntity(
        table: [List<int>.from(dp)],
        cellStates: Map.from(cellStates),
        activeRow: 0,
        activeCol: i,
        operation: 'dp[$i] = ${dp[i]}',
        explanation: 'F($i) = ${dp[i - 1]} + ${dp[i - 2]} = ${dp[i]}',
        formula: 'dp[$i] = ${dp[i]}',
      ));
    }

    // Highlight final result
    cellStates['0,$n'] = DPCellState.highlighted;
    frames.add(DPFrameEntity(
      table: [List<int>.from(dp)],
      cellStates: Map.from(cellStates),
      activeCol: n,
      operation: 'Complete',
      explanation: 'Fibonacci($n) = ${dp[n]}',
      formula: 'F($n) = ${dp[n]}',
    ));

    return frames;
  }
}
