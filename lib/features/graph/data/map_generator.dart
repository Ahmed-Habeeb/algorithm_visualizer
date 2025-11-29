import 'dart:math';

import '../domain/entities/building_entity.dart';
import '../domain/entities/street_entity.dart';
import '../domain/entities/obstacle_entity.dart';
import '../domain/entities/city_map_entity.dart';
import '../domain/entities/graph_entity.dart';
import '../domain/entities/graph_node_entity.dart';
import '../domain/entities/graph_edge_entity.dart';

class MapGenerator {
  final Random _random;

  MapGenerator({int? seed}) : _random = Random(seed);

  /// Generate a city map with the specified dimensions and density
  CityMapEntity generate({
    required int width,
    required int height,
    double buildingDensity = 0.3,
    double streetSpacing = 3,
  }) {
    // Grid to track what's at each position
    final grid = List.generate(
      height,
      (_) => List.generate(width, (_) => _CellType.empty),
    );

    // Generate streets first (grid-based)
    final streets = _generateStreets(grid, width, height, streetSpacing.toInt());

    // Place buildings in empty spaces
    final buildings = _generateBuildings(grid, width, height, buildingDensity);

    // Generate graph from street intersections
    final graph = _generateGraphFromStreets(streets, width, height);

    // Connect buildings to nearest nodes
    final connectedBuildings = _connectBuildingsToNodes(buildings, graph);

    return CityMapEntity(
      gridWidth: width,
      gridHeight: height,
      buildings: connectedBuildings,
      streets: streets,
      obstacles: [],
      graph: graph,
    );
  }

  List<StreetEntity> _generateStreets(
    List<List<_CellType>> grid,
    int width,
    int height,
    int spacing,
  ) {
    final streets = <StreetEntity>[];
    int streetId = 0;

    // Calculate spacing to ensure at least 2 streets in each direction
    final effectiveSpacing = spacing.clamp(2, (min(width, height) ~/ 2) - 1);

    // Generate horizontal streets
    for (int y = effectiveSpacing; y < height - 1; y += effectiveSpacing) {
      final path = <StreetSegment>[];
      for (int x = 0; x < width; x++) {
        path.add(StreetSegment(x, y));
        grid[y][x] = _CellType.street;
      }

      // Determine street type based on position
      final type = _getStreetTypeForPosition(y, height);
      final name = _generateStreetName(type, streetId, true);

      streets.add(StreetEntity(
        id: 'street_h_$streetId',
        path: path,
        type: type,
        name: name,
        isHorizontal: true,
      ));
      streetId++;
    }

    // Generate vertical streets
    for (int x = effectiveSpacing; x < width - 1; x += effectiveSpacing) {
      final path = <StreetSegment>[];
      for (int y = 0; y < height; y++) {
        path.add(StreetSegment(x, y));
        grid[y][x] = _CellType.street;
      }

      final type = _getStreetTypeForPosition(x, width);
      final name = _generateStreetName(type, streetId, false);

      streets.add(StreetEntity(
        id: 'street_v_$streetId',
        path: path,
        type: type,
        name: name,
        isHorizontal: false,
      ));
      streetId++;
    }

    // Add some random diagonal/connecting streets for variety
    _addRandomStreets(grid, streets, width, height, streetId);

    return streets;
  }

  void _addRandomStreets(
    List<List<_CellType>> grid,
    List<StreetEntity> streets,
    int width,
    int height,
    int startId,
  ) {
    final numExtra = _random.nextInt(3) + 1;
    int streetId = startId;

    for (int i = 0; i < numExtra; i++) {
      final isHorizontal = _random.nextBool();
      final path = <StreetSegment>[];

      if (isHorizontal) {
        final y = _random.nextInt(height - 2) + 1;
        final startX = _random.nextInt(width ~/ 2);
        final endX = startX + _random.nextInt(width ~/ 2) + 3;

        for (int x = startX; x < min(endX, width); x++) {
          path.add(StreetSegment(x, y));
          grid[y][x] = _CellType.street;
        }
      } else {
        final x = _random.nextInt(width - 2) + 1;
        final startY = _random.nextInt(height ~/ 2);
        final endY = startY + _random.nextInt(height ~/ 2) + 3;

        for (int y = startY; y < min(endY, height); y++) {
          path.add(StreetSegment(x, y));
          grid[y][x] = _CellType.street;
        }
      }

      if (path.length >= 3) {
        streets.add(StreetEntity(
          id: 'street_r_$streetId',
          path: path,
          type: StreetType.alley,
          name: 'Alley ${streetId + 1}',
          isHorizontal: isHorizontal,
        ));
        streetId++;
      }
    }
  }

