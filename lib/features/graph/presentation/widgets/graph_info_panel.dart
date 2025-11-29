import 'package:flutter/material.dart';

import '../../../../core/theme/colors_manager.dart';
import '../../domain/entities/graph_visualization_frame_entity.dart';

class GraphInfoPanel extends StatelessWidget {
  final String algorithmName;
  final String description;
  final String timeComplexity;
  final String spaceComplexity;
  final GraphVisualizationFrameEntity? currentFrame;
  final int stepNumber;
  final int totalSteps;

  const GraphInfoPanel({
    super.key,
    required this.algorithmName,
    required this.description,
    required this.timeComplexity,
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

            // Data structures visualization
            if (currentFrame != null) ...[
              if (currentFrame!.queue.isNotEmpty) ...[
                _DataStructureDisplay(
                  label: 'Queue',
                  items: currentFrame!.queue,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
              ],
              if (currentFrame!.stack.isNotEmpty) ...[
                _DataStructureDisplay(
                  label: 'Stack',
                  items: currentFrame!.stack,
                  color: Colors.purple,
                ),
                const SizedBox(height: 8),
              ],
              if (currentFrame!.path.isNotEmpty) ...[
                _DataStructureDisplay(
                  label: 'Path',
                  items: currentFrame!.path,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],

          // Complexity Section
          const Text(
            'Complexity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ComplexityBadge(
                label: 'Time: $timeComplexity',
                color: ColorsManager.warning,
              ),
              _ComplexityBadge(
                label: 'Space: $spaceComplexity',
                color: ColorsManager.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataStructureDisplay extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color color;

  const _DataStructureDisplay({
    required this.label,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((item) {
              return Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
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
