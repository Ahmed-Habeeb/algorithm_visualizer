import 'building_entity.dart';
import 'street_entity.dart';
import 'obstacle_entity.dart';
import 'graph_entity.dart';

class CityMapEntity {
  final int gridWidth;
  final int gridHeight;
  final List<BuildingEntity> buildings;
  final List<StreetEntity> streets;
  final List<ObstacleEntity> obstacles;
  final GraphEntity graph;
  final String? startNodeId;
  final String? endNodeId;
  final String? startBuildingId;
  final String? endBuildingId;

  const CityMapEntity({
    required this.gridWidth,
    required this.gridHeight,
    required this.buildings,
    required this.streets,
    required this.obstacles,
    required this.graph,
    this.startNodeId,
    this.endNodeId,
    this.startBuildingId,
    this.endBuildingId,
  });

  /// Find a building at a given grid position
  BuildingEntity? getBuildingAt(int x, int y) {
    try {
      return buildings.firstWhere((b) =>
          x >= b.gridX &&
          x < b.gridX + b.width &&
          y >= b.gridY &&
          y < b.gridY + b.height);
    } catch (_) {
      return null;
    }
  }

  /// Find a street at a given grid position
  StreetEntity? getStreetAt(int x, int y) {
    try {
      return streets.firstWhere(
          (s) => s.path.any((segment) => segment.x == x && segment.y == y));
    } catch (_) {
      return null;
    }
  }

  /// Check if there's an obstacle at a given position
  ObstacleEntity? getObstacleAt(int x, int y) {
    try {
      return obstacles.firstWhere((o) => o.gridX == x && o.gridY == y);
    } catch (_) {
      return null;
    }
  }

  /// Check if a grid cell is passable (has a street and no obstacle)
  bool isPassable(int x, int y) {
    final hasStreet = getStreetAt(x, y) != null;
    final hasObstacle = getObstacleAt(x, y) != null;
    return hasStreet && !hasObstacle;
  }

  /// Get all intersections (nodes) as grid coordinates
  List<(int, int)> get intersections {
    final Set<(int, int)> intersectionSet = {};

    for (final node in graph.nodes) {
      intersectionSet.add((node.x.toInt(), node.y.toInt()));
    }

    return intersectionSet.toList();
  }

  /// Find the nearest intersection/node to a building
  String? findNearestNode(BuildingEntity building) {
    final buildingCenterX = building.gridX + building.width / 2;
    final buildingCenterY = building.gridY + building.height / 2;

    String? nearestNodeId;
    double minDistance = double.infinity;

    for (final node in graph.nodes) {
      final dx = node.x - buildingCenterX;
      final dy = node.y - buildingCenterY;
      final distance = dx * dx + dy * dy;

      if (distance < minDistance) {
        minDistance = distance;
        nearestNodeId = node.id;
      }
    }

    return nearestNodeId;
  }

  CityMapEntity copyWith({
    int? gridWidth,
    int? gridHeight,
    List<BuildingEntity>? buildings,
    List<StreetEntity>? streets,
    List<ObstacleEntity>? obstacles,
    GraphEntity? graph,
    String? startNodeId,
    String? endNodeId,
    String? startBuildingId,
    String? endBuildingId,
  }) {
    return CityMapEntity(
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      buildings: buildings ?? this.buildings,
      streets: streets ?? this.streets,
      obstacles: obstacles ?? this.obstacles,
      graph: graph ?? this.graph,
      startNodeId: startNodeId ?? this.startNodeId,
      endNodeId: endNodeId ?? this.endNodeId,
      startBuildingId: startBuildingId ?? this.startBuildingId,
      endBuildingId: endBuildingId ?? this.endBuildingId,
    );
  }
}
