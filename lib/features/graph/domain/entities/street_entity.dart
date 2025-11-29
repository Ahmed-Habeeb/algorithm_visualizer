enum StreetType {
  highway,
  road,
  alley,
}

extension StreetTypeExtension on StreetType {
  String get displayName {
    switch (this) {
      case StreetType.highway:
        return 'Highway';
      case StreetType.road:
        return 'Road';
      case StreetType.alley:
        return 'Alley';
    }
  }

  /// Speed multiplier for pathfinding weight calculation
  /// Higher = faster travel = lower weight
  double get speedMultiplier {
    switch (this) {
      case StreetType.highway:
        return 2.0;
      case StreetType.road:
        return 1.0;
      case StreetType.alley:
        return 0.5;
    }
  }

  /// Weight multiplier for pathfinding (inverse of speed)
  double get weightMultiplier {
    switch (this) {
      case StreetType.highway:
        return 0.5;
      case StreetType.road:
        return 1.0;
      case StreetType.alley:
        return 2.0;
    }
  }

  /// Visual width in pixels
  double get visualWidth {
    switch (this) {
      case StreetType.highway:
        return 12.0;
      case StreetType.road:
        return 8.0;
      case StreetType.alley:
        return 4.0;
    }
  }
}

class StreetSegment {
  final int x;
  final int y;

  const StreetSegment(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreetSegment &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class StreetEntity {
  final String id;
  final List<StreetSegment> path;
  final StreetType type;
  final String? name;
  final bool isHorizontal;

  const StreetEntity({
    required this.id,
    required this.path,
    required this.type,
    this.name,
    this.isHorizontal = true,
  });

  /// Get the weight for pathfinding based on street type and distance
  double getWeight(double distance) {
    return distance * type.weightMultiplier;
  }

  StreetEntity copyWith({
    String? id,
    List<StreetSegment>? path,
    StreetType? type,
    String? name,
    bool? isHorizontal,
  }) {
    return StreetEntity(
      id: id ?? this.id,
      path: path ?? this.path,
      type: type ?? this.type,
      name: name ?? this.name,
      isHorizontal: isHorizontal ?? this.isHorizontal,
    );
  }
}
