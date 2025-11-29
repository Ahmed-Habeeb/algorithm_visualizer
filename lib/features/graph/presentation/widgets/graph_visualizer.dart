import 'package:flutter/material.dart';

import '../../domain/entities/graph_entity.dart';
import '../../domain/entities/graph_visualization_frame_entity.dart';
import 'graph_painter.dart';

class GraphVisualizer extends StatefulWidget {
  final GraphEntity graph;
  final GraphVisualizationFrameEntity? frame;
  final String? startNode;
  final String? endNode;
  final Function(String nodeId)? onNodeTap;
  final bool selectingStart;
  final bool selectingEnd;

  const GraphVisualizer({
    super.key,
    required this.graph,
    this.frame,
    this.startNode,
    this.endNode,
    this.onNodeTap,
    this.selectingStart = false,
    this.selectingEnd = false,
  });

  @override
  State<GraphVisualizer> createState() => _GraphVisualizerState();
}

class _GraphVisualizerState extends State<GraphVisualizer> {
  String? _hoveredNode;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) => _updateHoveredNode(event.localPosition, constraints),
          onExit: (_) => setState(() => _hoveredNode = null),
          child: GestureDetector(
            onTapUp: (details) => _handleTap(details.localPosition, constraints),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: GraphPainter(
                    graph: widget.graph,
                    frame: widget.frame,
                    startNode: widget.startNode,
                    endNode: widget.endNode,
                    hoveredNode: _hoveredNode,
                    isDarkMode: isDarkMode,
                  ),
                ),
                if (widget.selectingStart || widget.selectingEnd)
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.selectingStart
                              ? Colors.green.withValues(alpha: 0.9)
                              : Colors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.selectingStart
                              ? 'Click a node to set as START'
                              : 'Click a node to set as END',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateHoveredNode(Offset position, BoxConstraints constraints) {
    final node = _getNodeAtPosition(position, constraints);
    if (node != _hoveredNode) {
      setState(() => _hoveredNode = node);
    }
  }

  void _handleTap(Offset position, BoxConstraints constraints) {
    final node = _getNodeAtPosition(position, constraints);
    if (node != null && widget.onNodeTap != null) {
      widget.onNodeTap!(node);
    }
  }

  String? _getNodeAtPosition(Offset position, BoxConstraints constraints) {
    final size = Size(constraints.maxWidth, constraints.maxHeight);
    final nodeRadius = size.width * 0.05;

    for (final node in widget.graph.nodes) {
      final nodeCenter = Offset(
        node.x * size.width,
        node.y * size.height,
      );
      final distance = (position - nodeCenter).distance;
      if (distance <= nodeRadius * 1.5) {
        return node.id;
      }
    }
    return null;
  }
}
