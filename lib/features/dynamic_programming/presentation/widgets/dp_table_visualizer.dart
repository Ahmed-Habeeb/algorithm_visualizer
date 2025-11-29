import 'package:flutter/material.dart';

import '../../domain/entities/dp_frame_entity.dart';

class DPTableVisualizer extends StatefulWidget {
  final DPFrameEntity frame;
  final List<String>? rowLabels;
  final List<String>? colLabels;

  const DPTableVisualizer({
    super.key,
    required this.frame,
    this.rowLabels,
    this.colLabels,
  });

  @override
  State<DPTableVisualizer> createState() => _DPTableVisualizerState();
}

class _DPTableVisualizerState extends State<DPTableVisualizer> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(100),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildTable(context),
                  ),
                ),
              ),
            ),

            // Zoom controls
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildZoomControls(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTable(BuildContext context) {
    final table = widget.frame.table;
    if (table.isEmpty) return const SizedBox.shrink();

    final rows = table.length;
    final cols = table[0].length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column labels (if provided)
        if (widget.colLabels != null)
          Row(
            children: [
              const SizedBox(width: 50), // Space for row labels
              ...List.generate(cols, (j) {
                final label = j < widget.colLabels!.length ? widget.colLabels![j] : '$j';
                return _buildHeaderCell(context, label);
              }),
            ],
          ),

        // Table rows
        ...List.generate(rows, (i) {
          return Row(
            children: [
              // Row label
              if (widget.rowLabels != null)
                _buildHeaderCell(
                  context,
                  i < widget.rowLabels!.length ? widget.rowLabels![i] : '$i',
                )
              else
                _buildHeaderCell(context, '$i'),

              // Data cells
              ...List.generate(cols, (j) {
                return _buildCell(context, i, j, table[i][j]);
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 50,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, int row, int col, dynamic value) {
    final colorScheme = Theme.of(context).colorScheme;
    final cellKey = '$row,$col';
    final state = widget.frame.cellStates[cellKey] ?? DPCellState.empty;
    final isActive = widget.frame.activeRow == row && widget.frame.activeCol == col;

    Color bgColor;
    Color borderColor;
    double borderWidth = 1;

    switch (state) {
      case DPCellState.empty:
        bgColor = colorScheme.surface;
        borderColor = colorScheme.outlineVariant;
        break;
      case DPCellState.computing:
        bgColor = Colors.orange.shade100;
        borderColor = Colors.orange;
        borderWidth = 2;
        break;
      case DPCellState.computed:
        bgColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade200;
        break;
      case DPCellState.highlighted:
        bgColor = Colors.green.shade100;
        borderColor = Colors.green;
        borderWidth = 2;
        break;
      case DPCellState.path:
        bgColor = Colors.purple.shade100;
        borderColor = Colors.purple;
        borderWidth = 2;
        break;
    }

    if (isActive) {
      bgColor = Colors.orange.shade200;
      borderColor = Colors.orange;
      borderWidth = 3;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 50,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildZoomControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
          ),
          Container(
            width: 32,
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
          ),
          Container(
            width: 32,
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: _resetZoom,
            tooltip: 'Reset Zoom',
          ),
        ],
      ),
    );
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.2).clamp(0.5, 3.0);
    _setZoom(newScale);
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.2).clamp(0.5, 3.0);
    _setZoom(newScale);
  }

  void _setZoom(double scale) {
    final matrix = Matrix4.identity()..scale(scale, scale, 1.0);
    _transformationController.value = matrix;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }
}
