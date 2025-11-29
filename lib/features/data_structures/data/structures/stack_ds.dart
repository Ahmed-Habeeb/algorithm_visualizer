import '../../domain/entities/data_structure_entity.dart';
import '../../domain/entities/ds_visualization_frame_entity.dart';
import '../../domain/interfaces/data_structure.dart';

class StackDS implements DataStructure {
  @override
  DataStructureEntity get info => const DataStructureEntity(
        id: 'stack',
        name: 'Stack',
        description:
            'A Stack is a linear data structure that follows the LIFO (Last In First Out) principle. The last element added is the first one to be removed. Think of it like a stack of plates.',
        category: 'linear',
        operations: ['push', 'pop', 'peek', 'isEmpty'],
        timeComplexities: {
          'push': 'O(1)',
          'pop': 'O(1)',
          'peek': 'O(1)',
          'search': 'O(n)',
        },
        spaceComplexity: 'O(n)',
        pseudocode: [
          'push(element):',
          '  top = top + 1',
          '  stack[top] = element',
          '',
          'pop():',
          '  if isEmpty(): return error',
          '  element = stack[top]',
          '  top = top - 1',
          '  return element',
          '',
          'peek():',
          '  if isEmpty(): return error',
          '  return stack[top]',
        ],
      );

  @override
  List<DSVisualizationFrameEntity> insert(List<int> currentData, int value) {
    final frames = <DSVisualizationFrameEntity>[];
    final data = List<int>.from(currentData);

    // Initial state
    frames.add(DSVisualizationFrameEntity(
      operation: 'Push Start',
      explanation: 'Starting push operation. Adding $value to the stack.',
      arrayData: List.from(data),
      topIndex: data.isEmpty ? null : data.length - 1,
    ));

    // Add element
    data.add(value);

    frames.add(DSVisualizationFrameEntity(
      operation: 'Push',
      explanation: 'Pushed $value onto the stack. New top is at index ${data.length - 1}.',
      arrayData: List.from(data),
      topIndex: data.length - 1,
      currentIndex: data.length - 1,
    ));

    frames.add(DSVisualizationFrameEntity(
      operation: 'Complete',
      explanation: 'Push operation complete. Stack size is now ${data.length}.',
      arrayData: List.from(data),
      topIndex: data.length - 1,
    ));

    return frames;
  }

  @override
  List<DSVisualizationFrameEntity> delete(List<int> currentData, int value) {
    final frames = <DSVisualizationFrameEntity>[];
    final data = List<int>.from(currentData);

    if (data.isEmpty) {
      frames.add(const DSVisualizationFrameEntity(
        operation: 'Error',
        explanation: 'Stack is empty! Cannot pop from an empty stack.',
        arrayData: [],
      ));
      return frames;
    }

    // Initial state
    frames.add(DSVisualizationFrameEntity(
      operation: 'Pop Start',
      explanation: 'Starting pop operation. Will remove element from top.',
      arrayData: List.from(data),
      topIndex: data.length - 1,
      currentIndex: data.length - 1,
    ));

    final removedValue = data.removeLast();

    frames.add(DSVisualizationFrameEntity(
      operation: 'Pop',
      explanation: 'Popped $removedValue from the stack.',
      arrayData: List.from(data),
      topIndex: data.isEmpty ? null : data.length - 1,
    ));

    frames.add(DSVisualizationFrameEntity(
      operation: 'Complete',
      explanation: 'Pop operation complete. Removed value: $removedValue. Stack size is now ${data.length}.',
      arrayData: List.from(data),
      topIndex: data.isEmpty ? null : data.length - 1,
    ));

    return frames;
  }

  @override
  List<DSVisualizationFrameEntity> search(List<int> currentData, int value) {
    final frames = <DSVisualizationFrameEntity>[];

    if (currentData.isEmpty) {
      frames.add(const DSVisualizationFrameEntity(
        operation: 'Empty',
        explanation: 'Stack is empty! Nothing to search.',
        arrayData: [],
      ));
      return frames;
    }

    // Search from top to bottom
    for (int i = currentData.length - 1; i >= 0; i--) {
      frames.add(DSVisualizationFrameEntity(
        operation: 'Search',
        explanation: 'Checking element at index $i: ${currentData[i]}',
        arrayData: currentData,
        topIndex: currentData.length - 1,
        currentIndex: i,
      ));

      if (currentData[i] == value) {
        frames.add(DSVisualizationFrameEntity(
          operation: 'Found',
          explanation: 'Found $value at index $i! (${currentData.length - 1 - i} positions from top)',
          arrayData: currentData,
          topIndex: currentData.length - 1,
          currentIndex: i,
        ));
        return frames;
      }
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Not Found',
      explanation: '$value was not found in the stack.',
      arrayData: currentData,
      topIndex: currentData.length - 1,
    ));

    return frames;
  }

  @override
  List<DSVisualizationFrameEntity> visualize(List<int> data) {
    return [
      DSVisualizationFrameEntity(
        operation: 'Display',
        explanation: 'Stack with ${data.length} elements. Top is at index ${data.isEmpty ? "N/A" : data.length - 1}.',
        arrayData: data,
        topIndex: data.isEmpty ? null : data.length - 1,
      ),
    ];
  }
}
