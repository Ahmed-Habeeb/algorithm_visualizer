import 'package:flutter/material.dart';

import '../../domain/entities/visualization_frame_entity.dart';
import 'array_painter.dart';

/// Panel showing a single algorithm's array visualization for comparison
class ComparisonArrayPanel extends StatelessWidget {
  final String algorithmId;
  final String algorithmName;
  final VisualizationFrameEntity? frame;
  final List<int> initialData;
  final bool isFinished;
  final Color accentColor;

  const ComparisonArrayPanel({
    super.key,
    required this.algorithmId,
    required this.algorithmName,
    required this.frame,
    required this.initialData,
    required this.isFinished,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with algorithm name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
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
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isFinished)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Array visualization
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final displayFrame = frame;
                    if (displayFrame == null) {
                      // Show initial data
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: ArrayPainter(
                          data: initialData,
                          activeIndices: {},
                          comparedIndices: {},
                          sortedIndices: {},
                          isDarkMode: isDarkMode,
                        ),
                      );
                    }

                    return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: ArrayPainter(
                        data: displayFrame.data,
                        activeIndices: displayFrame.activeIndices,
                        comparedIndices: displayFrame.comparedIndices,
                        sortedIndices: displayFrame.sortedIndices,
                        isDarkMode: isDarkMode,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Operation info
          if (frame != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: Text(
                frame!.operation,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  String _getInitial(String algorithmId) {
    switch (algorithmId) {
      case 'bubble_sort':
        return 'B';
      case 'quick_sort':
        return 'Q';
      case 'merge_sort':
        return 'M';
      case 'insertion_sort':
        return 'I';
      case 'selection_sort':
        return 'S';
      case 'heap_sort':
        return 'H';
      default:
        return '?';
    }
  }
}
