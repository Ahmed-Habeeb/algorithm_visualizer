import '../../domain/entities/sorting_algorithm_entity.dart';
import '../../domain/entities/visualization_frame_entity.dart';
import '../../domain/interfaces/sorting_algorithm.dart';

class MergeSort implements SortingAlgorithm {
  static const _algorithmEntity = SortingAlgorithmEntity(
    id: 'merge_sort',
    name: 'Merge Sort',
    description:
        'Merge Sort is a divide-and-conquer algorithm that divides the array into '
        'two halves, recursively sorts them, and then merges the sorted halves.',
    timeComplexityBest: 'O(n log n)',
    timeComplexityAverage: 'O(n log n)',
    timeComplexityWorst: 'O(n log n)',
    spaceComplexity: 'O(n)',
    pseudocode: [
      'procedure mergeSort(A, left, right)',
      '    if left < right then',
      '        mid := (left + right) / 2',
      '        mergeSort(A, left, mid)',
      '        mergeSort(A, mid + 1, right)',
      '        merge(A, left, mid, right)',
      '    end if',
      'end procedure',
      '',
      'procedure merge(A, left, mid, right)',
      '    create temp arrays L and R',
      '    copy A[left..mid] to L',
      '    copy A[mid+1..right] to R',
      '    merge L and R back into A',
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
      explanation: 'Starting Merge Sort on array of $n elements',
    ));

    void merge(int left, int mid, int right) {
      final leftArr = arr.sublist(left, mid + 1);
      final rightArr = arr.sublist(mid + 1, right + 1);

      frames.add(VisualizationFrameEntity(
        data: List.from(arr),
        activeIndices: Set.from(List.generate(right - left + 1, (i) => left + i)),
        comparedIndices: {},
        sortedIndices: Set.from(sorted),
        operation: 'Merge',
        explanation: 'Merging subarrays [$left..$mid] and [${mid + 1}..$right]',
      ));

      int i = 0, j = 0, k = left;

      while (i < leftArr.length && j < rightArr.length) {
        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {k},
          comparedIndices: {left + i, mid + 1 + j},
          sortedIndices: Set.from(sorted),
          operation: 'Compare',
          explanation: 'Comparing ${leftArr[i]} and ${rightArr[j]}',
        ));

        if (leftArr[i] <= rightArr[j]) {
          arr[k] = leftArr[i];
          i++;
        } else {
          arr[k] = rightArr[j];
          j++;
        }
        k++;

        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {k - 1},
          comparedIndices: {},
          sortedIndices: Set.from(sorted),
          operation: 'Place',
          explanation: 'Placed ${arr[k - 1]} at position ${k - 1}',
        ));
      }

      while (i < leftArr.length) {
        arr[k] = leftArr[i];
        i++;
        k++;
      }

      while (j < rightArr.length) {
        arr[k] = rightArr[j];
        j++;
        k++;
      }

      frames.add(VisualizationFrameEntity(
        data: List.from(arr),
        activeIndices: Set.from(List.generate(right - left + 1, (i) => left + i)),
        comparedIndices: {},
        sortedIndices: Set.from(sorted),
        operation: 'Merge Complete',
        explanation: 'Merged subarray [$left..$right]',
      ));
    }

    void mergeSort(int left, int right) {
      if (left < right) {
        int mid = left + (right - left) ~/ 2;

        frames.add(VisualizationFrameEntity(
          data: List.from(arr),
          activeIndices: {mid},
          comparedIndices: Set.from(List.generate(right - left + 1, (i) => left + i)),
          sortedIndices: Set.from(sorted),
          operation: 'Divide',
          explanation: 'Dividing array at mid=$mid into [$left..$mid] and [${mid + 1}..$right]',
        ));

        mergeSort(left, mid);
        mergeSort(mid + 1, right);
        merge(left, mid, right);
      }
    }

    mergeSort(0, n - 1);

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
