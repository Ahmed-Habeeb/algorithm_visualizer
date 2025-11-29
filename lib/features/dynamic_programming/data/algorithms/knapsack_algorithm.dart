import '../../domain/entities/dp_frame_entity.dart';
import '../../domain/interfaces/dp_algorithm.dart';

class KnapsackAlgorithm implements DPAlgorithm {
  @override
  String get name => '0/1 Knapsack';

  @override
  String get description =>
      'Maximize value while staying within weight capacity';

  @override
  List<DPFrameEntity> generateFrames(Map<String, dynamic> input) {
    final items = input['items'] as List<KnapsackItem>;
    final capacity = input['capacity'] as int;
    final n = items.length;
    final frames = <DPFrameEntity>[];

    // Initialize DP table
    final dp = List.generate(n + 1, (_) => List<int>.filled(capacity + 1, 0));
    final cellStates = <String, DPCellState>{};

    // Initial state
    frames.add(DPFrameEntity(
      table: dp.map((row) => List<int>.from(row)).toList(),
      cellStates: Map.from(cellStates),
      operation: 'Initialize',
      explanation: 'Create a ${n + 1}×${capacity + 1} DP table. Rows = items, Columns = weight capacity',
      formula: 'dp[i][w] = max value using items 0..i-1 with capacity w',
    ));

    // Initialize first row and column
    for (int i = 0; i <= n; i++) {
      cellStates['$i,0'] = DPCellState.computed;
    }
    for (int w = 0; w <= capacity; w++) {
      cellStates['0,$w'] = DPCellState.computed;
    }

    frames.add(DPFrameEntity(
      table: dp.map((row) => List<int>.from(row)).toList(),
      cellStates: Map.from(cellStates),
      operation: 'Base cases',
      explanation: 'With 0 items or 0 capacity, max value is 0',
      formula: 'dp[0][w] = dp[i][0] = 0',
    ));

    // Fill the table
    for (int i = 1; i <= n; i++) {
      final item = items[i - 1];

      for (int w = 1; w <= capacity; w++) {
        cellStates['$i,$w'] = DPCellState.computing;

        if (item.weight > w) {
          // Item too heavy, can't include
          frames.add(DPFrameEntity(
            table: dp.map((row) => List<int>.from(row)).toList(),
            cellStates: Map.from(cellStates),
            activeRow: i,
            activeCol: w,
            operation: 'Item ${item.name} too heavy',
            explanation: '${item.name} weighs ${item.weight}, but capacity is only $w. Cannot include.',
            formula: 'dp[$i][$w] = dp[${i - 1}][$w] = ${dp[i - 1][w]}',
          ));

          dp[i][w] = dp[i - 1][w];
        } else {
          // Choose max of including or excluding
          final exclude = dp[i - 1][w];
          final include = dp[i - 1][w - item.weight] + item.value;

          frames.add(DPFrameEntity(
            table: dp.map((row) => List<int>.from(row)).toList(),
            cellStates: Map.from(cellStates),
            activeRow: i,
            activeCol: w,
            operation: 'Consider ${item.name}',
            explanation: 'Exclude: ${dp[i - 1][w]}, Include: ${dp[i - 1][w - item.weight]} + ${item.value} = $include. Choose max.',
            formula: 'dp[$i][$w] = max($exclude, $include)',
          ));

          dp[i][w] = exclude > include ? exclude : include;
        }

        cellStates['$i,$w'] = DPCellState.computed;

        frames.add(DPFrameEntity(
          table: dp.map((row) => List<int>.from(row)).toList(),
          cellStates: Map.from(cellStates),
          activeRow: i,
          activeCol: w,
          operation: 'dp[$i][$w] = ${dp[i][w]}',
          explanation: 'Set dp[$i][$w] = ${dp[i][w]}',
        ));
      }
    }

    // Traceback to find selected items
    final selectedItems = <String>[];
    int w = capacity;
    for (int i = n; i > 0 && w > 0; i--) {
      if (dp[i][w] != dp[i - 1][w]) {
        final item = items[i - 1];
        selectedItems.add(item.name);
        cellStates['$i,$w'] = DPCellState.path;
        w -= item.weight;
      }
    }

    frames.add(DPFrameEntity(
      table: dp.map((row) => List<int>.from(row)).toList(),
      cellStates: Map.from(cellStates),
      operation: 'Complete',
      explanation: 'Max value = ${dp[n][capacity]}. Selected items: ${selectedItems.reversed.join(", ")}',
    ));

    return frames;
  }
}
