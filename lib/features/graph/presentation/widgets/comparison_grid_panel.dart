import 'package:flutter/material.dart';

import '../../domain/entities/grid_entity.dart';
import '../../domain/entities/grid_visualization_frame.dart';
import 'grid_painter.dart';

/// A grid panel for comparison view with algorithm label
class ComparisonGridPanel extends StatelessWidget {
  final String algorithmId;
  final String algorithmName;
  final GridEntity grid;
  final GridVisualizationFrame? frame;
  final bool isFinished;
  final Color accentColor;

  const ComparisonGridPanel({
    super.key,
    required this.algorithmId,
    required this.algorithmName,
    required this.grid,
    this.frame,
    this.isFinished = false,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFinished ? accentColor : colorScheme.outlineVariant,
          width: isFinished ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with algorithm name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      _getInitial(algorithmId),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    algorithmName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isFinished)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Grid visualization
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final availableHeight = constraints.maxHeight;

                  final cellWidth = availableWidth / grid.width;
                  final cellHeight = availableHeight / grid.height;
                  final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

                  final gridWidth = cellSize * grid.width;
                  final gridHeight = cellSize * grid.height;

                  return Center(
                    child: Container(
                      width: gridWidth,
                      height: gridHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CustomPaint(
                          size: Size(gridWidth, gridHeight),
                          painter: GridPainter(
                            grid: grid,
                            frame: frame,
                            cellSize: cellSize,
                            showGridLines: true,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Status bar
          if (frame != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      frame!.operation,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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

/// Helper to get algorithm color
Color getAlgorithmColor(String algorithmId) {
  switch (algorithmId) {
    case 'bfs':
      return const Color(0xFF3B82F6); // Blue
    case 'dfs':
      return const Color(0xFF8B5CF6); // Purple
    case 'dijkstra':
      return const Color(0xFFF97316); // Orange
    case 'a_star':
      return const Color(0xFF22C55E); // Green
    default:
      return Colors.grey;
  }
}
