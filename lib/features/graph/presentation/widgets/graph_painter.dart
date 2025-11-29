import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../domain/entities/graph_entity.dart';
import '../../domain/entities/graph_visualization_frame_entity.dart';

class GraphPainter extends CustomPainter {
  final GraphEntity graph;
  final GraphVisualizationFrameEntity? frame;
  final String? startNode;
  final String? endNode;
  final String? hoveredNode;
  final bool isDarkMode;

  GraphPainter({
    required this.graph,
    this.frame,
    this.startNode,
    this.endNode,
    this.hoveredNode,
    this.isDarkMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeRadius = math.min(size.width, size.height) * 0.05;
    final fontSize = nodeRadius * 0.8;

    // Draw edges first
    for (final edge in graph.edges) {
      final fromNode = graph.getNode(edge.from);
      final toNode = graph.getNode(edge.to);
      if (fromNode == null || toNode == null) continue;

      final from = Offset(fromNode.x * size.width, fromNode.y * size.height);
      final to = Offset(toNode.x * size.width, toNode.y * size.height);

      final edgeKey = '${edge.from}-${edge.to}';
      final reverseEdgeKey = '${edge.to}-${edge.from}';
      final edgeState = frame?.edgeStates[edgeKey] ?? frame?.edgeStates[reverseEdgeKey];

      Color edgeColor;
      double strokeWidth = 2.0;

      switch (edgeState) {
        case GraphEdgeState.path:
          edgeColor = Colors.green;
          strokeWidth = 4.0;
          break;
        case GraphEdgeState.visited:
          edgeColor = Colors.blue;
          strokeWidth = 3.0;
          break;
        case GraphEdgeState.considering:
          edgeColor = Colors.orange;
          strokeWidth = 3.0;
          break;
        case GraphEdgeState.rejected:
          edgeColor = Colors.red.withValues(alpha: 0.3);
          break;
        default:
          edgeColor = isDarkMode ? Colors.white30 : Colors.black26;
      }

      final edgePaint = Paint()
        ..color = edgeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawLine(from, to, edgePaint);

      // Draw weight label if weighted
      if (graph.isWeighted) {
        final midpoint = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
        final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
        final offset = Offset(
          -math.sin(angle) * 12,
          math.cos(angle) * 12,
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: edge.weight.toStringAsFixed(0),
            style: TextStyle(
              color: edgeColor == Colors.green ? Colors.green : (isDarkMode ? Colors.white70 : Colors.black54),
              fontSize: fontSize * 0.7,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          midpoint + offset - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      // Draw arrow if directed
      if (graph.isDirected) {
        final direction = (to - from).direction;
        final arrowEnd = to - Offset.fromDirection(direction, nodeRadius + 5);
        final arrowSize = 10.0;

        final path = Path()
          ..moveTo(arrowEnd.dx, arrowEnd.dy)
          ..lineTo(
            arrowEnd.dx - arrowSize * math.cos(direction - 0.4),
            arrowEnd.dy - arrowSize * math.sin(direction - 0.4),
          )
          ..moveTo(arrowEnd.dx, arrowEnd.dy)
          ..lineTo(
            arrowEnd.dx - arrowSize * math.cos(direction + 0.4),
            arrowEnd.dy - arrowSize * math.sin(direction + 0.4),
          );

        canvas.drawPath(path, edgePaint);
      }
    }

    // Draw nodes
    for (final node in graph.nodes) {
      final center = Offset(node.x * size.width, node.y * size.height);
      final nodeState = frame?.nodeStates[node.id];

      Color fillColor;
      Color borderColor;
      double borderWidth = 2.0;

      // Determine colors based on state
      if (node.id == startNode || nodeState == GraphNodeState.start) {
        fillColor = Colors.green;
        borderColor = Colors.green.shade700;
        borderWidth = 3.0;
      } else if (node.id == endNode || nodeState == GraphNodeState.end) {
        fillColor = Colors.red;
        borderColor = Colors.red.shade700;
        borderWidth = 3.0;
      } else if (nodeState == GraphNodeState.path) {
        fillColor = Colors.green.shade300;
        borderColor = Colors.green;
        borderWidth = 3.0;
      } else if (nodeState == GraphNodeState.current) {
        fillColor = Colors.orange;
        borderColor = Colors.orange.shade700;
        borderWidth = 3.0;
      } else if (nodeState == GraphNodeState.visiting) {
        fillColor = Colors.yellow;
        borderColor = Colors.yellow.shade700;
      } else if (nodeState == GraphNodeState.inQueue || nodeState == GraphNodeState.inStack) {
        fillColor = Colors.lightBlue;
        borderColor = Colors.blue;
      } else if (nodeState == GraphNodeState.visited) {
        fillColor = Colors.blue;
        borderColor = Colors.blue.shade700;
      } else {
        fillColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
        borderColor = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500;
      }

      // Hover effect
      if (node.id == hoveredNode) {
        borderColor = Colors.purple;
        borderWidth = 4.0;
      }

      // Draw node
      final fillPaint = Paint()..color = fillColor;
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      canvas.drawCircle(center, nodeRadius, fillPaint);
      canvas.drawCircle(center, nodeRadius, borderPaint);

      // Draw label
      final textColor = _getContrastColor(fillColor);
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.label ?? node.id,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    return graph != oldDelegate.graph ||
        frame != oldDelegate.frame ||
        startNode != oldDelegate.startNode ||
        endNode != oldDelegate.endNode ||
        hoveredNode != oldDelegate.hoveredNode ||
        isDarkMode != oldDelegate.isDarkMode;
  }
}
