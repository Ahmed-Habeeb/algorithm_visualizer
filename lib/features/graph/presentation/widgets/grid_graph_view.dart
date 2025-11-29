import 'package:flutter/material.dart';

import '../../domain/entities/grid_entity.dart';
import '../../domain/entities/grid_visualization_frame.dart';

/// Displays a node-edge graph representation of the grid
class GridGraphView extends StatelessWidget {
  final GridEntity grid;
  final GridVisualizationFrame? frame;
  final double maxSize;

  const GridGraphView({
    super.key,
    required this.grid,
    this.frame,
    this.maxSize = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxSize, maxHeight: maxSize),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          size: Size(maxSize, maxSize),
          painter: _GridGraphPainter(
            grid: grid,
            frame: frame,
          ),
        ),
      ),
    );
  }
}

class _GridGraphPainter extends CustomPainter {
  final GridEntity grid;
  final GridVisualizationFrame? frame;

  _GridGraphPainter({
    required this.grid,
    this.frame,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / grid.width;
    final cellHeight = size.height / grid.height;
    final nodeRadius = (cellWidth < cellHeight ? cellWidth : cellHeight) * 0.25;

    // Draw edges first (so nodes appear on top)
    _drawEdges(canvas, size, cellWidth, cellHeight, nodeRadius);

    // Draw nodes
    _drawNodes(canvas, size, cellWidth, cellHeight, nodeRadius);
  }

  void _drawEdges(Canvas canvas, Size size, double cellWidth, double cellHeight, double nodeRadius) {
    final edgePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final pathEdgePaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final visitedEdgePaint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = frame?.path ?? [];
    final pathSet = path.toSet();

    for (int x = 0; x < grid.width; x++) {
      for (int y = 0; y < grid.height; y++) {
        if (grid.obstacles.contains((x, y))) continue;

        final centerX = x * cellWidth + cellWidth / 2;
        final centerY = y * cellHeight + cellHeight / 2;

        // Draw edges to right and down neighbors only (to avoid duplicates)
        final neighbors = [
          (x + 1, y), // Right
          (x, y + 1), // Down
        ];

        for (final (nx, ny) in neighbors) {
          if (!grid.isWalkable(nx, ny)) continue;

          final neighborCenterX = nx * cellWidth + cellWidth / 2;
          final neighborCenterY = ny * cellHeight + cellHeight / 2;

          // Check if this edge is part of the path
          final isPathEdge = pathSet.contains((x, y)) && pathSet.contains((nx, ny)) &&
              _areAdjacent(x, y, nx, ny, path);

          // Check if both nodes are visited
          final cellStates = frame?.cellStates ?? {};
          final isVisitedEdge = (cellStates[(x, y)] == GridCellState.visited ||
                  cellStates[(x, y)] == GridCellState.path) &&
              (cellStates[(nx, ny)] == GridCellState.visited ||
                  cellStates[(nx, ny)] == GridCellState.path);

          Paint paint;
          if (isPathEdge) {
            paint = pathEdgePaint;
          } else if (isVisitedEdge) {
            paint = visitedEdgePaint;
          } else {
            paint = edgePaint;
          }

          canvas.drawLine(
            Offset(centerX, centerY),
            Offset(neighborCenterX, neighborCenterY),
            paint,
          );
        }
      }
    }
  }

  bool _areAdjacent(int x1, int y1, int x2, int y2, List<(int, int)> path) {
    for (int i = 0; i < path.length - 1; i++) {
      if ((path[i] == (x1, y1) && path[i + 1] == (x2, y2)) ||
          (path[i] == (x2, y2) && path[i + 1] == (x1, y1))) {
        return true;
      }
    }
    return false;
  }

  void _drawNodes(Canvas canvas, Size size, double cellWidth, double cellHeight, double nodeRadius) {
    for (int x = 0; x < grid.width; x++) {
      for (int y = 0; y < grid.height; y++) {
        final centerX = x * cellWidth + cellWidth / 2;
        final centerY = y * cellHeight + cellHeight / 2;

        final color = _getNodeColor(x, y);
        if (color == null) continue; // Skip obstacles

        final nodePaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        final borderPaint = Paint()
          ..color = color.withValues(alpha: 0.8)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

        canvas.drawCircle(Offset(centerX, centerY), nodeRadius, nodePaint);
        canvas.drawCircle(Offset(centerX, centerY), nodeRadius, borderPaint);

        // Draw current cell indicator
        if (frame?.currentCell == (x, y)) {
          final highlightPaint = Paint()
            ..color = Colors.white
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(Offset(centerX, centerY), nodeRadius * 0.5, highlightPaint);
        }
      }
    }
  }

  Color? _getNodeColor(int x, int y) {
    if (grid.obstacles.contains((x, y))) return null;

    if ((x, y) == grid.start) return const Color(0xFF22C55E); // Green
    if ((x, y) == grid.end) return const Color(0xFFEF4444); // Red

    final cellState = frame?.cellStates[(x, y)];
    switch (cellState) {
      case GridCellState.current:
        return const Color(0xFFF97316); // Orange
      case GridCellState.path:
        return const Color(0xFF4ADE80); // Bright green
      case GridCellState.visited:
        return const Color(0xFF93C5FD); // Light blue
      case GridCellState.frontier:
        return const Color(0xFFC4B5FD); // Light purple
      default:
        return Colors.grey.shade300; // Empty
    }
  }

  @override
  bool shouldRepaint(covariant _GridGraphPainter oldDelegate) {
    return oldDelegate.grid != grid || oldDelegate.frame != frame;
  }
}
