import 'package:flutter/material.dart';

import '../../domain/entities/recursion_frame_entity.dart';

class HanoiVisualizer extends StatelessWidget {
  final Map<String, List<int>> pegs;
  final int totalDisks;
  final HanoiMove? currentMove;

  const HanoiVisualizer({
    super.key,
    required this.pegs,
    required this.totalDisks,
    this.currentMove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Pegs visualization
        Expanded(
          child: Row(
            children: [
              _buildPeg(context, 'A', pegs['A'] ?? []),
              _buildPeg(context, 'B', pegs['B'] ?? []),
              _buildPeg(context, 'C', pegs['C'] ?? []),
            ],
          ),
        ),

        // Current move indicator
        if (currentMove != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Move disk ${currentMove!.disk} from ${currentMove!.from} to ${currentMove!.to}',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPeg(BuildContext context, String label, List<int> disks) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSource = currentMove?.from == label;
    final isDestination = currentMove?.to == label;

    return Expanded(
      child: Column(
        children: [
          // Peg label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSource
                  ? Colors.orange.shade100
                  : isDestination
                      ? Colors.green.shade100
                      : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSource
                    ? Colors.orange
                    : isDestination
                        ? Colors.green
                        : colorScheme.outline,
                width: isSource || isDestination ? 2 : 1,
              ),
            ),
            child: Text(
              'Peg $label',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSource
                    ? Colors.orange.shade900
                    : isDestination
                        ? Colors.green.shade900
                        : colorScheme.onSurface,
              ),
            ),
          ),

          // Peg and disks
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pegHeight = constraints.maxHeight - 20;
                final pegWidth = 10.0;
                final baseWidth = constraints.maxWidth * 0.8;
                final maxDiskWidth = baseWidth - 20;
                final diskHeight = (pegHeight - 30) / (totalDisks + 1);

                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Base
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: baseWidth,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // Vertical peg
                    Positioned(
                      bottom: 15,
                      child: Container(
                        width: pegWidth,
                        height: pegHeight - 15,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade600,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Disks
                    ...disks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final disk = entry.value;
                      final diskWidth =
                          (maxDiskWidth / totalDisks) * disk + 30;
                      final isMovingDisk = currentMove?.disk == disk;

                      return Positioned(
                        bottom: 15 + index * diskHeight + 5,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: diskWidth,
                          height: diskHeight - 4,
                          decoration: BoxDecoration(
                            color: _getDiskColor(disk),
                            borderRadius: BorderRadius.circular(4),
                            border: isMovingDisk
                                ? Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  )
                                : null,
                            boxShadow: isMovingDisk
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$disk',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getDiskColor(int disk) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
    ];
    return colors[(disk - 1) % colors.length];
  }
}
