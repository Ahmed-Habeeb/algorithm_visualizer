import 'package:equatable/equatable.dart';

class SearchingAlgorithmEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String timeComplexityBest;
  final String timeComplexityAverage;
  final String timeComplexityWorst;
  final String spaceComplexity;
  final List<String> pseudocode;
  final bool requiresSorted;

  const SearchingAlgorithmEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.timeComplexityBest,
    required this.timeComplexityAverage,
    required this.timeComplexityWorst,
    required this.spaceComplexity,
    required this.pseudocode,
    this.requiresSorted = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        timeComplexityBest,
        timeComplexityAverage,
        timeComplexityWorst,
        spaceComplexity,
        pseudocode,
        requiresSorted,
      ];
}
