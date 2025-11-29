import '../../domain/entities/searching_algorithm_entity.dart';
import '../../domain/entities/search_visualization_frame_entity.dart';

class BinarySearch {
  static const SearchingAlgorithmEntity algorithm = SearchingAlgorithmEntity(
    id: 'binary_search',
    name: 'Binary Search',
    description:
        'Binary Search works on sorted arrays by repeatedly dividing the search '
        'interval in half. It compares the target with the middle element and '
        'eliminates half of the remaining elements each iteration.',
    timeComplexityBest: 'O(1)',
    timeComplexityAverage: 'O(log n)',
    timeComplexityWorst: 'O(log n)',
    spaceComplexity: 'O(1)',
    requiresSorted: true,
    pseudocode: [
      'procedure binarySearch(A, target)',
      '    left := 0',
      '    right := length(A) - 1',
      '    while left <= right do',
      '        mid := left + (right - left) / 2',
      '        if A[mid] == target then',
      '            return mid',
      '        else if A[mid] < target then',
      '            left := mid + 1',
      '        else',
      '            right := mid - 1',
      '        end if',
      '    end while',
      '    return -1  // not found',
      'end procedure',
    ],
  );

  static List<SearchVisualizationFrameEntity> search(List<int> input, int target) {
    final frames = <SearchVisualizationFrameEntity>[];
    final data = List<int>.from(input);
    data.sort(); // Binary search requires sorted array
    final checked = <int>{};

    int left = 0;
    int right = data.length - 1;

    // Initial state
    frames.add(SearchVisualizationFrameEntity(
      data: data,
      leftBound: left,
      rightBound: right,
      checkedIndices: {},
      target: target,
      operation: 'Initial State',
      explanation: 'Starting Binary Search for target $target in sorted array. Search range: [0, ${data.length - 1}]',
    ));

    while (left <= right) {
      int mid = left + (right - left) ~/ 2;

      // Show current search range and mid
      frames.add(SearchVisualizationFrameEntity(
        data: data,
        leftBound: left,
        rightBound: right,
        midIndex: mid,
        checkedIndices: Set.from(checked),
        target: target,
        operation: 'Calculate Mid',
        explanation: 'Search range: [$left, $right]. Middle index: $mid, value: ${data[mid]}',
      ));

      // Compare
      frames.add(SearchVisualizationFrameEntity(
        data: data,
        leftBound: left,
        rightBound: right,
        midIndex: mid,
        currentIndex: mid,
        checkedIndices: Set.from(checked),
        target: target,
        operation: 'Compare',
        explanation: 'Comparing ${data[mid]} with target $target',
      ));

      if (data[mid] == target) {
        // Found!
        frames.add(SearchVisualizationFrameEntity(
          data: data,
          leftBound: left,
          rightBound: right,
          midIndex: mid,
          foundIndex: mid,
          checkedIndices: Set.from(checked),
          target: target,
          operation: 'Found',
          explanation: 'Target $target found at index $mid!',
        ));
        return frames;
      }

      checked.add(mid);

      if (data[mid] < target) {
        // Target is in right half
        frames.add(SearchVisualizationFrameEntity(
          data: data,
          leftBound: left,
          rightBound: right,
          midIndex: mid,
          checkedIndices: Set.from(checked),
          target: target,
          operation: 'Eliminate Left',
          explanation: '${data[mid]} < $target. Eliminating left half. New range: [${mid + 1}, $right]',
        ));
        left = mid + 1;
      } else {
        // Target is in left half
        frames.add(SearchVisualizationFrameEntity(
          data: data,
          leftBound: left,
          rightBound: right,
          midIndex: mid,
          checkedIndices: Set.from(checked),
          target: target,
          operation: 'Eliminate Right',
          explanation: '${data[mid]} > $target. Eliminating right half. New range: [$left, ${mid - 1}]',
        ));
        right = mid - 1;
      }
    }

    // Not found
    frames.add(SearchVisualizationFrameEntity(
      data: data,
      checkedIndices: Set.from(checked),
      target: target,
      operation: 'Not Found',
      explanation: 'Target $target not found in the array. Search space exhausted.',
    ));

    return frames;
  }
}
