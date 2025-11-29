import 'package:flutter/material.dart';

import '../../domain/entities/grid_entity.dart';
import '../../domain/entities/grid_visualization_frame.dart';
import 'grid_painter.dart';

/// Interactive mode for the grid
enum GridInteractionMode {
  drawObstacle,
  eraseObstacle,
  setStart,
  setEnd,
}

/// Interactive widget for displaying and editing the pathfinding grid
class GridVisualizer extends StatefulWidget {
  final GridEntity grid;
  final GridVisualizationFrame? frame;
  final GridInteractionMode mode;
  final Function(int x, int y)? onCellTap;
  final Function(int x, int y)? onCellDrag;
  final bool showGridLines;

  const GridVisualizer({
    super.key,
    required this.grid,
    this.frame,
    this.mode = GridInteractionMode.drawObstacle,
    this.onCellTap,
    this.onCellDrag,
    this.showGridLines = true,
  });

  @override
  State<GridVisualizer> createState() => _GridVisualizerState();
}

class _GridVisualizerState extends State<GridVisualizer> {
  // Track the last cell that was modified during drag
  (int, int)? _lastDragCell;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size to fit grid in available space
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        final cellWidth = availableWidth / widget.grid.width;
        final cellHeight = availableHeight / widget.grid.height;
        final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

        // Calculate actual grid size
        final gridWidth = cellSize * widget.grid.width;
        final gridHeight = cellSize * widget.grid.height;

        return Center(
          child: Container(
            width: gridWidth,
            height: gridHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: GestureDetector(
                onTapDown: (details) => _handleTap(details.localPosition, cellSize),
                onPanStart: (details) {
                  _lastDragCell = null;
                  _handleDrag(details.localPosition, cellSize);
                },
                onPanUpdate: (details) => _handleDrag(details.localPosition, cellSize),
                onPanEnd: (_) => _lastDragCell = null,
                child: CustomPaint(
                  size: Size(gridWidth, gridHeight),
                  painter: GridPainter(
                    grid: widget.grid,
                    frame: widget.frame,
                    cellSize: cellSize,
                    showGridLines: widget.showGridLines,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(Offset position, double cellSize) {
    final cell = _positionToCell(position, cellSize);
    if (cell != null) {
      widget.onCellTap?.call(cell.$1, cell.$2);
    }
  }

  void _handleDrag(Offset position, double cellSize) {
    // Only handle drag for obstacle drawing/erasing
    if (widget.mode != GridInteractionMode.drawObstacle &&
        widget.mode != GridInteractionMode.eraseObstacle) {
      return;
    }

    final cell = _positionToCell(position, cellSize);
    if (cell != null && cell != _lastDragCell) {
      _lastDragCell = cell;
      widget.onCellDrag?.call(cell.$1, cell.$2);
    }
  }

  (int, int)? _positionToCell(Offset position, double cellSize) {
    final x = (position.dx / cellSize).floor();
    final y = (position.dy / cellSize).floor();

    if (widget.grid.isValidCell(x, y)) {
      return (x, y);
    }
    return null;
  }
}
