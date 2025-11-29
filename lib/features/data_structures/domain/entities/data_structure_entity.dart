class DataStructureEntity {
  final String id;
  final String name;
  final String description;
  final String category; // 'linear' or 'non_linear'
  final List<String> operations;
  final Map<String, String> timeComplexities;
  final String spaceComplexity;
  final List<String> pseudocode;

  const DataStructureEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.operations,
    required this.timeComplexities,
    required this.spaceComplexity,
    required this.pseudocode,
  });
}
