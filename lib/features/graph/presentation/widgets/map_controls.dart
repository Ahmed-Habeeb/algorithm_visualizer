import 'package:flutter/material.dart';

import '../../data/map_generator.dart';
import '../../domain/entities/obstacle_entity.dart';

class MapControls extends StatefulWidget {
  final int currentWidth;
  final int currentHeight;
  final bool isVisualizationRunning;
  final Function(int width, int height) onSizeChanged;
  final VoidCallback onRegenerateMap;
  final Function(ObstacleType type)? onAddObstacleMode;
  final VoidCallback? onClearObstacles;
  final Function(CityMapPreset preset)? onLoadPreset;

  const MapControls({
    super.key,
    required this.currentWidth,
    required this.currentHeight,
    this.isVisualizationRunning = false,
    required this.onSizeChanged,
    required this.onRegenerateMap,
    this.onAddObstacleMode,
    this.onClearObstacles,
    this.onLoadPreset,
  });

  @override
  State<MapControls> createState() => _MapControlsState();
}

class _MapControlsState extends State<MapControls> {
  late int _width;
  late int _height;
  ObstacleType? _selectedObstacleType;

  @override
  void initState() {
    super.initState();
    _width = widget.currentWidth;
    _height = widget.currentHeight;
  }

  @override
  void didUpdateWidget(covariant MapControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWidth != widget.currentWidth) {
      _width = widget.currentWidth;
    }
    if (oldWidget.currentHeight != widget.currentHeight) {
      _height = widget.currentHeight;
    }
  }

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Map Controls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Map Size Controls
          _buildSizeControls(context),
          const SizedBox(height: 16),

          // Presets
          _buildPresets(context),
          const SizedBox(height: 16),

          // Regenerate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.isVisualizationRunning ? null : widget.onRegenerateMap,
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Obstacle Controls
          if (widget.onAddObstacleMode != null) ...[
            const Divider(),
            const SizedBox(height: 12),
            _buildObstacleControls(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSizeControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Map Size',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        // Width Slider
        Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                'Width:',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Slider(
                value: _width.toDouble(),
                min: 10,
                max: 50,
                divisions: 8,
                label: '$_width',
                onChanged: widget.isVisualizationRunning
                    ? null
                    : (value) {
                        setState(() {
                          _width = value.toInt();
                        });
                      },
                onChangeEnd: widget.isVisualizationRunning
                    ? null
                    : (value) {
                        widget.onSizeChanged(_width, _height);
                      },
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$_width',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),

        // Height Slider
        Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                'Height:',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Slider(
                value: _height.toDouble(),
                min: 10,
                max: 50,
                divisions: 8,
                label: '$_height',
                onChanged: widget.isVisualizationRunning
                    ? null
                    : (value) {
                        setState(() {
                          _height = value.toInt();
                        });
                      },
                onChangeEnd: widget.isVisualizationRunning
                    ? null
                    : (value) {
                        widget.onSizeChanged(_width, _height);
                      },
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$_height',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresets(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetChip(context, 'Small', CityMapPreset.small),
            _buildPresetChip(context, 'Medium', CityMapPreset.medium),
            _buildPresetChip(context, 'Large', CityMapPreset.large),
            _buildPresetChip(context, 'Maze', CityMapPreset.maze),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip(BuildContext context, String label, CityMapPreset preset) {
    return ActionChip(
      label: Text(label),
      onPressed: widget.isVisualizationRunning
          ? null
          : () => widget.onLoadPreset?.call(preset),
    );
  }

  Widget _buildObstacleControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Obstacles',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap a street cell to add/remove obstacles',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        // Obstacle type selection
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ObstacleType.values.map((type) {
            final isSelected = _selectedObstacleType == type;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(type.icon),
                  const SizedBox(width: 4),
                  Text(type.displayName),
                ],
              ),
              selected: isSelected,
              onSelected: widget.isVisualizationRunning
                  ? null
                  : (selected) {
                      setState(() {
                        _selectedObstacleType = selected ? type : null;
                      });
                      if (selected) {
                        widget.onAddObstacleMode?.call(type);
                      }
                    },
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Clear Obstacles Button
        if (widget.onClearObstacles != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.isVisualizationRunning ? null : widget.onClearObstacles,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All Obstacles'),
            ),
          ),
      ],
    );
  }
}
