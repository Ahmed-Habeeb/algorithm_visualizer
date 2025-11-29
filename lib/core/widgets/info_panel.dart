import 'package:flutter/material.dart';

import '../theme/colors_manager.dart';

class InfoPanel extends StatelessWidget {
  final String algorithmName;
  final String description;
  final String timeComplexityBest;
  final String timeComplexityAverage;
  final String timeComplexityWorst;
  final String spaceComplexity;
  final String currentStep;
  final String explanation;
  final int stepNumber;
  final int totalSteps;

  const InfoPanel({
    super.key,
    required this.algorithmName,
    required this.description,
    required this.timeComplexityBest,
    required this.timeComplexityAverage,
    required this.timeComplexityWorst,
    required this.spaceComplexity,
    required this.currentStep,
    required this.explanation,
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
              _ComplexityBadge(
                label: currentStep,
                color: ColorsManager.activeElement,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current Explanation
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
              explanation,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Complexity Section
          const Text(
            'Complexity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Time Complexity
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ComplexityBadge(
                label: 'Best: $timeComplexityBest',
                color: ColorsManager.success,
              ),
              _ComplexityBadge(
                label: 'Avg: $timeComplexityAverage',
                color: ColorsManager.warning,
              ),
              _ComplexityBadge(
                label: 'Worst: $timeComplexityWorst',
                color: ColorsManager.error,
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
