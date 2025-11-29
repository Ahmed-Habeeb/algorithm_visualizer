import '../entities/sorting_algorithm_entity.dart';
import '../entities/visualization_frame_entity.dart';

/// Abstract interface for all sorting algorithms
abstract class SortingAlgorithm {
  /// The algorithm metadata (name, description, complexity, etc.)
  SortingAlgorithmEntity get algorithm;

  /// Execute the sorting algorithm and generate visualization frames
  List<VisualizationFrameEntity> sort(List<int> input);
}
