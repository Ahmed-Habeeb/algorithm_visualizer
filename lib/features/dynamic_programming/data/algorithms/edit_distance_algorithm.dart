import '../../domain/entities/dp_frame_entity.dart';
import '../../domain/interfaces/dp_algorithm.dart';

class EditDistanceAlgorithm implements DPAlgorithm {
  @override
  String get name => 'Edit Distance';

  @override
  String get description =>
      'Find minimum operations to transform one string to another';

  @override
  List<DPFrameEntity> generateFrames(Map<String, dynamic> input) {
    final str1 = input['str1'] as String;
    final str2 = input['str2'] as String;
    final m = str1.length;
    final n = str2.length;
    final frames = <DPFrameEntity>[];

    // Initialize DP table
    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    final cellStates = <String, DPCellState>{};

    // Initial state
    frames.add(DPFrameEntity(
      table: dp.map((row) => List<int>.from(row)).toList(),
      cellStates: Map.from(cellStates),
      operation: 'Initialize',
      explanation: 'Create a ${m + 1}×${n + 1} DP table. Transform "$str1" into "$str2"',
      formula: 'dp[i][j] = min edits to transform str1[0..i-1] to str2[0..j-1]',
    ));

    // Initialize first column
    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
      cellStates['$i,0'] = DPCellState.computed;
    }

    frames.add(DPFrameEntity(
      table: dp.map((row) => List<int>.from(row)).toList(),
      cellStates: Map.from(cellStates),
      operation: 'Base case: first column',
      explanation: 'To transform str1[0..i-1] to empty string, delete i characters',
      formula: 'dp[i][0] = i (i deletions)',
    ));

    // Initialize first row
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
      cellStates['0,$j'] = DPCellState.computed;
    }

    frames.add(DPFrameEntity(
      table: dp.map((row) => List<int>.from(row)).toList(),
      cellStates: Map.from(cellStates),
      operation: 'Base case: first row',
      explanation: 'To transform empty string to str2[0..j-1], insert j characters',
      formula: 'dp[0][j] = j (j insertions)',
    ));

    // Fill the table
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        cellStates['$i,$j'] = DPCellState.computing;

        final char1 = str1[i - 1];
        final char2 = str2[j - 1];

        if (char1 == char2) {
          frames.add(DPFrameEntity(
            table: dp.map((row) => List<int>.from(row)).toList(),
            cellStates: Map.from(cellStates),
            activeRow: i,
            activeCol: j,
            operation: 'Match: "$char1" == "$char2"',
            explanation: 'Characters match! No edit needed. dp[$i][$j] = dp[${i - 1}][${j - 1}] = ${dp[i - 1][j - 1]}',
            formula: 'dp[$i][$j] = dp[${i - 1}][${j - 1}]',
          ));

          dp[i][j] = dp[i - 1][j - 1];
        } else {
          final insert = dp[i][j - 1] + 1;
          final delete = dp[i - 1][j] + 1;
          final replace = dp[i - 1][j - 1] + 1;

          frames.add(DPFrameEntity(
            table: dp.map((row) => List<int>.from(row)).toList(),
            cellStates: Map.from(cellStates),
            activeRow: i,
            activeCol: j,
            operation: 'No match: "$char1" ≠ "$char2"',
            explanation: 'Insert: $insert, Delete: $delete, Replace: $replace. Choose minimum.',
            formula: 'dp[$i][$j] = min(insert, delete, replace)',
          ));

          dp[i][j] = [insert, delete, replace].reduce((a, b) => a < b ? a : b);
        }

        cellStates['$i,$j'] = DPCellState.computed;

        frames.add(DPFrameEntity(
          table: dp.map((row) => List<int>.from(row)).toList(),
          cellStates: Map.from(cellStates),
          activeRow: i,
          activeCol: j,
          operation: 'dp[$i][$j] = ${dp[i][j]}',
          explanation: 'Set dp[$i][$j] = ${dp[i][j]}',
        ));
      }
    }

    // Traceback to find operations
    final operations = <String>[];
    int i = m, j = n;
    final traceback = <(int, int)>[];

    while (i > 0 || j > 0) {
      traceback.add((i, j));
      cellStates['$i,$j'] = DPCellState.path;

      if (i > 0 && j > 0 && str1[i - 1] == str2[j - 1]) {
        operations.add('Keep "${str1[i - 1]}"');
        i--;
        j--;
      } else if (i > 0 && j > 0 && dp[i][j] == dp[i - 1][j - 1] + 1) {
        operations.add('Replace "${str1[i - 1]}" with "${str2[j - 1]}"');
        i--;
        j--;
      } else if (j > 0 && dp[i][j] == dp[i][j - 1] + 1) {
        operations.add('Insert "${str2[j - 1]}"');
        j--;
      } else if (i > 0) {
        operations.add('Delete "${str1[i - 1]}"');
        i--;
      }
    }

    frames.add(DPFrameEntity(
      table: dp.map((row) => List<int>.from(row)).toList(),
      cellStates: Map.from(cellStates),
      operation: 'Complete',
      explanation: 'Edit distance = ${dp[m][n]}. Operations: ${operations.reversed.where((op) => !op.startsWith("Keep")).join(", ")}',
      traceback: traceback,
    ));

    return frames;
  }
}
