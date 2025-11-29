import 'package:flutter/material.dart';

import '../../domain/entities/sorting_algorithm_entity.dart';
import '../bloc/sorting_comparison_bloc.dart';

/// Widget for selecting sorting algorithms to compare
class SortingAlgorithmSelector extends StatelessWidget {
  final List<SortingAlgorithmEntity> availableAlgorithms;
  final Set<String> selectedAlgorithmIds;
  final void Function(String algorithmId, bool selected) onSelectionChanged;
  final bool compact;

  const SortingAlgorithmSelector({
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
                'Select Algorithms (2-4)',
                style: TextStyle(
                  fontSize: compact ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 12),
          ...availableAlgorithms.map((algorithm) {
            final isSelected = selectedAlgorithmIds.contains(algorithm.id);
            final algorithmColor = getSortingAlgorithmColor(algorithm.id);
            final canSelect = isSelected || selectedAlgorithmIds.length < 4;
            final canDeselect = !isSelected || selectedAlgorithmIds.length > 2;

            return Padding(
              padding: EdgeInsets.only(bottom: compact ? 4 : 6),
              child: InkWell(
                onTap: () {
                  if (isSelected && canDeselect) {
                    onSelectionChanged(algorithm.id, false);
                  } else if (!isSelected && canSelect) {
                    onSelectionChanged(algorithm.id, true);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 12,
                    vertical: compact ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? algorithmColor.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? algorithmColor : Colors.transparent,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: compact ? 20 : 24,
                        height: compact ? 20 : 24,
                        decoration: BoxDecoration(
                          color: algorithmColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            _getInitial(algorithm.id),
                            style: TextStyle(
                              fontSize: compact ? 10 : 12,
                              fontWeight: FontWeight.bold,
                              color: algorithmColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: compact ? 8 : 12),
                      Expanded(
                        child: Text(
                          algorithm.name,
                          style: TextStyle(
                            fontSize: compact ? 11 : 13,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? algorithmColor
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          if (value == true && canSelect) {
                            onSelectionChanged(algorithm.id, true);
                          } else if (value == false && canDeselect) {
                            onSelectionChanged(algorithm.id, false);
                          }
                        },
                        activeColor: algorithmColor,
                        visualDensity: compact
                            ? VisualDensity.compact
                            : VisualDensity.standard,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
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
