enum ObstacleType {
  roadblock,
  construction,
  closedRoad,
}

extension ObstacleTypeExtension on ObstacleType {
  String get displayName {
    switch (this) {
      case ObstacleType.roadblock:
        return 'Roadblock';
      case ObstacleType.construction:
        return 'Construction';
      case ObstacleType.closedRoad:
        return 'Closed Road';
    }
  }

  String get icon {
    switch (this) {
      case ObstacleType.roadblock:
        return '🚧';
      case ObstacleType.construction:
        return '🏗️';
      case ObstacleType.closedRoad:
        return '⛔';
    }
  }
}

class ObstacleEntity {
  final String id;
  final int gridX;
  final int gridY;
  final ObstacleType type;
  final bool isTemporary;
  final String? affectedStreetId;

  const ObstacleEntity({
    required this.id,
    required this.gridX,
    required this.gridY,
    required this.type,
    this.isTemporary = true,
    this.affectedStreetId,
  });

  ObstacleEntity copyWith({
    String? id,
    int? gridX,
    int? gridY,
    ObstacleType? type,
    bool? isTemporary,
    String? affectedStreetId,
  }) {
    return ObstacleEntity(
      id: id ?? this.id,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      type: type ?? this.type,
      isTemporary: isTemporary ?? this.isTemporary,
      affectedStreetId: affectedStreetId ?? this.affectedStreetId,
    );
  }
}
