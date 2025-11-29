import 'package:flutter/material.dart';

import 'grid_visualizer.dart';

/// Control panel for the grid pathfinding visualizer
class GridControls extends StatelessWidget {
  final int gridWidth;
  final int gridHeight;
  final GridInteractionMode mode;
  final bool canRun;
  final bool hasRun;
  final bool isPlaying;
  final Function(int width, int height) onSizeChanged;
  final Function(GridInteractionMode mode) onModeChanged;
  final VoidCallback onClear;
  final VoidCallback onClearPath;
  final VoidCallback onRun;

  const GridControls({
    super.key,
    required this.gridWidth,
    required this.gridHeight,
    required this.mode,
    required this.canRun,
    required this.hasRun,
    required this.isPlaying,
    required this.onSizeChanged,
    required this.onModeChanged,
    required this.onClear,
    required this.onClearPath,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grid Size Control
          Text(
            'Grid Size: $gridWidth × $gridHeight',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: gridWidth.toDouble(),
            min: 5,
            max: 50,
            divisions: 45,
            label: '$gridWidth',
            onChanged: isPlaying ? null : (value) {
              onSizeChanged(value.round(), value.round());
            },
          ),
          const SizedBox(height: 16),

          // Interaction Mode
          Text(
            'Drawing Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ModeButton(
                icon: Icons.brush,
                label: 'Draw Wall',
                isSelected: mode == GridInteractionMode.drawObstacle,
                color: const Color(0xFF374151),
                onTap: isPlaying ? null : () => onModeChanged(GridInteractionMode.drawObstacle),
              ),
              _ModeButton(
                icon: Icons.auto_fix_high,
                label: 'Erase',
                isSelected: mode == GridInteractionMode.eraseObstacle,
                color: Colors.grey,
                onTap: isPlaying ? null : () => onModeChanged(GridInteractionMode.eraseObstacle),
              ),
              _ModeButton(
                icon: Icons.play_circle_outline,
                label: 'Start',
                isSelected: mode == GridInteractionMode.setStart,
                color: const Color(0xFF22C55E),
                onTap: isPlaying ? null : () => onModeChanged(GridInteractionMode.setStart),
              ),
              _ModeButton(
                icon: Icons.flag_outlined,
                label: 'End',
                isSelected: mode == GridInteractionMode.setEnd,
                color: const Color(0xFFEF4444),
                onTap: isPlaying ? null : () => onModeChanged(GridInteractionMode.setEnd),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isPlaying ? null : onClear,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (isPlaying || !hasRun) ? null : onClearPath,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Clear Path'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Run Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (canRun && !isPlaying) ? onRun : null,
              icon: const Icon(Icons.route),
              label: Text(hasRun ? 'Run Again' : 'Find Path'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? color : Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
