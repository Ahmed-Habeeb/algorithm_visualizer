import 'package:flutter/material.dart';

import '../../../../core/theme/colors_manager.dart';
import '../../domain/entities/ds_visualization_frame_entity.dart';

class DSInfoPanel extends StatelessWidget {
  final String structureName;
  final String description;
  final Map<String, String> timeComplexities;
  final String spaceComplexity;
  final DSVisualizationFrameEntity? currentFrame;
  final int stepNumber;
  final int totalSteps;

  const DSInfoPanel({
    super.key,
    required this.structureName,
    required this.description,
    required this.timeComplexities,
    required this.spaceComplexity,
    this.currentFrame,
    required this.stepNumber,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Counter
          if (totalSteps > 0) ...[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Step $stepNumber / $totalSteps',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (currentFrame != null)
                  _ComplexityBadge(
                    label: currentFrame!.operation,
                    color: ColorsManager.activeElement,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Current Explanation
            if (currentFrame != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  currentFrame!.explanation,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],

          // Complexity Section
          const Text(
            'Time Complexity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timeComplexities.entries.map((entry) {
              return _ComplexityBadge(
                label: '${entry.key}: ${entry.value}',
                color: _getComplexityColor(entry.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          _ComplexityBadge(
            label: 'Space: $spaceComplexity',
            color: ColorsManager.info,
          ),
        ],
      ),
    );
  }

  Color _getComplexityColor(String operation) {
    switch (operation.toLowerCase()) {
      case 'insert':
      case 'push':
      case 'enqueue':
      case 'inserthead':
        return ColorsManager.success;
      case 'delete':
      case 'pop':
      case 'dequeue':
        return ColorsManager.error;
      case 'search':
      case 'access':
        return ColorsManager.warning;
      default:
        return ColorsManager.info;
    }
  }
}

class _ComplexityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ComplexityBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
