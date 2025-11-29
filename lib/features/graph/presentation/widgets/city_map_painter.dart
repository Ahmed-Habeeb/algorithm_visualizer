import 'package:flutter/material.dart';

import '../../domain/entities/city_map_entity.dart';
import '../../domain/entities/building_entity.dart';
import '../../domain/entities/street_entity.dart';
import '../../domain/entities/obstacle_entity.dart';

class CityMapPainter extends CustomPainter {
  final CityMapEntity cityMap;
  final double cellSize;
  final Set<String> highlightedStreetIds;
  final Set<String> visitedNodeIds;
  final Set<String> currentNodeIds;
  final List<String>? pathNodeIds;
  final String? startNodeId;
  final String? endNodeId;
  final bool showGrid;
  final bool showNodeLabels;

  CityMapPainter({
    required this.cityMap,
    this.cellSize = 20.0,
    this.highlightedStreetIds = const {},
    this.visitedNodeIds = const {},
    this.currentNodeIds = const {},
    this.pathNodeIds,
    this.startNodeId,
    this.endNodeId,
    this.showGrid = true,
    this.showNodeLabels = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid background
    if (showGrid) {
      _drawGrid(canvas, size);
    }

    // Draw streets
    _drawStreets(canvas);

    // Draw path highlighting (if any)
    if (pathNodeIds != null && pathNodeIds!.isNotEmpty) {
      _drawPath(canvas);
    }

    // Draw buildings
    _drawBuildings(canvas);

    // Draw obstacles
    _drawObstacles(canvas);

    // Draw intersections/nodes
    _drawNodes(canvas);

    // Draw start/end markers
    _drawStartEndMarkers(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (int x = 0; x <= cityMap.gridWidth; x++) {
      canvas.drawLine(
        Offset(x * cellSize, 0),
        Offset(x * cellSize, cityMap.gridHeight * cellSize),
        paint,
      );
    }

    // Horizontal lines
    for (int y = 0; y <= cityMap.gridHeight; y++) {
      canvas.drawLine(
        Offset(0, y * cellSize),
        Offset(cityMap.gridWidth * cellSize, y * cellSize),
        paint,
      );
    }
  }

  void _drawStreets(Canvas canvas) {
    for (final street in cityMap.streets) {
      final isHighlighted = highlightedStreetIds.contains(street.id);
      _drawStreet(canvas, street, isHighlighted);
    }
  }

  void _drawStreet(Canvas canvas, StreetEntity street, bool isHighlighted) {
    if (street.path.isEmpty) return;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Street color and width based on type
    Color streetColor;
    double strokeWidth;

    switch (street.type) {
      case StreetType.highway:
        streetColor = const Color(0xFF424242);
        strokeWidth = cellSize * 0.6;
        break;
      case StreetType.road:
        streetColor = const Color(0xFF616161);
        strokeWidth = cellSize * 0.45;
        break;
      case StreetType.alley:
        streetColor = const Color(0xFF9E9E9E);
        strokeWidth = cellSize * 0.3;
        break;
    }

    if (isHighlighted) {
      streetColor = Colors.green.shade400;
    }

    basePaint
      ..color = streetColor
      ..strokeWidth = strokeWidth;

    // Draw street path
    final path = Path();
    path.moveTo(
      street.path.first.x * cellSize + cellSize / 2,
      street.path.first.y * cellSize + cellSize / 2,
    );

    for (int i = 1; i < street.path.length; i++) {
      path.lineTo(
        street.path[i].x * cellSize + cellSize / 2,
        street.path[i].y * cellSize + cellSize / 2,
      );
    }

    canvas.drawPath(path, basePaint);

    // Draw center line for highways
    if (street.type == StreetType.highway) {
      final centerLinePaint = Paint()
        ..color = isHighlighted ? Colors.lightGreen : Colors.yellow.shade600
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, centerLinePaint);
    }
  }

  void _drawPath(Canvas canvas) {
    if (pathNodeIds == null || pathNodeIds!.length < 2) return;

    final pathPaint = Paint()
      ..color = Colors.green.shade400.withValues(alpha: 0.8)
      ..strokeWidth = cellSize * 0.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    bool first = true;

    for (final nodeId in pathNodeIds!) {
      final node = cityMap.graph.getNode(nodeId);
      if (node != null) {
        final x = node.x * cellSize + cellSize / 2;
        final y = node.y * cellSize + cellSize / 2;
        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, pathPaint);

    // Draw path direction arrows
    _drawPathArrows(canvas, pathNodeIds!);
  }

  void _drawPathArrows(Canvas canvas, List<String> pathNodes) {
    if (pathNodes.length < 2) return;

    final arrowPaint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.fill;

    for (int i = 0; i < pathNodes.length - 1; i++) {
      final fromNode = cityMap.graph.getNode(pathNodes[i]);
      final toNode = cityMap.graph.getNode(pathNodes[i + 1]);

      if (fromNode == null || toNode == null) continue;

      final fromX = fromNode.x * cellSize + cellSize / 2;
      final fromY = fromNode.y * cellSize + cellSize / 2;
      final toX = toNode.x * cellSize + cellSize / 2;
      final toY = toNode.y * cellSize + cellSize / 2;

      // Draw arrow at midpoint
      final midX = (fromX + toX) / 2;
      final midY = (fromY + toY) / 2;

      final dx = toX - fromX;
      final dy = toY - fromY;
      final len = (dx * dx + dy * dy);
      if (len == 0) continue;

      final angle = dx.isNaN || dy.isNaN ? 0.0 :
          ((dx >= 0 ? 1.0 : -1.0) * (dy >= 0 ? 1.0 : -1.0) *
          (dx.abs() > dy.abs() ? 0.0 : 3.14159 / 2));

      final arrowSize = cellSize * 0.25;

      canvas.save();
      canvas.translate(midX, midY);
      canvas.rotate(angle);

      final arrowPath = Path()
        ..moveTo(arrowSize, 0)
        ..lineTo(-arrowSize / 2, -arrowSize / 2)
        ..lineTo(-arrowSize / 2, arrowSize / 2)
        ..close();

      canvas.drawPath(arrowPath, arrowPaint);
      canvas.restore();
    }
  }

  void _drawBuildings(Canvas canvas) {
    for (final building in cityMap.buildings) {
      _drawBuilding(canvas, building);
    }
  }

  void _drawBuilding(Canvas canvas, BuildingEntity building) {
    final isStart = cityMap.startBuildingId == building.id;
    final isEnd = cityMap.endBuildingId == building.id;

    final rect = Rect.fromLTWH(
      building.gridX * cellSize + 2,
      building.gridY * cellSize + 2,
      building.width * cellSize - 4,
      building.height * cellSize - 4,
    );

    // Building fill color based on type
    Color fillColor;
    switch (building.type) {
      case BuildingType.house:
        fillColor = Colors.blue.shade300;
        break;
      case BuildingType.office:
        fillColor = Colors.blueGrey.shade400;
        break;
      case BuildingType.hospital:
        fillColor = Colors.red.shade300;
        break;
      case BuildingType.restaurant:
        fillColor = Colors.orange.shade300;
        break;
      case BuildingType.school:
        fillColor = Colors.yellow.shade400;
        break;
    }

    // Highlight if start or end
    if (isStart) {
      fillColor = Colors.green.shade400;
    } else if (isEnd) {
      fillColor = Colors.red.shade400;
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = fillColor.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw building
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, strokePaint);

    // Draw building icon
    if (cellSize >= 15) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: building.type.icon,
          style: TextStyle(fontSize: cellSize * 0.5),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          rect.center.dx - textPainter.width / 2,
          rect.center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawObstacles(Canvas canvas) {
    for (final obstacle in cityMap.obstacles) {
      _drawObstacle(canvas, obstacle);
    }
  }

  void _drawObstacle(Canvas canvas, ObstacleEntity obstacle) {
    final centerX = obstacle.gridX * cellSize + cellSize / 2;
    final centerY = obstacle.gridY * cellSize + cellSize / 2;

    // Draw obstacle background
    final bgPaint = Paint()
      ..color = Colors.red.shade100.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), cellSize * 0.4, bgPaint);

    // Draw obstacle icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: obstacle.type.icon,
        style: TextStyle(fontSize: cellSize * 0.5),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY - textPainter.height / 2,
      ),
    );
  }

  void _drawNodes(Canvas canvas) {
    for (final node in cityMap.graph.nodes) {
      final isVisited = visitedNodeIds.contains(node.id);
      final isCurrent = currentNodeIds.contains(node.id);
      final isStart = node.id == startNodeId;
      final isEnd = node.id == endNodeId;
      final isInPath = pathNodeIds?.contains(node.id) ?? false;

      final centerX = node.x * cellSize + cellSize / 2;
      final centerY = node.y * cellSize + cellSize / 2;

      // Determine node color
      Color nodeColor;
      double radius = cellSize * 0.2;

      if (isStart) {
        nodeColor = Colors.green;
        radius = cellSize * 0.3;
      } else if (isEnd) {
        nodeColor = Colors.red;
        radius = cellSize * 0.3;
      } else if (isCurrent) {
        nodeColor = Colors.purple;
        radius = cellSize * 0.25;
      } else if (isInPath) {
        nodeColor = Colors.green.shade400;
      } else if (isVisited) {
        nodeColor = Colors.blue.shade300;
      } else {
        nodeColor = Colors.grey.shade600;
      }

      // Draw node
      final nodePaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(centerX, centerY), radius, nodePaint);

      // Draw node border
      final borderPaint = Paint()
        ..color = nodeColor.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(centerX, centerY), radius + 1, borderPaint);

      // Draw node label if enabled
      if (showNodeLabels && cellSize >= 20) {
        final label = node.label ?? node.id;
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.white,
              fontSize: cellSize * 0.25,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            centerX - textPainter.width / 2,
            centerY - textPainter.height / 2,
          ),
        );
      }
    }
  }

  void _drawStartEndMarkers(Canvas canvas) {
    // Draw start marker
    if (startNodeId != null) {
      final startNode = cityMap.graph.getNode(startNodeId!);
      if (startNode != null) {
        _drawMarker(
          canvas,
          startNode.x * cellSize + cellSize / 2,
          startNode.y * cellSize + cellSize / 2,
          Colors.green,
          'S',
        );
      }
    }

    // Draw end marker
    if (endNodeId != null) {
      final endNode = cityMap.graph.getNode(endNodeId!);
      if (endNode != null) {
        _drawMarker(
          canvas,
          endNode.x * cellSize + cellSize / 2,
          endNode.y * cellSize + cellSize / 2,
          Colors.red,
          'E',
        );
      }
    }
  }

  void _drawMarker(
    Canvas canvas,
    double x,
    double y,
    Color color,
    String label,
  ) {
    // Draw pin shape
    final pinPath = Path()
      ..moveTo(x, y)
      ..lineTo(x - cellSize * 0.3, y - cellSize * 0.8)
      ..quadraticBezierTo(
        x,
        y - cellSize * 1.2,
        x + cellSize * 0.3,
        y - cellSize * 0.8,
      )
      ..close();

    final pinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(pinPath, pinPaint);

    // Draw circle at top of pin
    canvas.drawCircle(
      Offset(x, y - cellSize * 0.8),
      cellSize * 0.25,
      pinPaint,
    );

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: cellSize * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        x - textPainter.width / 2,
        y - cellSize * 0.8 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CityMapPainter oldDelegate) {
    return cityMap != oldDelegate.cityMap ||
        cellSize != oldDelegate.cellSize ||
        highlightedStreetIds != oldDelegate.highlightedStreetIds ||
        visitedNodeIds != oldDelegate.visitedNodeIds ||
        currentNodeIds != oldDelegate.currentNodeIds ||
        pathNodeIds != oldDelegate.pathNodeIds ||
        startNodeId != oldDelegate.startNodeId ||
        endNodeId != oldDelegate.endNodeId ||
        showGrid != oldDelegate.showGrid ||
        showNodeLabels != oldDelegate.showNodeLabels;
  }
}
