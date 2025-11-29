import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../domain/entities/recursion_tree_node_entity.dart';
import '../../domain/entities/recursion_frame_entity.dart';

class RecursionTreePainter extends CustomPainter {
  final RecursionTreeNodeEntity tree;
  final RecursionFrameEntity? frame;
  final double nodeRadius;
  final double horizontalSpacing;
  final double verticalSpacing;

  late Map<String, Offset> _nodePositions;
  late double _treeWidth;
  late double _treeHeight;

  RecursionTreePainter({
    required this.tree,
    this.frame,
    this.nodeRadius = 25,
    this.horizontalSpacing = 20,
    this.verticalSpacing = 80,
  }) {
    _calculatePositions();
  }

  void _calculatePositions() {
    _nodePositions = {};
    final maxDepth = _getMaxDepth(tree);
    _treeHeight = (maxDepth + 1) * verticalSpacing + nodeRadius * 2;

    // Calculate width for each subtree
    final widths = <String, double>{};
    _calculateSubtreeWidths(tree, widths);

    // Position nodes
    _positionNodes(tree, 0, widths);

    // Calculate total tree width
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    for (final pos in _nodePositions.values) {
      minX = math.min(minX, pos.dx);
      maxX = math.max(maxX, pos.dx);
    }
    _treeWidth = maxX - minX + nodeRadius * 4;

    // Normalize positions to start from 0
    final offsetX = -minX + nodeRadius * 2;
    final newPositions = <String, Offset>{};
    for (final entry in _nodePositions.entries) {
      newPositions[entry.key] = Offset(entry.value.dx + offsetX, entry.value.dy);
    }
    _nodePositions = newPositions;
  }

  int _getMaxDepth(RecursionTreeNodeEntity node) {
    if (node.children.isEmpty) return node.depth;
    int maxChildDepth = node.depth;
    for (final child in node.children) {
      maxChildDepth = math.max(maxChildDepth, _getMaxDepth(child));
    }
    return maxChildDepth;
  }

  double _calculateSubtreeWidths(
    RecursionTreeNodeEntity node,
    Map<String, double> widths,
  ) {
    if (node.children.isEmpty) {
      widths[node.id] = nodeRadius * 2 + horizontalSpacing;
      return widths[node.id]!;
    }

    double totalWidth = 0;
    for (final child in node.children) {
      totalWidth += _calculateSubtreeWidths(child, widths);
    }
    totalWidth = math.max(totalWidth, nodeRadius * 2 + horizontalSpacing);
    widths[node.id] = totalWidth;
    return totalWidth;
  }

  void _positionNodes(
    RecursionTreeNodeEntity node,
    double startX,
    Map<String, double> widths,
  ) {
    final y = node.depth * verticalSpacing + nodeRadius + 20;
    final width = widths[node.id]!;
    final x = startX + width / 2;

    _nodePositions[node.id] = Offset(x, y);

    if (node.children.isNotEmpty) {
      double childX = startX;
      for (final child in node.children) {
        _positionNodes(child, childX, widths);
        childX += widths[child.id]!;
      }
    }
  }

  Size get treeSize => Size(_treeWidth, _treeHeight);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges first
    _drawEdges(canvas, tree);

