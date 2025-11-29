import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

import '../../domain/entities/city_map_entity.dart';
import '../../domain/entities/building_entity.dart';
import 'city_map_painter.dart';

class CityMapVisualizer extends StatefulWidget {
  final CityMapEntity cityMap;
  final Set<String> highlightedStreetIds;
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
  final double initialZoom;
  final double minZoom;
  final double maxZoom;

  const CityMapVisualizer({
    super.key,
    required this.cityMap,
    this.highlightedStreetIds = const {},
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
    this.initialZoom = 1.0,
    this.minZoom = 0.5,
    this.maxZoom = 3.0,
  });

  @override
  State<CityMapVisualizer> createState() => _CityMapVisualizerState();
}

class _CityMapVisualizerState extends State<CityMapVisualizer> {
  late TransformationController _transformationController;
  double _currentZoom = 1.0;
  final double _baseCellSize = 25.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _currentZoom = widget.initialZoom;

    // Set initial scale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialTransform();
    });
  }

  void _setInitialTransform() {
    final matrix = Matrix4.identity()..scale(widget.initialZoom, widget.initialZoom, 1.0);
    _transformationController.value = matrix;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapWidth = widget.cityMap.gridWidth * _baseCellSize;
    final mapHeight = widget.cityMap.gridHeight * _baseCellSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Map with zoom/pan
            Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  _handleScroll(event);
                }
              },
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: widget.minZoom,
                maxScale: widget.maxZoom,
                boundaryMargin: const EdgeInsets.all(100),
                onInteractionUpdate: (details) {
                  setState(() {
                    _currentZoom = _transformationController.value.getMaxScaleOnAxis();
                  });
                },
                child: GestureDetector(
                  onTapUp: _handleTap,
                  onLongPressStart: _handleLongPress,
                  child: SizedBox(
                    width: mapWidth,
                    height: mapHeight,
                    child: CustomPaint(
                      painter: CityMapPainter(
                        cityMap: widget.cityMap,
                        cellSize: _baseCellSize,
                        highlightedStreetIds: widget.highlightedStreetIds,
                        visitedNodeIds: widget.visitedNodeIds,
                        currentNodeIds: widget.currentNodeIds,
                        pathNodeIds: widget.pathNodeIds,
                        startNodeId: widget.startNodeId,
                        endNodeId: widget.endNodeId,
                        showGrid: widget.showGrid,
                        showNodeLabels: widget.showNodeLabels,
                      ),
                      size: Size(mapWidth, mapHeight),
                    ),
                  ),
                ),
              ),
            ),

            // Zoom controls
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildZoomControls(),
            ),

            // Zoom indicator
            Positioned(
              left: 16,
              bottom: 16,
              child: _buildZoomIndicator(),
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
            onPressed: _currentZoom < widget.maxZoom ? _zoomIn : null,
            tooltip: 'Zoom In',
          ),
          Container(
            width: 32,
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _currentZoom > widget.minZoom ? _zoomOut : null,
            tooltip: 'Zoom Out',
          ),
          Container(
            width: 32,
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: _fitToScreen,
            tooltip: 'Fit to Screen',
          ),
        ],
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${(_currentZoom * 100).toInt()}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  void _handleScroll(PointerScrollEvent event) {
    final delta = event.scrollDelta.dy;
    if (delta < 0) {
      _zoomIn();
    } else {
      _zoomOut();
    }
  }

  void _zoomIn() {
    final newZoom = (_currentZoom * 1.2).clamp(widget.minZoom, widget.maxZoom);
    _setZoom(newZoom);
  }

  void _zoomOut() {
    final newZoom = (_currentZoom / 1.2).clamp(widget.minZoom, widget.maxZoom);
    _setZoom(newZoom);
  }

  void _setZoom(double zoom) {
    final matrix = Matrix4.identity()..scale(zoom, zoom, 1.0);
    _transformationController.value = matrix;
    setState(() {
      _currentZoom = zoom;
    });
  }

  void _fitToScreen() {
    _setZoom(1.0);
    _transformationController.value = Matrix4.identity();
  }

  void _handleTap(TapUpDetails details) {
    final localPosition = _getLocalPosition(details.localPosition);
    final gridX = (localPosition.dx / _baseCellSize).floor();
    final gridY = (localPosition.dy / _baseCellSize).floor();

    // Check bounds
    if (gridX < 0 ||
        gridX >= widget.cityMap.gridWidth ||
        gridY < 0 ||
        gridY >= widget.cityMap.gridHeight) {
      return;
    }

    // Check if tapped on a node
    for (final node in widget.cityMap.graph.nodes) {
      final nodeGridX = node.x.toInt();
      final nodeGridY = node.y.toInt();

      if (gridX == nodeGridX && gridY == nodeGridY) {
        widget.onNodeTap?.call(node.id);
        return;
      }
    }

    // Check if tapped on a building
    final building = widget.cityMap.getBuildingAt(gridX, gridY);
    if (building != null) {
      widget.onBuildingTap?.call(building);
      return;
    }

    // Otherwise, callback with cell position
    widget.onCellTap?.call(gridX, gridY);
  }

  void _handleLongPress(LongPressStartDetails details) {
    final localPosition = _getLocalPosition(details.localPosition);
    final gridX = (localPosition.dx / _baseCellSize).floor();
    final gridY = (localPosition.dy / _baseCellSize).floor();

    // Check bounds
    if (gridX < 0 ||
        gridX >= widget.cityMap.gridWidth ||
        gridY < 0 ||
        gridY >= widget.cityMap.gridHeight) {
      return;
    }

    widget.onCellLongPress?.call(gridX, gridY);
  }

  Offset _getLocalPosition(Offset screenPosition) {
    final matrix = _transformationController.value.clone();
    matrix.invert();
    final vector = vector_math.Vector3(screenPosition.dx, screenPosition.dy, 0);
    final transformed = matrix.transform3(vector);
    return Offset(transformed.x, transformed.y);
  }
}
