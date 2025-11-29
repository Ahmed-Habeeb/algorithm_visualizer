import '../../domain/entities/sorting_algorithm_entity.dart';
import '../../domain/entities/visualization_frame_entity.dart';
import '../../domain/interfaces/sorting_algorithm.dart';

class InsertionSort implements SortingAlgorithm {
  static const _algorithmEntity = SortingAlgorithmEntity(
    id: 'insertion_sort',
    name: 'Insertion Sort',
    description:
        'Insertion Sort builds the sorted array one element at a time by repeatedly '
        'picking the next element and inserting it into its correct position.',
    timeComplexityBest: 'O(n)',
    timeComplexityAverage: 'O(n²)',
    timeComplexityWorst: 'O(n²)',
    spaceComplexity: 'O(1)',
    pseudocode: [
      'procedure insertionSort(A)',
      '    for i := 1 to length(A) - 1 do',
      '        key := A[i]',
      '        j := i - 1',
      '        while j >= 0 and A[j] > key do',
      '            A[j + 1] := A[j]',
      '            j := j - 1',
      '        end while',
      '        A[j + 1] := key',
      '    end for',
      'end procedure',
    ],
  );

  @override
  SortingAlgorithmEntity get algorithm => _algorithmEntity;

  @override
  List<VisualizationFrameEntity> sort(List<int> input) {
    final frames = <VisualizationFrameEntity>[];
    final arr = List<int>.from(input);
    final n = arr.length;
    final sorted = <int>{0}; // First element is always "sorted"

    frames.add(VisualizationFrameEntity(
      data: List.from(arr),
      activeIndices: {},
      comparedIndices: {},
      sortedIndices: {0},
      operation: 'Initial State',
      explanation: 'Starting Insertion Sort. First element is considered sorted.',
    ));

    for (int i = 1; i < n; i++) {
      int key = arr[i];
      int j = i - 1;

      frames.add(VisualizationFrameEntity(
        data: List.from(arr),
        activeIndices: {i},
        comparedIndices: {},
        sortedIndices: Set.from(sorted),
        operation: 'Select Key',
        explanation: 'Selected key: $key at index $i to insert into sorted portion',
      ));

      while (j >= 0 && arr[j] > key) {
        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {i},
          comparedIndices: {j, j + 1},
          sortedIndices: Set.from(sorted),
          operation: 'Compare',
          explanation: '${arr[j]} > $key, shifting ${arr[j]} to the right',
        ));

        arr[j + 1] = arr[j];

        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {j, j + 1},
          comparedIndices: {},
          sortedIndices: Set.from(sorted),
          operation: 'Shift',
          explanation: 'Shifted ${arr[j]} from index $j to ${j + 1}',
        ));

        j--;
      }

      arr[j + 1] = key;
      sorted.add(i);

      frames.add(VisualizationFrameEntity(
        data: List.from(arr),
        activeIndices: {j + 1},
        comparedIndices: {},
        sortedIndices: Set.from(sorted),
        operation: 'Insert',
        explanation: 'Inserted $key at position ${j + 1}',
      ));
    }

    frames.add(VisualizationFrameEntity(
      data: List.from(arr),
      activeIndices: {},
      comparedIndices: {},
      sortedIndices: Set.from(List.generate(n, (i) => i)),
      operation: 'Complete',
      explanation: 'Array is now fully sorted!',
    ));

    return frames;
  }
}
