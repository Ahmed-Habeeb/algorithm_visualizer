import 'package:flutter/material.dart';

import '../../../../core/utils/adaptive_layout.dart';
import '../../domain/entities/city_map_entity.dart';
import '../../domain/entities/building_entity.dart';
import '../../domain/entities/graph_visualization_frame_entity.dart';
import 'city_map_visualizer.dart';
import 'graph_visualizer.dart';

class DualViewContainer extends StatelessWidget {
  final CityMapEntity cityMap;
  final GraphVisualizationFrameEntity? currentFrame;
  final Set<String> visitedNodeIds;
  final Set<String> currentNodeIds;
  final List<String>? pathNodeIds;
  final String? startNodeId;
  final String? endNodeId;
  final bool showGrid;
  final bool showNodeLabels;
  final Function(String nodeId)? onNodeTap;
  final Function(BuildingEntity building)? onBuildingTap;
  final Function(int gridX, int gridY)? onCellTap;
  final Function(int gridX, int gridY)? onCellLongPress;

  const DualViewContainer({
    super.key,
    required this.cityMap,
    this.currentFrame,
    this.visitedNodeIds = const {},
    this.currentNodeIds = const {},
    this.pathNodeIds,
    this.startNodeId,
    this.endNodeId,
    this.showGrid = true,
    this.showNodeLabels = false,
    this.onNodeTap,
    this.onBuildingTap,
    this.onCellTap,
    this.onCellLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // City Map View
        Expanded(
          child: _buildMapView(context, 'City Map'),
        ),
        const SizedBox(width: 16),
        // Graph View
        Expanded(
          child: _buildGraphView(context, 'Graph View'),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // City Map View
        Expanded(
          child: _buildMapView(context, 'Map'),
        ),
        const SizedBox(width: 12),
        // Graph View
        Expanded(
          child: _buildGraphView(context, 'Graph'),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // City Map View
        Expanded(
          child: _buildMapView(context, 'City Map'),
        ),
        const SizedBox(height: 12),
        // Graph View
        Expanded(
          child: _buildGraphView(context, 'Graph View'),
        ),
      ],
    );
  }

  Widget _buildMapView(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get highlighted streets from path
    final highlightedStreetIds = <String>{};
    if (pathNodeIds != null && pathNodeIds!.isNotEmpty) {
      // Find streets that contain path segments
      for (final street in cityMap.streets) {
        for (int i = 0; i < pathNodeIds!.length - 1; i++) {
          final fromNode = cityMap.graph.getNode(pathNodeIds![i]);
          final toNode = cityMap.graph.getNode(pathNodeIds![i + 1]);

          if (fromNode != null && toNode != null) {
            // Check if this street contains both nodes
            final hasFrom = street.path.any(
              (s) => s.x == fromNode.x.toInt() && s.y == fromNode.y.toInt(),
            );
            final hasTo = street.path.any(
              (s) => s.x == toNode.x.toInt() && s.y == toNode.y.toInt(),
            );

            if (hasFrom && hasTo) {
              highlightedStreetIds.add(street.id);
            }
          }
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.map,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                _buildLegendButton(context, _showMapLegend),
              ],
            ),
          ),
          // Map
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              child: CityMapVisualizer(
                cityMap: cityMap,
                highlightedStreetIds: highlightedStreetIds,
                visitedNodeIds: visitedNodeIds,
                currentNodeIds: currentNodeIds,
                pathNodeIds: pathNodeIds,
                startNodeId: startNodeId,
                endNodeId: endNodeId,
                showGrid: showGrid,
                showNodeLabels: showNodeLabels,
                onNodeTap: onNodeTap,
                onBuildingTap: onBuildingTap,
                onCellTap: onCellTap,
                onCellLongPress: onCellLongPress,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphView(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.hub,
                  size: 20,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                _buildLegendButton(context, _showGraphLegend),
              ],
            ),
          ),
          // Graph
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              child: GraphVisualizer(
                graph: cityMap.graph,
                frame: currentFrame ?? _buildDefaultFrame(),
                startNode: startNodeId,
                endNode: endNodeId,
                onNodeTap: onNodeTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendButton(BuildContext context, Function(BuildContext) onPressed) {
    return IconButton(
      icon: const Icon(Icons.help_outline, size: 18),
      onPressed: () => onPressed(context),
      tooltip: 'Legend',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
    );
  }

  void _showMapLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map Legend'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendSection('Buildings', [
                _buildLegendItem(Colors.blue.shade300, '🏠', 'House'),
                _buildLegendItem(Colors.blueGrey.shade400, '🏢', 'Office'),
                _buildLegendItem(Colors.red.shade300, '🏥', 'Hospital'),
                _buildLegendItem(Colors.orange.shade300, '🍽️', 'Restaurant'),
                _buildLegendItem(Colors.yellow.shade400, '🏫', 'School'),
              ]),
              const SizedBox(height: 16),
              _buildLegendSection('Streets', [
                _buildLegendItem(const Color(0xFF424242), null, 'Highway (fast)'),
                _buildLegendItem(const Color(0xFF616161), null, 'Road (normal)'),
                _buildLegendItem(const Color(0xFF9E9E9E), null, 'Alley (slow)'),
              ]),
              const SizedBox(height: 16),
              _buildLegendSection('Markers', [
                _buildLegendItem(Colors.green, 'S', 'Start Point'),
                _buildLegendItem(Colors.red, 'E', 'End Point'),
                _buildLegendItem(Colors.green.shade400, null, 'Path'),
              ]),
              const SizedBox(height: 16),
              _buildLegendSection('Obstacles', [
                _buildLegendItem(Colors.red.shade100, '🚧', 'Roadblock'),
                _buildLegendItem(Colors.red.shade100, '🏗️', 'Construction'),
                _buildLegendItem(Colors.red.shade100, '⛔', 'Closed Road'),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showGraphLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Graph Legend'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendSection('Nodes', [
                _buildLegendItem(Colors.grey.shade600, null, 'Unvisited'),
                _buildLegendItem(Colors.blue.shade300, null, 'Visited'),
                _buildLegendItem(Colors.purple, null, 'Current'),
                _buildLegendItem(Colors.green, 'S', 'Start'),
                _buildLegendItem(Colors.red, 'E', 'End'),
              ]),
              const SizedBox(height: 16),
              _buildLegendSection('Edges', [
                _buildLegendItem(Colors.grey, null, 'Normal edge'),
                _buildLegendItem(Colors.green.shade400, null, 'Path edge'),
                _buildLegendItem(Colors.blue.shade300, null, 'Visited edge'),
              ]),
              const SizedBox(height: 16),
              const Text(
                'Edge weights are based on street type:\n'
                '• Highway: 0.5x weight (fast)\n'
                '• Road: 1.0x weight (normal)\n'
                '• Alley: 2.0x weight (slow)',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildLegendItem(Color color, String? icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: icon != null
                ? Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 12),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  GraphVisualizationFrameEntity _buildDefaultFrame() {
    // Build node states from visited/current nodes
    final nodeStates = <String, GraphNodeState>{};

    for (final node in cityMap.graph.nodes) {
      if (node.id == startNodeId) {
        nodeStates[node.id] = GraphNodeState.start;
      } else if (node.id == endNodeId) {
        nodeStates[node.id] = GraphNodeState.end;
      } else if (currentNodeIds.contains(node.id)) {
        nodeStates[node.id] = GraphNodeState.current;
      } else if (pathNodeIds?.contains(node.id) ?? false) {
        nodeStates[node.id] = GraphNodeState.path;
      } else if (visitedNodeIds.contains(node.id)) {
        nodeStates[node.id] = GraphNodeState.visited;
      } else {
        nodeStates[node.id] = GraphNodeState.unvisited;
      }
    }

    // Build edge states from path
    final edgeStates = <String, GraphEdgeState>{};

    if (pathNodeIds != null && pathNodeIds!.length > 1) {
      for (int i = 0; i < pathNodeIds!.length - 1; i++) {
        final from = pathNodeIds![i];
        final to = pathNodeIds![i + 1];
        edgeStates['$from-$to'] = GraphEdgeState.path;
        edgeStates['$to-$from'] = GraphEdgeState.path;
      }
    }

    return GraphVisualizationFrameEntity(
      nodeStates: nodeStates,
      edgeStates: edgeStates,
      operation: '',
      explanation: '',
      path: pathNodeIds ?? [],
    );
  }
}
