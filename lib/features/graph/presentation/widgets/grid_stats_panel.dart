import 'package:flutter/material.dart';

import '../../domain/entities/grid_entity.dart';
import '../../domain/entities/grid_visualization_frame.dart';

/// Statistics panel showing current cell, visited count, path length, etc.
class GridStatsPanel extends StatelessWidget {
  final GridEntity grid;
  final GridVisualizationFrame? frame;
  final int currentStep;
  final int totalSteps;

  const GridStatsPanel({
    super.key,
    required this.grid,
    this.frame,
    this.currentStep = 0,
    this.totalSteps = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cellStates = frame?.cellStates ?? {};

    // Calculate statistics
    final visitedCount = cellStates.entries
        .where((e) =>
            e.value == GridCellState.visited ||
            e.value == GridCellState.path ||
            e.value == GridCellState.current)
        .length;

    final frontierCount = cellStates.entries
        .where((e) => e.value == GridCellState.frontier)
        .length;

    final pathLength = frame?.path?.length ?? 0;
    final currentCell = frame?.currentCell;

    final totalCells = grid.width * grid.height;
    final walkableCells = totalCells - grid.obstacles.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Statistics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // Current Cell
          _buildStatRow(
            context,
            icon: Icons.location_on,
            label: 'Current Cell',
            value: currentCell != null
                ? '(${currentCell.$1}, ${currentCell.$2})'
                : '-',
            color: const Color(0xFFF97316),
          ),

          // Start Point
          _buildStatRow(
            context,
            icon: Icons.play_arrow,
            label: 'Start',
            value: grid.start != null
                ? '(${grid.start!.$1}, ${grid.start!.$2})'
                : 'Not set',
            color: const Color(0xFF22C55E),
          ),

          // End Point
          _buildStatRow(
            context,
            icon: Icons.flag,
            label: 'End',
            value: grid.end != null
                ? '(${grid.end!.$1}, ${grid.end!.$2})'
                : 'Not set',
            color: const Color(0xFFEF4444),
          ),

          const Divider(height: 16),

          // Visited Count
          _buildStatRow(
            context,
            icon: Icons.check_circle_outline,
            label: 'Visited',
            value: '$visitedCount / $walkableCells',
            color: const Color(0xFF93C5FD),
          ),

          // Frontier Count
          _buildStatRow(
            context,
            icon: Icons.radio_button_unchecked,
            label: 'Frontier',
            value: '$frontierCount',
            color: const Color(0xFFC4B5FD),
          ),

          // Path Length
          if (pathLength > 0)
            _buildStatRow(
              context,
              icon: Icons.route,
              label: 'Path Length',
              value: '$pathLength cells',
              color: const Color(0xFF4ADE80),
            ),

          const Divider(height: 16),

          // Grid Info
          _buildStatRow(
            context,
            icon: Icons.grid_on,
            label: 'Grid Size',
            value: '${grid.width} × ${grid.height}',
            color: colorScheme.primary,
          ),

          _buildStatRow(
            context,
            icon: Icons.block,
            label: 'Obstacles',
            value: '${grid.obstacles.length}',
            color: const Color(0xFF374151),
          ),

          // Progress
          if (totalSteps > 0) ...[
            const Divider(height: 16),
            _buildStatRow(
              context,
              icon: Icons.timeline,
              label: 'Step',
              value: '${currentStep + 1} / $totalSteps',
              color: colorScheme.secondary,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalSteps > 0 ? (currentStep + 1) / totalSteps : 0,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
