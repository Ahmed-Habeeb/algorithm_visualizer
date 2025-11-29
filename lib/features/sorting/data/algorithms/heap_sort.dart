import '../../domain/entities/sorting_algorithm_entity.dart';
import '../../domain/entities/visualization_frame_entity.dart';
import '../../domain/interfaces/sorting_algorithm.dart';

class HeapSort implements SortingAlgorithm {
  static const _algorithmEntity = SortingAlgorithmEntity(
    id: 'heap_sort',
    name: 'Heap Sort',
    description:
        'Heap Sort uses a binary heap data structure. It first builds a max-heap, '
        'then repeatedly extracts the maximum element and places it at the end.',
    timeComplexityBest: 'O(n log n)',
    timeComplexityAverage: 'O(n log n)',
    timeComplexityWorst: 'O(n log n)',
    spaceComplexity: 'O(1)',
    pseudocode: [
      'procedure heapSort(A)',
      '    buildMaxHeap(A)',
      '    for i := length(A) - 1 down to 1 do',
      '        swap(A[0], A[i])',
      '        heapify(A, 0, i)',
      '    end for',
      'end procedure',
      '',
      'procedure heapify(A, i, n)',
      '    largest := i',
      '    left := 2*i + 1',
      '    right := 2*i + 2',
      '    if left < n and A[left] > A[largest] then',
      '        largest := left',
      '    if right < n and A[right] > A[largest] then',
      '        largest := right',
      '    if largest != i then',
      '        swap(A[i], A[largest])',
      '        heapify(A, largest, n)',
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
      explanation: 'Starting Heap Sort on array of $n elements',
    ));

    void heapify(int heapSize, int i) {
      int largest = i;
      int left = 2 * i + 1;
      int right = 2 * i + 2;

      frames.add(VisualizationFrameEntity(
        data: List.from(arr),
        activeIndices: {i},
        comparedIndices: {if (left < heapSize) left, if (right < heapSize) right},
        sortedIndices: Set.from(sorted),
        operation: 'Heapify',
        explanation: 'Heapifying at index $i (value: ${arr[i]})',
      ));

      if (left < heapSize && arr[left] > arr[largest]) {
        largest = left;
      }

      if (right < heapSize && arr[right] > arr[largest]) {
        largest = right;
      }

      if (largest != i) {
        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {i, largest},
          comparedIndices: {},
          sortedIndices: Set.from(sorted),
          operation: 'Swap',
          explanation: 'Swapping ${arr[i]} with ${arr[largest]}',
        ));

        final temp = arr[i];
        arr[i] = arr[largest];
        arr[largest] = temp;

        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {i, largest},
          comparedIndices: {},
          sortedIndices: Set.from(sorted),
          operation: 'After Swap',
          explanation: 'Swapped. Continuing heapify down.',
        ));

        heapify(heapSize, largest);
      }
    }

    // Build max heap
    frames.add(VisualizationFrameEntity(
      data: List.from(arr),
      activeIndices: {},
      comparedIndices: {},
      sortedIndices: {},
      operation: 'Build Max Heap',
      explanation: 'Building max heap from bottom up',
    ));

    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      heapify(n, i);
    }

    frames.add(VisualizationFrameEntity(
      data: List.from(arr),
      activeIndices: {},
      comparedIndices: {},
      sortedIndices: {},
      operation: 'Max Heap Built',
      explanation: 'Max heap constructed. Maximum element is at root.',
    ));

    // Extract elements from heap one by one
    for (int i = n - 1; i > 0; i--) {
      frames.add(VisualizationFrameEntity(
        data: List.from(arr),
        activeIndices: {0, i},
        comparedIndices: {},
        sortedIndices: Set.from(sorted),
        operation: 'Extract Max',
        explanation: 'Moving max element ${arr[0]} to position $i',
      ));

      final temp = arr[0];
      arr[0] = arr[i];
      arr[i] = temp;

      sorted.add(i);

      frames.add(VisualizationFrameEntity(
        data: List.from(arr),
        activeIndices: {},
        comparedIndices: {},
        sortedIndices: Set.from(sorted),
        operation: 'Element Sorted',
        explanation: '${arr[i]} is now in its final position',
      ));

      heapify(i, 0);
    }

    sorted.add(0);

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
