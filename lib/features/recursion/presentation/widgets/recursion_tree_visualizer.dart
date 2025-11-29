import 'package:flutter/material.dart';

import '../../domain/entities/recursion_tree_node_entity.dart';
import '../../domain/entities/recursion_frame_entity.dart';
import 'recursion_tree_painter.dart';

class RecursionTreeVisualizer extends StatefulWidget {
  final RecursionTreeNodeEntity tree;
  final RecursionFrameEntity? frame;

  const RecursionTreeVisualizer({
    super.key,
    required this.tree,
    this.frame,
  });

  @override
  State<RecursionTreeVisualizer> createState() => _RecursionTreeVisualizerState();
}

class _RecursionTreeVisualizerState extends State<RecursionTreeVisualizer> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = RecursionTreePainter(
      tree: widget.tree,
      frame: widget.frame,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final treeSize = painter.treeSize;

        return Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.3,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(200),
              child: SizedBox(
                width: treeSize.width.clamp(constraints.maxWidth, double.infinity),
                height: treeSize.height.clamp(constraints.maxHeight, double.infinity),
                child: CustomPaint(
                  painter: painter,
                  size: treeSize,
                ),
              ),
            ),

            // Zoom controls
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildZoomControls(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildZoomControls() {
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
    final newScale = (currentScale * 1.2).clamp(0.3, 3.0);
    _setZoom(newScale);
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.2).clamp(0.3, 3.0);
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
