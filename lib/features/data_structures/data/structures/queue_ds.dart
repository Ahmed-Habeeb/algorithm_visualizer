import '../../domain/entities/data_structure_entity.dart';
import '../../domain/entities/ds_visualization_frame_entity.dart';
import '../../domain/interfaces/data_structure.dart';

class QueueDS implements DataStructure {
  @override
  DataStructureEntity get info => const DataStructureEntity(
        id: 'queue',
        name: 'Queue',
        description:
            'A Queue is a linear data structure that follows the FIFO (First In First Out) principle. The first element added is the first one to be removed. Think of it like a line at a checkout counter.',
        category: 'linear',
        operations: ['enqueue', 'dequeue', 'front', 'isEmpty'],
        timeComplexities: {
          'enqueue': 'O(1)',
          'dequeue': 'O(1)',
          'front': 'O(1)',
          'search': 'O(n)',
        },
        spaceComplexity: 'O(n)',
        pseudocode: [
          'enqueue(element):',
          '  rear = rear + 1',
          '  queue[rear] = element',
          '',
          'dequeue():',
          '  if isEmpty(): return error',
          '  element = queue[front]',
          '  front = front + 1',
          '  return element',
          '',
          'front():',
          '  if isEmpty(): return error',
          '  return queue[front]',
        ],
      );

  @override
  List<DSVisualizationFrameEntity> insert(List<int> currentData, int value) {
    final frames = <DSVisualizationFrameEntity>[];
    final data = List<int>.from(currentData);

    // Initial state
    frames.add(DSVisualizationFrameEntity(
      operation: 'Enqueue Start',
      explanation: 'Starting enqueue operation. Adding $value to the rear of the queue.',
      arrayData: List.from(data),
      headIndex: data.isEmpty ? null : 0,
      tailIndex: data.isEmpty ? null : data.length - 1,
    ));

    // Add element at rear
    data.add(value);

    frames.add(DSVisualizationFrameEntity(
      operation: 'Enqueue',
      explanation: 'Enqueued $value at the rear. Queue rear is now at index ${data.length - 1}.',
      arrayData: List.from(data),
      headIndex: 0,
      tailIndex: data.length - 1,
      currentIndex: data.length - 1,
    ));

    frames.add(DSVisualizationFrameEntity(
      operation: 'Complete',
      explanation: 'Enqueue operation complete. Queue size is now ${data.length}.',
      arrayData: List.from(data),
      headIndex: 0,
      tailIndex: data.length - 1,
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
        explanation: 'Queue is empty! Cannot dequeue from an empty queue.',
        arrayData: [],
      ));
      return frames;
    }

    // Initial state
    frames.add(DSVisualizationFrameEntity(
      operation: 'Dequeue Start',
      explanation: 'Starting dequeue operation. Will remove element from front.',
      arrayData: List.from(data),
      headIndex: 0,
      tailIndex: data.length - 1,
      currentIndex: 0,
    ));

    final removedValue = data.removeAt(0);

    frames.add(DSVisualizationFrameEntity(
      operation: 'Dequeue',
      explanation: 'Dequeued $removedValue from the front of the queue.',
      arrayData: List.from(data),
      headIndex: data.isEmpty ? null : 0,
      tailIndex: data.isEmpty ? null : data.length - 1,
    ));

    frames.add(DSVisualizationFrameEntity(
      operation: 'Complete',
      explanation: 'Dequeue operation complete. Removed value: $removedValue. Queue size is now ${data.length}.',
      arrayData: List.from(data),
      headIndex: data.isEmpty ? null : 0,
      tailIndex: data.isEmpty ? null : data.length - 1,
    ));

    return frames;
  }

  @override
  List<DSVisualizationFrameEntity> search(List<int> currentData, int value) {
    final frames = <DSVisualizationFrameEntity>[];

    if (currentData.isEmpty) {
      frames.add(const DSVisualizationFrameEntity(
        operation: 'Empty',
        explanation: 'Queue is empty! Nothing to search.',
        arrayData: [],
      ));
      return frames;
    }

    // Search from front to rear
    for (int i = 0; i < currentData.length; i++) {
      frames.add(DSVisualizationFrameEntity(
        operation: 'Search',
        explanation: 'Checking element at position $i: ${currentData[i]}',
        arrayData: currentData,
        headIndex: 0,
        tailIndex: currentData.length - 1,
        currentIndex: i,
      ));

      if (currentData[i] == value) {
        frames.add(DSVisualizationFrameEntity(
          operation: 'Found',
          explanation: 'Found $value at position $i from the front!',
          arrayData: currentData,
          headIndex: 0,
          tailIndex: currentData.length - 1,
          currentIndex: i,
        ));
        return frames;
      }
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Not Found',
      explanation: '$value was not found in the queue.',
      arrayData: currentData,
      headIndex: 0,
      tailIndex: currentData.length - 1,
    ));

    return frames;
  }

  @override
  List<DSVisualizationFrameEntity> visualize(List<int> data) {
    return [
      DSVisualizationFrameEntity(
        operation: 'Display',
        explanation: 'Queue with ${data.length} elements. Front at index 0, Rear at index ${data.isEmpty ? "N/A" : data.length - 1}.',
        arrayData: data,
        headIndex: data.isEmpty ? null : 0,
        tailIndex: data.isEmpty ? null : data.length - 1,
      ),
    ];
  }
}