  StreetType _getStreetTypeForPosition(int pos, int max) {
    // Main streets in the middle are highways
    final center = max ~/ 2;
    final distFromCenter = (pos - center).abs();

    if (distFromCenter <= max ~/ 6) {
      return StreetType.highway;
    } else if (distFromCenter <= max ~/ 3) {
      return StreetType.road;
    } else {
      return StreetType.alley;
    }
  }

  String _generateStreetName(StreetType type, int id, bool isHorizontal) {
    final streetNames = [
      'Main', 'Oak', 'Maple', 'Cedar', 'Pine', 'Elm',
      'Washington', 'Lincoln', 'Park', 'Lake', 'River', 'Hill',
      'Center', 'Market', 'Church', 'School', 'Mill', 'Spring'
    ];

    final suffix = isHorizontal ? 'Street' : 'Avenue';
    final name = streetNames[id % streetNames.length];

    switch (type) {
      case StreetType.highway:
        return 'Highway ${id + 1}';
      case StreetType.road:
        return '$name $suffix';
      case StreetType.alley:
        return '$name Alley';
    }
  }

  List<BuildingEntity> _generateBuildings(
    List<List<_CellType>> grid,
    int width,
    int height,
    double density,
  ) {
    final buildings = <BuildingEntity>[];
    int buildingId = 0;

    // Try to place buildings in empty cells adjacent to streets
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (grid[y][x] != _CellType.empty) continue;
        if (_random.nextDouble() > density) continue;

        // Check if adjacent to a street
        if (!_isAdjacentToStreet(grid, x, y, width, height)) continue;

        // Determine building size (1x1 to 2x2)
        final size = _random.nextDouble() < 0.7 ? 1 : 2;

        // Check if we can place a building of this size
        if (!_canPlaceBuilding(grid, x, y, size, size, width, height)) continue;

        // Pick building type
        final type = _getRandomBuildingType();
        final name = _generateBuildingName(type, buildingId);

        buildings.add(BuildingEntity(
          id: 'building_$buildingId',
          gridX: x,
          gridY: y,
          width: size,
          height: size,
          type: type,
          name: name,
        ));

        // Mark cells as occupied
        for (int dy = 0; dy < size; dy++) {
          for (int dx = 0; dx < size; dx++) {
            if (y + dy < height && x + dx < width) {
              grid[y + dy][x + dx] = _CellType.building;
            }
          }
        }

        buildingId++;
      }
    }

    return buildings;
  }

  bool _isAdjacentToStreet(
    List<List<_CellType>> grid,
    int x,
    int y,
    int width,
    int height,
  ) {
    final directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1],
    ];

    for (final dir in directions) {
      final nx = x + dir[0];
      final ny = y + dir[1];
      if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
        if (grid[ny][nx] == _CellType.street) return true;
      }
    }
    return false;
  }

  bool _canPlaceBuilding(
    List<List<_CellType>> grid,
    int x,
    int y,
    int w,
    int h,
    int gridWidth,
    int gridHeight,
  ) {
    for (int dy = 0; dy < h; dy++) {
      for (int dx = 0; dx < w; dx++) {
        final nx = x + dx;
        final ny = y + dy;
        if (nx >= gridWidth || ny >= gridHeight) return false;
        if (grid[ny][nx] != _CellType.empty) return false;
      }
    }
    return true;
  }

  BuildingType _getRandomBuildingType() {
    final rand = _random.nextDouble();
    if (rand < 0.4) return BuildingType.house;
    if (rand < 0.6) return BuildingType.office;
    if (rand < 0.75) return BuildingType.restaurant;
    if (rand < 0.9) return BuildingType.school;
    return BuildingType.hospital;
  }

  String _generateBuildingName(BuildingType type, int id) {
    switch (type) {
      case BuildingType.house:
        return 'House ${id + 1}';
      case BuildingType.office:
        final officeNames = ['Tech Hub', 'Business Center', 'Corporate Office', 'Startup Hub'];
        return officeNames[id % officeNames.length];
      case BuildingType.hospital:
        return 'City Hospital';
      case BuildingType.restaurant:
        final restaurantNames = ['The Bistro', 'Cafe Corner', 'Grill House', 'Pizza Palace'];
        return restaurantNames[id % restaurantNames.length];
      case BuildingType.school:
        return 'Public School ${id + 1}';
    }
  }

  GraphEntity _generateGraphFromStreets(
    List<StreetEntity> streets,
    int width,
    int height,
  ) {
    // Find all street cells and their intersections
    final streetCells = <(int, int), Set<String>>{};

    for (final street in streets) {
      for (final segment in street.path) {
        final key = (segment.x, segment.y);
        streetCells[key] ??= {};
        streetCells[key]!.add(street.id);
      }
    }

    // Find intersections (cells where multiple streets meet)
    final intersections = <(int, int), String>{};
    int nodeId = 0;

    for (final entry in streetCells.entries) {
      if (entry.value.length > 1) {
        // This is an intersection
        intersections[entry.key] = 'node_$nodeId';
        nodeId++;
      }
    }

    // Also add endpoints of streets as nodes
    for (final street in streets) {
      if (street.path.isNotEmpty) {
        final first = (street.path.first.x, street.path.first.y);
        final last = (street.path.last.x, street.path.last.y);

        if (!intersections.containsKey(first)) {
          intersections[first] = 'node_$nodeId';
          nodeId++;
        }
        if (!intersections.containsKey(last)) {
          intersections[last] = 'node_$nodeId';
          nodeId++;
        }
      }
    }

    // Create nodes
    final nodes = <GraphNodeEntity>[];
    for (final entry in intersections.entries) {
      nodes.add(GraphNodeEntity(
        id: entry.value,
        x: entry.key.$1.toDouble(),
        y: entry.key.$2.toDouble(),
        label: entry.value.replaceAll('node_', 'N'),
      ));
    }

    // Create edges between adjacent intersections on the same street
    final edges = <GraphEdgeEntity>[];

    for (final street in streets) {
      final nodesOnStreet = <(int, int, String)>[];

      for (final segment in street.path) {
        final key = (segment.x, segment.y);
        if (intersections.containsKey(key)) {
          nodesOnStreet.add((segment.x, segment.y, intersections[key]!));
        }
      }

      // Sort by position along the street
      if (street.isHorizontal) {
        nodesOnStreet.sort((a, b) => a.$1.compareTo(b.$1));
      } else {
        nodesOnStreet.sort((a, b) => a.$2.compareTo(b.$2));
      }

      // Create edges between consecutive nodes
      for (int i = 0; i < nodesOnStreet.length - 1; i++) {
        final from = nodesOnStreet[i];
        final to = nodesOnStreet[i + 1];

        // Calculate distance
        final dx = (to.$1 - from.$1).toDouble();
        final dy = (to.$2 - from.$2).toDouble();
        final distance = sqrt(dx * dx + dy * dy);

        // Apply street type weight
        final weight = street.getWeight(distance);

        edges.add(GraphEdgeEntity(
          from: from.$3,
          to: to.$3,
          weight: weight,
        ));
      }
    }

    return GraphEntity(
      nodes: nodes,
      edges: edges,
      isDirected: false,
      isWeighted: true,
    );
  }

  List<BuildingEntity> _connectBuildingsToNodes(
    List<BuildingEntity> buildings,
    GraphEntity graph,
  ) {
    return buildings.map((building) {
      final centerX = building.gridX + building.width / 2;
      final centerY = building.gridY + building.height / 2;

      String? nearestNodeId;
      double minDistance = double.infinity;

      for (final node in graph.nodes) {
        final dx = node.x - centerX;
        final dy = node.y - centerY;
        final distance = dx * dx + dy * dy;

        if (distance < minDistance) {
          minDistance = distance;
          nearestNodeId = node.id;
        }
      }

      return building.copyWith(connectedNodeId: nearestNodeId);
    }).toList();
  }

  /// Generate a preset city map for specific scenarios
  CityMapEntity generatePreset(CityMapPreset preset) {
    switch (preset) {
      case CityMapPreset.small:
        return generate(width: 15, height: 15, streetSpacing: 4);
      case CityMapPreset.medium:
        return generate(width: 25, height: 25, streetSpacing: 5);
      case CityMapPreset.large:
        return generate(width: 40, height: 40, streetSpacing: 6);
      case CityMapPreset.maze:
        return _generateMazeCity(20, 20);
    }
  }

  CityMapEntity _generateMazeCity(int width, int height) {
    // Create a more maze-like city with fewer straight paths
    final map = generate(
      width: width,
      height: height,
      buildingDensity: 0.4,
      streetSpacing: 3,
    );

    // Add some obstacles to make it more interesting
    final obstacles = <ObstacleEntity>[];
    int obstacleId = 0;

    for (final street in map.streets) {
      if (_random.nextDouble() < 0.1 && street.path.length > 5) {
        final segment = street.path[_random.nextInt(street.path.length)];
        obstacles.add(ObstacleEntity(
          id: 'obstacle_$obstacleId',
          gridX: segment.x,
          gridY: segment.y,
          type: ObstacleType.construction,
          affectedStreetId: street.id,
        ));
        obstacleId++;
      }
    }

    return map.copyWith(obstacles: obstacles);
  }
}

enum _CellType {
  empty,
  street,
  building,
}

enum CityMapPreset {
  small,
  medium,
  large,
  maze,
}
