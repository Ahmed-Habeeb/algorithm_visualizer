import 'package:flutter/material.dart';

/// Legend showing what each color represents in the grid visualization
class GridLegend extends StatelessWidget {
  final bool compact;

  const GridLegend({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = [
      _LegendItem('Start', const Color(0xFF22C55E), Icons.play_arrow),
      _LegendItem('End', const Color(0xFFEF4444), Icons.flag),
      _LegendItem('Current', const Color(0xFFF97316), Icons.location_on),
      _LegendItem('Visited', const Color(0xFF93C5FD), Icons.check_circle_outline),
      _LegendItem('Frontier', const Color(0xFFC4B5FD), Icons.radio_button_unchecked),
      _LegendItem('Path', const Color(0xFF4ADE80), Icons.route),
      _LegendItem('Obstacle', const Color(0xFF374151), Icons.block),
      _LegendItem('Empty', Colors.white, Icons.crop_square),
    ];

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
          Text(
            'Legend',
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: compact ? 6 : 10),
          if (compact)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: items.map((item) => _buildCompactItem(item, colorScheme)).toList(),
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: _buildItem(item, colorScheme),
                )),
        ],
      ),
    );
  }

  Widget _buildItem(_LegendItem item, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: item.color == Colors.white
                  ? Colors.grey.shade400
                  : item.color.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactItem(_LegendItem item, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: item.color == Colors.white
                  ? Colors.grey.shade400
                  : item.color.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LegendItem {
  final String label;
  final Color color;
  final IconData icon;

  const _LegendItem(this.label, this.color, this.icon);
}
