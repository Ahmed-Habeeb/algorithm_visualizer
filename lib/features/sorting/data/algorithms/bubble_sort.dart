import '../../domain/entities/sorting_algorithm_entity.dart';
import '../../domain/entities/visualization_frame_entity.dart';
import '../../domain/interfaces/sorting_algorithm.dart';

class BubbleSort implements SortingAlgorithm {
  static const _algorithmEntity = SortingAlgorithmEntity(
    id: 'bubble_sort',
    name: 'Bubble Sort',
    description:
        'Bubble Sort repeatedly steps through the list, compares adjacent elements, '
        'and swaps them if they are in the wrong order. The pass through the list '
        'is repeated until the list is sorted.',
    timeComplexityBest: 'O(n)',
    timeComplexityAverage: 'O(n²)',
    timeComplexityWorst: 'O(n²)',
    spaceComplexity: 'O(1)',
    pseudocode: [
      'procedure bubbleSort(A: list)',
      '    n := length(A)',
      '    repeat',
      '        swapped := false',
      '        for i := 1 to n-1 do',
      '            if A[i-1] > A[i] then',
      '                swap(A[i-1], A[i])',
      '                swapped := true',
      '            end if',
      '        end for',
      '        n := n - 1',
      '    until not swapped',
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

    // Initial state
    frames.add(VisualizationFrameEntity(
      data: List.from(arr),
      activeIndices: {},
      comparedIndices: {},
      sortedIndices: {},
      operation: 'Initial State',
      explanation: 'Starting with unsorted array of $n elements',
    ));

    for (int i = 0; i < n - 1; i++) {
      bool swapped = false;

      for (int j = 0; j < n - i - 1; j++) {
        // Comparing frame
        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {},
          comparedIndices: {j, j + 1},
          sortedIndices: Set.from(sorted),
          operation: 'Compare',
          explanation:
              'Comparing elements at index $j (${arr[j]}) and ${j + 1} (${arr[j + 1]})',
        ));

        if (arr[j] > arr[j + 1]) {
          // Swap
          final temp = arr[j];
          arr[j] = arr[j + 1];
          arr[j + 1] = temp;
          swapped = true;

          frames.add(VisualizationFrameEntity(
            data: List.from(arr),
            activeIndices: {j, j + 1},
            comparedIndices: {},
            sortedIndices: Set.from(sorted),
            operation: 'Swap',
            explanation:
                'Swapped ${arr[j]} and ${arr[j + 1]} because ${arr[j + 1]} > ${arr[j]}',
          ));
        }
      }

      sorted.add(n - i - 1);

      frames.add(VisualizationFrameEntity(
        data: List.from(arr),
        activeIndices: {},
        comparedIndices: {},
        sortedIndices: Set.from(sorted),
        operation: 'Pass Complete',
        explanation:
            'Pass ${i + 1} complete. Element ${arr[n - i - 1]} is now in its final position.',
      ));

      if (!swapped) {
        // Array is sorted
        break;
      }
    }

    // Final sorted state
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
