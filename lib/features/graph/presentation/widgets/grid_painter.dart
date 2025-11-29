import 'package:flutter/material.dart';

import '../../domain/entities/grid_entity.dart';
import '../../domain/entities/grid_visualization_frame.dart';

/// CustomPainter that renders the pathfinding grid
class GridPainter extends CustomPainter {
  final GridEntity grid;
  final GridVisualizationFrame? frame;
  final double cellSize;
  final bool showGridLines;

  // Colors for different cell states
  static const _colors = {
    GridCellState.empty: Colors.white,
    GridCellState.obstacle: Color(0xFF374151),
    GridCellState.start: Color(0xFF22C55E),
    GridCellState.end: Color(0xFFEF4444),
    GridCellState.visited: Color(0xFF93C5FD),
    GridCellState.current: Color(0xFFF97316),
    GridCellState.path: Color(0xFF4ADE80),
    GridCellState.frontier: Color(0xFFC4B5FD),
  };

  GridPainter({
    required this.grid,
    this.frame,
    required this.cellSize,
    this.showGridLines = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw cells
    for (int y = 0; y < grid.height; y++) {
      for (int x = 0; x < grid.width; x++) {
        _drawCell(canvas, x, y);
      }
    }

    // Draw grid lines
    if (showGridLines) {
      _drawGridLines(canvas, size);
    }

    // Draw start/end markers on top
    if (grid.start != null) {
      _drawMarker(canvas, grid.start!, isStart: true);
    }
    if (grid.end != null) {
      _drawMarker(canvas, grid.end!, isStart: false);
    }
  }

  void _drawCell(Canvas canvas, int x, int y) {
    final rect = Rect.fromLTWH(
      x * cellSize,
      y * cellSize,
      cellSize,
      cellSize,
    );

    // Determine cell state
    GridCellState state = GridCellState.empty;

    // Check obstacles first
    if (grid.obstacles.contains((x, y))) {
      state = GridCellState.obstacle;
    }
    // Check start/end
    else if (grid.start == (x, y)) {
      state = GridCellState.start;
    } else if (grid.end == (x, y)) {
      state = GridCellState.end;
    }
    // Check visualization frame state
    else if (frame != null) {
      state = frame!.cellStates[(x, y)] ?? GridCellState.empty;
      // Preserve start/end in frame
      if (state == GridCellState.start || state == GridCellState.end) {
        // Already handled above
      }
    }

    // Draw cell background
    final paint = Paint()
      ..color = _colors[state] ?? Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Vertical lines
    for (int x = 0; x <= grid.width; x++) {
      canvas.drawLine(
        Offset(x * cellSize, 0),
        Offset(x * cellSize, grid.height * cellSize),
        paint,
      );
    }

    // Horizontal lines
    for (int y = 0; y <= grid.height; y++) {
      canvas.drawLine(
        Offset(0, y * cellSize),
        Offset(grid.width * cellSize, y * cellSize),
        paint,
      );
    }
  }

  void _drawMarker(Canvas canvas, (int, int) pos, {required bool isStart}) {
    final centerX = pos.$1 * cellSize + cellSize / 2;
    final centerY = pos.$2 * cellSize + cellSize / 2;
    final radius = cellSize * 0.3;

    // Draw outer circle
    final outerPaint = Paint()
      ..color = isStart ? const Color(0xFF22C55E) : const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), radius, outerPaint);

    // Draw inner circle (white)
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), radius * 0.5, innerPaint);

    // Draw icon
    final iconPaint = Paint()
      ..color = isStart ? const Color(0xFF22C55E) : const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;

    if (isStart) {
      // Draw play icon (triangle)
      final path = Path();
      final iconSize = radius * 0.4;
      path.moveTo(centerX - iconSize * 0.3, centerY - iconSize);
      path.lineTo(centerX - iconSize * 0.3, centerY + iconSize);
      path.lineTo(centerX + iconSize * 0.7, centerY);
      path.close();
      canvas.drawPath(path, iconPaint);
    } else {
      // Draw flag icon (simple rectangle)
      final iconSize = radius * 0.4;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: iconSize,
          height: iconSize,
        ),
        iconPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return grid != oldDelegate.grid ||
        frame != oldDelegate.frame ||
        cellSize != oldDelegate.cellSize ||
        showGridLines != oldDelegate.showGridLines;
  }
}
