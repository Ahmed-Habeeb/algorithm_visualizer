import '../../domain/entities/searching_algorithm_entity.dart';
import '../../domain/entities/search_visualization_frame_entity.dart';

class LinearSearch {
  static const SearchingAlgorithmEntity algorithm = SearchingAlgorithmEntity(
    id: 'linear_search',
    name: 'Linear Search',
    description:
        'Linear Search sequentially checks each element of the list until a match '
        'is found or the whole list has been searched. It works on both sorted '
        'and unsorted arrays.',
    timeComplexityBest: 'O(1)',
    timeComplexityAverage: 'O(n)',
    timeComplexityWorst: 'O(n)',
    spaceComplexity: 'O(1)',
    requiresSorted: false,
    pseudocode: [
      'procedure linearSearch(A, target)',
      '    for i := 0 to length(A) - 1 do',
      '        if A[i] == target then',
      '            return i',
      '        end if',
      '    end for',
      '    return -1  // not found',
      'end procedure',
    ],
  );

  static List<SearchVisualizationFrameEntity> search(List<int> input, int target) {
    final frames = <SearchVisualizationFrameEntity>[];
    final data = List<int>.from(input);
    final checked = <int>{};

    // Initial state
    frames.add(SearchVisualizationFrameEntity(
      data: data,
      checkedIndices: {},
      target: target,
      operation: 'Initial State',
      explanation: 'Starting Linear Search for target value $target in array of ${data.length} elements',
    ));

    for (int i = 0; i < data.length; i++) {
      // Checking current element
      frames.add(SearchVisualizationFrameEntity(
        data: data,
        currentIndex: i,
        checkedIndices: Set.from(checked),
        target: target,
        operation: 'Check',
        explanation: 'Checking element at index $i: ${data[i]} == $target?',
      ));

      if (data[i] == target) {
        // Found!
        frames.add(SearchVisualizationFrameEntity(
          data: data,
          currentIndex: i,
          checkedIndices: Set.from(checked),
          foundIndex: i,
          target: target,
          operation: 'Found',
          explanation: 'Target $target found at index $i!',
        ));
        return frames;
      }

      checked.add(i);

      // Not found at this index
      frames.add(SearchVisualizationFrameEntity(
        data: data,
        currentIndex: i,
        checkedIndices: Set.from(checked),
        target: target,
        operation: 'Not Match',
        explanation: '${data[i]} != $target. Moving to next element.',
      ));
    }

    // Not found in array
    frames.add(SearchVisualizationFrameEntity(
      data: data,
      checkedIndices: Set.from(checked),
      target: target,
      operation: 'Not Found',
      explanation: 'Target $target not found in the array after checking all ${data.length} elements.',
    ));

    return frames;
  }
}
