import '../../domain/entities/dp_frame_entity.dart';
import '../../domain/interfaces/dp_algorithm.dart';

class LCSAlgorithm implements DPAlgorithm {
  @override
  String get name => 'Longest Common Subsequence';

  @override
  String get description =>
      'Find the longest subsequence common to two sequences';

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
      explanation: 'Create a ${m + 1}×${n + 1} DP table. Rows represent "$str1", columns represent "$str2"',
      formula: 'dp[i][j] = length of LCS of str1[0..i-1] and str2[0..j-1]',
    ));

    // Initialize first row and column to 0
    for (int i = 0; i <= m; i++) {
      cellStates['$i,0'] = DPCellState.computed;
    }
    for (int j = 0; j <= n; j++) {
      cellStates['0,$j'] = DPCellState.computed;
    }

    frames.add(DPFrameEntity(
      table: dp.map((row) => List<int>.from(row)).toList(),
      cellStates: Map.from(cellStates),
      operation: 'Base cases',
      explanation: 'Initialize first row and column to 0 (empty string has LCS of 0)',
      formula: 'dp[0][j] = dp[i][0] = 0',
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
            explanation: 'Characters match! dp[$i][$j] = dp[${i - 1}][${j - 1}] + 1 = ${dp[i - 1][j - 1]} + 1',
            formula: 'dp[$i][$j] = dp[${i - 1}][${j - 1}] + 1',
          ));

          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          frames.add(DPFrameEntity(
            table: dp.map((row) => List<int>.from(row)).toList(),
            cellStates: Map.from(cellStates),
            activeRow: i,
            activeCol: j,
            operation: 'No match: "$char1" ≠ "$char2"',
            explanation: 'Characters differ. dp[$i][$j] = max(dp[${i - 1}][$j], dp[$i][${j - 1}]) = max(${dp[i - 1][j]}, ${dp[i][j - 1]})',
            formula: 'dp[$i][$j] = max(dp[${i - 1}][$j], dp[$i][${j - 1}])',
          ));

          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
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

    // Traceback to find LCS
    final traceback = <(int, int)>[];
    int i = m, j = n;
    final lcs = StringBuffer();

    while (i > 0 && j > 0) {
      traceback.add((i, j));
      if (str1[i - 1] == str2[j - 1]) {
        lcs.write(str1[i - 1]);
        cellStates['$i,$j'] = DPCellState.path;
        i--;
        j--;
      } else if (dp[i - 1][j] > dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }

    final lcsStr = lcs.toString().split('').reversed.join();

    frames.add(DPFrameEntity(
      table: dp.map((row) => List<int>.from(row)).toList(),
      cellStates: Map.from(cellStates),
      operation: 'Complete',
      explanation: 'LCS length = ${dp[m][n]}. LCS = "$lcsStr"',
      traceback: traceback,
    ));

    return frames;
  }
}
