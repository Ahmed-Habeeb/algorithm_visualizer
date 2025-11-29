enum BuildingType {
  house,
  office,
  hospital,
  restaurant,
  school,
}

extension BuildingTypeExtension on BuildingType {
  String get displayName {
    switch (this) {
      case BuildingType.house:
        return 'House';
      case BuildingType.office:
        return 'Office';
      case BuildingType.hospital:
        return 'Hospital';
      case BuildingType.restaurant:
        return 'Restaurant';
      case BuildingType.school:
        return 'School';
    }
  }

  String get icon {
    switch (this) {
      case BuildingType.house:
        return '🏠';
      case BuildingType.office:
        return '🏢';
      case BuildingType.hospital:
        return '🏥';
      case BuildingType.restaurant:
        return '🍽️';
      case BuildingType.school:
        return '🏫';
    }
  }
}

class BuildingEntity {
  final String id;
  final int gridX;
  final int gridY;
  final int width;
  final int height;
  final BuildingType type;
  final String name;
  final String? connectedNodeId;

  const BuildingEntity({
    required this.id,
    required this.gridX,
    required this.gridY,
    this.width = 1,
    this.height = 1,
    required this.type,
    required this.name,
    this.connectedNodeId,
  });

  BuildingEntity copyWith({
    String? id,
    int? gridX,
    int? gridY,
    int? width,
    int? height,
    BuildingType? type,
    String? name,
    String? connectedNodeId,
  }) {
    return BuildingEntity(
      id: id ?? this.id,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      width: width ?? this.width,
      height: height ?? this.height,
      type: type ?? this.type,
      name: name ?? this.name,
      connectedNodeId: connectedNodeId ?? this.connectedNodeId,
    );
  }
}
