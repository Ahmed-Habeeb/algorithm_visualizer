import '../../domain/entities/data_structure_entity.dart';
import '../../domain/entities/ds_visualization_frame_entity.dart';
import '../../domain/interfaces/data_structure.dart';

class LinkedListDS implements DataStructure {
  @override
  DataStructureEntity get info => const DataStructureEntity(
        id: 'linked_list',
        name: 'Linked List',
        description:
            'A Linked List is a linear data structure where elements are stored in nodes. Each node contains data and a reference (pointer) to the next node. Unlike arrays, elements are not stored in contiguous memory locations.',
        category: 'linear',
        operations: ['insertHead', 'insertTail', 'delete', 'search'],
        timeComplexities: {
          'insertHead': 'O(1)',
          'insertTail': 'O(n)',
          'delete': 'O(n)',
          'search': 'O(n)',
          'access': 'O(n)',
        },
        spaceComplexity: 'O(n)',
        pseudocode: [
          'insertHead(value):',
          '  newNode = Node(value)',
          '  newNode.next = head',
          '  head = newNode',
          '',
          'insertTail(value):',
          '  newNode = Node(value)',
          '  if head is null:',
          '    head = newNode',
          '  else:',
          '    current = head',
          '    while current.next is not null:',
          '      current = current.next',
          '    current.next = newNode',
          '',
          'delete(value):',
          '  if head.value == value:',
          '    head = head.next',
          '  else:',
          '    current = head',
          '    while current.next.value != value:',
          '      current = current.next',
          '    current.next = current.next.next',
        ],
      );

  @override
  List<DSVisualizationFrameEntity> insert(List<int> currentData, int value) {
    final frames = <DSVisualizationFrameEntity>[];
    final data = List<int>.from(currentData);

    // Insert at tail (more visual)
    frames.add(DSVisualizationFrameEntity(
      operation: 'Insert Start',
      explanation: 'Creating new node with value $value.',
      nodes: _createNodes(data),
      edges: _createEdges(data.length),
    ));

    if (data.isEmpty) {
      data.add(value);
      frames.add(DSVisualizationFrameEntity(
        operation: 'Insert Head',
        explanation: 'List was empty. $value becomes the head.',
        nodes: _createNodes(data, highlightIndex: 0),
        edges: _createEdges(data.length),
      ));
    } else {
      // Traverse to end
      for (int i = 0; i < data.length; i++) {
        frames.add(DSVisualizationFrameEntity(
          operation: 'Traverse',
          explanation: 'Traversing to find the tail. Current node: ${data[i]}',
          nodes: _createNodes(data, currentIndex: i),
          edges: _createEdges(data.length),
        ));
      }

      data.add(value);
      frames.add(DSVisualizationFrameEntity(
        operation: 'Insert Tail',
        explanation: 'Inserting $value at the tail of the list.',
        nodes: _createNodes(data, highlightIndex: data.length - 1),
        edges: _createEdges(data.length),
      ));
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Complete',
      explanation: 'Insert complete. List now has ${data.length} nodes.',
      nodes: _createNodes(data),
      edges: _createEdges(data.length),
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
        explanation: 'List is empty! Nothing to delete.',
        nodes: [],
        edges: [],
      ));
      return frames;
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Delete Start',
      explanation: 'Searching for node with value $value to delete.',
      nodes: _createNodes(data),
      edges: _createEdges(data.length),
    ));

    int? foundIndex;
    for (int i = 0; i < data.length; i++) {
      frames.add(DSVisualizationFrameEntity(
        operation: 'Search',
        explanation: 'Checking node ${data[i]} at position $i',
        nodes: _createNodes(data, currentIndex: i),
        edges: _createEdges(data.length),
      ));

      if (data[i] == value) {
        foundIndex = i;
        break;
      }
    }

    if (foundIndex != null) {
      frames.add(DSVisualizationFrameEntity(
        operation: 'Found',
        explanation: 'Found $value at position $foundIndex. Removing it.',
        nodes: _createNodes(data, highlightIndex: foundIndex),
        edges: _createEdges(data.length),
      ));

      data.removeAt(foundIndex);

      frames.add(DSVisualizationFrameEntity(
        operation: 'Complete',
        explanation: 'Deleted $value. Updated pointers. List now has ${data.length} nodes.',
        nodes: _createNodes(data),
        edges: _createEdges(data.length),
      ));
    } else {
      frames.add(DSVisualizationFrameEntity(
        operation: 'Not Found',
        explanation: '$value was not found in the list.',
        nodes: _createNodes(data),
        edges: _createEdges(data.length),
      ));
    }

    return frames;
  }

  @override
  List<DSVisualizationFrameEntity> search(List<int> currentData, int value) {
    final frames = <DSVisualizationFrameEntity>[];

    if (currentData.isEmpty) {
      frames.add(const DSVisualizationFrameEntity(
        operation: 'Empty',
        explanation: 'List is empty! Nothing to search.',
        nodes: [],
        edges: [],
      ));
      return frames;
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Search Start',
      explanation: 'Searching for $value starting from head.',
      nodes: _createNodes(currentData),
      edges: _createEdges(currentData.length),
    ));

    for (int i = 0; i < currentData.length; i++) {
      frames.add(DSVisualizationFrameEntity(
        operation: 'Compare',
        explanation: 'Comparing ${currentData[i]} with $value at position $i',
        nodes: _createNodes(currentData, currentIndex: i),
        edges: _createEdges(currentData.length),
      ));

      if (currentData[i] == value) {
        frames.add(DSVisualizationFrameEntity(
          operation: 'Found',
          explanation: 'Found $value at position $i!',
          nodes: _createNodes(currentData, highlightIndex: i),
          edges: _createEdges(currentData.length),
        ));
        return frames;
      }
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Not Found',
      explanation: '$value was not found in the list.',
      nodes: _createNodes(currentData),
      edges: _createEdges(currentData.length),
    ));

    return frames;
  }

  @override
  List<DSVisualizationFrameEntity> visualize(List<int> data) {
    return [
      DSVisualizationFrameEntity(
        operation: 'Display',
        explanation: 'Linked List with ${data.length} nodes.',
        nodes: _createNodes(data),
        edges: _createEdges(data.length),
      ),
    ];
  }

  List<DSNodeData> _createNodes(List<int> data, {int? currentIndex, int? highlightIndex}) {
    final nodes = <DSNodeData>[];
    const spacing = 0.15;
    const startX = 0.1;

    for (int i = 0; i < data.length; i++) {
      DSNodeState state = DSNodeState.normal;
      if (i == highlightIndex) {
        state = DSNodeState.highlighted;
      } else if (i == currentIndex) {
        state = DSNodeState.current;
      }

      nodes.add(DSNodeData(
        id: 'node_$i',
        value: data[i],
        x: startX + (i * spacing),
        y: 0.5,
        state: state,
        label: i == 0 ? 'Head' : (i == data.length - 1 ? 'Tail' : null),
      ));
    }

    return nodes;
  }

  List<DSEdgeData> _createEdges(int length) {
    final edges = <DSEdgeData>[];

    for (int i = 0; i < length - 1; i++) {
      edges.add(DSEdgeData(
        fromId: 'node_$i',
        toId: 'node_${i + 1}',
      ));
    }

    return edges;
  }
}
