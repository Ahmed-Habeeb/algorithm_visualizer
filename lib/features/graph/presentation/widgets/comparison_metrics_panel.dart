import 'package:flutter/material.dart';

import '../../domain/entities/algorithm_result.dart';
import 'comparison_grid_panel.dart';

/// Panel showing comparison metrics for all algorithms in a table
class ComparisonMetricsPanel extends StatelessWidget {
  final Map<String, AlgorithmResult> results;
  final List<String> algorithmOrder;
  final bool compact;

  const ComparisonMetricsPanel({
    super.key,
    required this.results,
    required this.algorithmOrder,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (results.isEmpty) {
      return Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Center(
          child: Text(
            'Run comparison to see metrics',
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(compact ? 8 : 12),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: compact ? 16 : 20,
                  color: colorScheme.primary,
                ),
                SizedBox(width: compact ? 6 : 8),
                Text(
                  'Comparison Results',
                  style: TextStyle(
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final orderedResults = algorithmOrder
        .where((id) => results.containsKey(id))
        .map((id) => results[id]!)
        .toList();

    if (orderedResults.isEmpty) return const SizedBox.shrink();

    // Find best values for highlighting
    final minSteps = orderedResults
        .map((r) => r.totalSteps)
        .reduce((a, b) => a < b ? a : b);
    final minVisited = orderedResults
        .map((r) => r.cellsVisited)
        .reduce((a, b) => a < b ? a : b);
    final minPath = orderedResults
        .where((r) => r.pathFound)
        .map((r) => r.pathLength)
        .fold<int?>(null, (a, b) => a == null || b < a ? b : a);
    final minTime = orderedResults
        .map((r) => r.executionTime.inMicroseconds)
        .reduce((a, b) => a < b ? a : b);

    return DataTable(
      columnSpacing: compact ? 16 : 24,
      horizontalMargin: compact ? 8 : 12,
      headingRowHeight: compact ? 36 : 44,
      dataRowMinHeight: compact ? 32 : 40,
      dataRowMaxHeight: compact ? 40 : 48,
      columns: [
        DataColumn(
          label: Text(
            'Metric',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ),
        ...orderedResults.map((result) => DataColumn(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: compact ? 16 : 20,
                    height: compact ? 16 : 20,
                    decoration: BoxDecoration(
                      color: getAlgorithmColor(result.algorithmId)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        _getInitial(result.algorithmId),
                        style: TextStyle(
                          fontSize: compact ? 8 : 10,
                          fontWeight: FontWeight.bold,
                          color: getAlgorithmColor(result.algorithmId),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? 4 : 6),
                  Text(
                    result.algorithmName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 10 : 11,
                    ),
                  ),
                ],
              ),
            )),
      ],
      rows: [
        // Steps
        DataRow(cells: [
          DataCell(Text('Steps', style: TextStyle(fontSize: compact ? 11 : 12))),
          ...orderedResults.map((r) => DataCell(
                _buildValueCell(
                  context,
                  r.totalSteps.toString(),
                  r.totalSteps == minSteps,
                  Icons.timeline,
                ),
              )),
        ]),

        // Cells Visited
        DataRow(cells: [
          DataCell(Text('Visited', style: TextStyle(fontSize: compact ? 11 : 12))),
          ...orderedResults.map((r) => DataCell(
                _buildValueCell(
                  context,
                  r.cellsVisited.toString(),
                  r.cellsVisited == minVisited,
                  Icons.grid_on,
                ),
              )),
        ]),

        // Path Length
        DataRow(cells: [
          DataCell(Text('Path Length', style: TextStyle(fontSize: compact ? 11 : 12))),
          ...orderedResults.map((r) => DataCell(
                _buildValueCell(
                  context,
                  r.pathFound ? r.pathLength.toString() : '-',
                  r.pathFound && minPath != null && r.pathLength == minPath,
                  Icons.route,
                ),
              )),
        ]),

        // Time
        DataRow(cells: [
          DataCell(Text('Time', style: TextStyle(fontSize: compact ? 11 : 12))),
          ...orderedResults.map((r) => DataCell(
                _buildValueCell(
                  context,
                  _formatDuration(r.executionTime),
                  r.executionTime.inMicroseconds == minTime,
                  Icons.timer_outlined,
                ),
              )),
        ]),

        // Path Found
        DataRow(cells: [
          DataCell(Text('Found', style: TextStyle(fontSize: compact ? 11 : 12))),
          ...orderedResults.map((r) => DataCell(
                Icon(
                  r.pathFound ? Icons.check_circle : Icons.cancel,
                  color: r.pathFound ? Colors.green : Colors.red,
                  size: compact ? 16 : 20,
                ),
              )),
        ]),
      ],
    );
  }

  Widget _buildValueCell(
    BuildContext context,
    String value,
    bool isBest,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
            color: isBest ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        if (isBest) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.star,
            size: compact ? 12 : 14,
            color: Colors.amber,
          ),
        ],
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds < 1) {
      return '${duration.inMicroseconds}µs';
    } else if (duration.inSeconds < 1) {
      return '${duration.inMilliseconds}ms';
    } else {
      return '${duration.inSeconds}.${(duration.inMilliseconds % 1000) ~/ 100}s';
    }
  }

  String _getInitial(String algorithmId) {
    switch (algorithmId) {
      case 'bfs':
        return 'B';
      case 'dfs':
        return 'D';
      case 'dijkstra':
        return 'Dj';
      case 'a_star':
        return 'A*';
      default:
        return '?';
    }
  }
}
