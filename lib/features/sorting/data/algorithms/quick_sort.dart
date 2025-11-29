import '../../domain/entities/sorting_algorithm_entity.dart';
import '../../domain/entities/visualization_frame_entity.dart';
import '../../domain/interfaces/sorting_algorithm.dart';

class QuickSort implements SortingAlgorithm {
  static const _algorithmEntity = SortingAlgorithmEntity(
    id: 'quick_sort',
    name: 'Quick Sort',
    description:
        'Quick Sort is a divide-and-conquer algorithm that selects a pivot element '
        'and partitions the array around it. Elements smaller than the pivot go to '
        'the left, and elements larger go to the right.',
    timeComplexityBest: 'O(n log n)',
    timeComplexityAverage: 'O(n log n)',
    timeComplexityWorst: 'O(n²)',
    spaceComplexity: 'O(log n)',
    pseudocode: [
      'procedure quickSort(A, low, high)',
      '    if low < high then',
      '        pi := partition(A, low, high)',
      '        quickSort(A, low, pi - 1)',
      '        quickSort(A, pi + 1, high)',
      '    end if',
      'end procedure',
      '',
      'procedure partition(A, low, high)',
      '    pivot := A[high]',
      '    i := low - 1',
      '    for j := low to high - 1 do',
      '        if A[j] < pivot then',
      '            i := i + 1',
      '            swap(A[i], A[j])',
      '        end if',
      '    end for',
      '    swap(A[i + 1], A[high])',
      '    return i + 1',
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
      explanation: 'Starting Quick Sort on array of $n elements',
    ));

    void quickSort(int low, int high) {
      if (low < high) {
        // Partition
        int pivotIndex = high;
        int pivotValue = arr[pivotIndex];

        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {pivotIndex},
          comparedIndices: {},
          sortedIndices: Set.from(sorted),
          operation: 'Select Pivot',
          explanation: 'Selected pivot: $pivotValue at index $pivotIndex',
          metadata: {'pivotIndex': pivotIndex, 'low': low, 'high': high},
        ));

        int i = low - 1;

        for (int j = low; j < high; j++) {
          frames.add(VisualizationFrameEntity(
            data: List.from(arr),
            activeIndices: {pivotIndex},
            comparedIndices: {j},
            sortedIndices: Set.from(sorted),
            operation: 'Compare',
            explanation: 'Comparing ${arr[j]} with pivot $pivotValue',
          ));

          if (arr[j] < pivotValue) {
            i++;
            if (i != j) {
              final temp = arr[i];
              arr[i] = arr[j];
              arr[j] = temp;

              frames.add(VisualizationFrameEntity(
                data: List.from(arr),
                activeIndices: {i, j, pivotIndex},
                comparedIndices: {},
                sortedIndices: Set.from(sorted),
                operation: 'Swap',
                explanation: 'Swapped ${arr[j]} and ${arr[i]}',
              ));
            }
          }
        }

        // Place pivot in correct position
        final temp = arr[i + 1];
        arr[i + 1] = arr[high];
        arr[high] = temp;

        final newPivotIndex = i + 1;
        sorted.add(newPivotIndex);

        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {newPivotIndex},
          comparedIndices: {},
          sortedIndices: Set.from(sorted),
          operation: 'Pivot Placed',
          explanation:
              'Pivot $pivotValue placed at correct position $newPivotIndex',
        ));

        // Recursively sort left and right
        quickSort(low, newPivotIndex - 1);
        quickSort(newPivotIndex + 1, high);
      } else if (low == high && low >= 0 && low < n) {
        sorted.add(low);
      }
    }

    quickSort(0, n - 1);

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
