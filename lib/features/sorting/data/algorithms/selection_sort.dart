import '../../domain/entities/sorting_algorithm_entity.dart';
import '../../domain/entities/visualization_frame_entity.dart';
import '../../domain/interfaces/sorting_algorithm.dart';

class SelectionSort implements SortingAlgorithm {
  static const _algorithmEntity = SortingAlgorithmEntity(
    id: 'selection_sort',
    name: 'Selection Sort',
    description:
        'Selection Sort divides the array into sorted and unsorted regions. '
        'It repeatedly finds the minimum element from the unsorted region '
        'and moves it to the end of the sorted region.',
    timeComplexityBest: 'O(n²)',
    timeComplexityAverage: 'O(n²)',
    timeComplexityWorst: 'O(n²)',
    spaceComplexity: 'O(1)',
    pseudocode: [
      'procedure selectionSort(A)',
      '    for i := 0 to length(A) - 2 do',
      '        minIndex := i',
      '        for j := i + 1 to length(A) - 1 do',
      '            if A[j] < A[minIndex] then',
      '                minIndex := j',
      '            end if',
      '        end for',
      '        swap(A[i], A[minIndex])',
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
    final sorted = <int>{};

    frames.add(VisualizationFrameEntity(
      data: List.from(arr),
      activeIndices: {},
      comparedIndices: {},
      sortedIndices: {},
      operation: 'Initial State',
      explanation: 'Starting Selection Sort on array of $n elements',
    ));

    for (int i = 0; i < n - 1; i++) {
      int minIndex = i;

      frames.add(VisualizationFrameEntity(
        data: List.from(arr),
        activeIndices: {i},
        comparedIndices: {},
        sortedIndices: Set.from(sorted),
        operation: 'Start Search',
        explanation: 'Finding minimum element from index $i to ${n - 1}',
      ));

      for (int j = i + 1; j < n; j++) {
        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {minIndex},
          comparedIndices: {j},
          sortedIndices: Set.from(sorted),
          operation: 'Compare',
          explanation:
              'Comparing ${arr[j]} with current minimum ${arr[minIndex]}',
        ));

        if (arr[j] < arr[minIndex]) {
          minIndex = j;

          frames.add(VisualizationFrameEntity(
            data: List.from(arr),
            activeIndices: {minIndex},
            comparedIndices: {},
            sortedIndices: Set.from(sorted),
            operation: 'New Minimum',
            explanation: 'Found new minimum: ${arr[minIndex]} at index $minIndex',
          ));
        }
      }

      if (minIndex != i) {
        final temp = arr[i];
        arr[i] = arr[minIndex];
        arr[minIndex] = temp;

        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {i, minIndex},
          comparedIndices: {},
          sortedIndices: Set.from(sorted),
          operation: 'Swap',
          explanation: 'Swapped ${arr[minIndex]} and ${arr[i]}',
        ));
      }

      sorted.add(i);

      frames.add(VisualizationFrameEntity(
        data: List.from(arr),
        activeIndices: {},
        comparedIndices: {},
        sortedIndices: Set.from(sorted),
        operation: 'Element Sorted',
        explanation: '${arr[i]} is now in its final position at index $i',
      ));
    }

    sorted.add(n - 1);

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