    // Draw nodes on top
    _drawNodes(canvas, tree);
  }

  void _drawEdges(Canvas canvas, RecursionTreeNodeEntity node) {
    final nodePos = _nodePositions[node.id];
    if (nodePos == null) return;

    for (final child in node.children) {
      final childPos = _nodePositions[child.id];
      if (childPos == null) continue;

      final childState = frame?.nodeStates[child.id];
      Color edgeColor;

      if (childState == RecursionNodeState.completed) {
        edgeColor = Colors.green.shade400;
      } else if (childState == RecursionNodeState.active ||
          childState == RecursionNodeState.computing) {
        edgeColor = Colors.orange.shade400;
      } else {
        edgeColor = Colors.grey.shade400;
      }

      final edgePaint = Paint()
        ..color = edgeColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // Draw curved edge
      final path = Path();
      path.moveTo(nodePos.dx, nodePos.dy + nodeRadius);

      final midY = (nodePos.dy + childPos.dy) / 2;
      path.cubicTo(
        nodePos.dx,
        midY,
        childPos.dx,
        midY,
        childPos.dx,
        childPos.dy - nodeRadius,
      );

      canvas.drawPath(path, edgePaint);

      // Draw arrow head
      _drawArrowHead(canvas, childPos, edgeColor);

      // Draw return value on edge if available
      final returnValue = frame?.returnValues[child.id];
      if (returnValue != null && childState == RecursionNodeState.completed) {
        _drawReturnValueOnEdge(canvas, nodePos, childPos, returnValue);
      }

      _drawEdges(canvas, child);
    }
  }

  void _drawArrowHead(Canvas canvas, Offset to, Color color) {
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    final arrowSize = 8.0;
    final y = to.dy - nodeRadius;

    arrowPath.moveTo(to.dx, y);
    arrowPath.lineTo(to.dx - arrowSize / 2, y - arrowSize);
    arrowPath.lineTo(to.dx + arrowSize / 2, y - arrowSize);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  void _drawReturnValueOnEdge(
    Canvas canvas,
    Offset from,
    Offset to,
    String value,
  ) {
    final midX = (from.dx + to.dx) / 2;
    final midY = (from.dy + to.dy) / 2;

    // Draw background
    final bgPaint = Paint()
      ..color = Colors.green.shade100
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: Colors.green.shade800,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(midX + 15, midY),
        width: textPainter.width + 8,
        height: textPainter.height + 4,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(bgRect, bgPaint);

    // Draw text
    textPainter.paint(
      canvas,
      Offset(
        midX + 15 - textPainter.width / 2,
        midY - textPainter.height / 2,
      ),
    );
  }

  void _drawNodes(Canvas canvas, RecursionTreeNodeEntity node) {
    final pos = _nodePositions[node.id];
    if (pos == null) return;

    final nodeState = frame?.nodeStates[node.id] ?? RecursionNodeState.pending;
    final isActive = frame?.activeNodeId == node.id;

    // Determine colors based on state
    Color fillColor;
    Color borderColor;
    Color textColor;

    switch (nodeState) {
      case RecursionNodeState.pending:
        fillColor = Colors.grey.shade200;
        borderColor = Colors.grey.shade400;
        textColor = Colors.grey.shade700;
        break;
      case RecursionNodeState.active:
        fillColor = Colors.orange.shade100;
        borderColor = Colors.orange;
        textColor = Colors.orange.shade900;
        break;
      case RecursionNodeState.computing:
        fillColor = Colors.purple.shade100;
        borderColor = Colors.purple;
        textColor = Colors.purple.shade900;
        break;
      case RecursionNodeState.returning:
        fillColor = Colors.blue.shade100;
        borderColor = Colors.blue;
        textColor = Colors.blue.shade900;
        break;
      case RecursionNodeState.completed:
        fillColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
        break;
    }

    // Draw glow for active node
    if (isActive) {
      final glowPaint = Paint()
        ..color = borderColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(pos, nodeRadius + 5, glowPaint);
    }

    // Draw node circle
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 3 : 2;

    canvas.drawCircle(pos, nodeRadius, fillPaint);
    canvas.drawCircle(pos, nodeRadius, borderPaint);

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );

    // Draw return value badge if completed
    final returnValue = frame?.returnValues[node.id];
    if (returnValue != null && nodeState == RecursionNodeState.completed) {
      _drawReturnValueBadge(canvas, pos, returnValue);
    }

    // Draw children
    for (final child in node.children) {
      _drawNodes(canvas, child);
    }
  }

  void _drawReturnValueBadge(Canvas canvas, Offset pos, String value) {
    final badgePos = Offset(pos.dx + nodeRadius - 5, pos.dy - nodeRadius + 5);

    // Draw badge background
    final bgPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final badgeRadius = math.max(textPainter.width, textPainter.height) / 2 + 4;
    canvas.drawCircle(badgePos, badgeRadius, bgPaint);

    // Draw text
    textPainter.paint(
      canvas,
      Offset(
        badgePos.dx - textPainter.width / 2,
        badgePos.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant RecursionTreePainter oldDelegate) {
    return tree != oldDelegate.tree || frame != oldDelegate.frame;
  }
}
