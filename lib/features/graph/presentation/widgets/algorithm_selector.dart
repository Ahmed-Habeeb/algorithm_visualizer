import 'package:flutter/material.dart';

import '../../domain/entities/graph_algorithm_entity.dart';

/// Widget for selecting algorithms to compare
class AlgorithmSelector extends StatelessWidget {
  final List<GraphAlgorithmEntity> availableAlgorithms;
  final Set<String> selectedAlgorithmIds;
  final Function(String algorithmId, bool selected) onSelectionChanged;
  final bool compact;

  const AlgorithmSelector({
    super.key,
    required this.availableAlgorithms,
    required this.selectedAlgorithmIds,
    required this.onSelectionChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                size: compact ? 16 : 20,
                color: colorScheme.primary,
              ),
              SizedBox(width: compact ? 6 : 8),
              Text(
                'Select Algorithms',
                style: TextStyle(
                  fontSize: compact ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            'Choose 2-4 algorithms to compare',
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          if (compact)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: availableAlgorithms
                  .map((algo) => _buildCompactCheckbox(context, algo))
                  .toList(),
            )
          else
            ...availableAlgorithms.map((algo) => _buildCheckboxTile(context, algo)),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(BuildContext context, GraphAlgorithmEntity algo) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedAlgorithmIds.contains(algo.id);
    final canDeselect = selectedAlgorithmIds.length > 2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          if (isSelected && !canDeselect) return;
          onSelectionChanged(algo.id, !isSelected);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (isSelected && !canDeselect)
                      ? null
                      : (value) => onSelectionChanged(algo.id, value ?? false),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      algo.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      algo.timeComplexity,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAlgorithmBadge(context, algo.id),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCheckbox(BuildContext context, GraphAlgorithmEntity algo) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedAlgorithmIds.contains(algo.id);
    final canDeselect = selectedAlgorithmIds.length > 2;

    return FilterChip(
      label: Text(
        algo.name,
        style: TextStyle(fontSize: 11),
      ),
      selected: isSelected,
      onSelected: (isSelected && !canDeselect)
          ? null
          : (value) => onSelectionChanged(algo.id, value),
      visualDensity: VisualDensity.compact,
      avatar: _buildAlgorithmBadge(context, algo.id, size: 14),
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primaryContainer,
    );
  }

  Widget _buildAlgorithmBadge(BuildContext context, String algorithmId, {double size = 20}) {
    final color = _getAlgorithmColor(algorithmId);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          _getAlgorithmInitial(algorithmId),
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _getAlgorithmColor(String algorithmId) {
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

  String _getAlgorithmInitial(String algorithmId) {
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
