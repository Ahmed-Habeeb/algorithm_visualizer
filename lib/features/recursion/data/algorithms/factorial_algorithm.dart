import '../../domain/entities/recursion_tree_node_entity.dart';
import '../../domain/entities/recursion_frame_entity.dart';
import '../../domain/interfaces/recursion_algorithm.dart';

class FactorialAlgorithm implements RecursionAlgorithm {
  @override
  String get name => 'Factorial';

  @override
  String get description => 'Calculate n! recursively: n! = n × (n-1)!';

  int _nodeIdCounter = 0;

  String _generateNodeId() {
    return 'fact_${_nodeIdCounter++}';
  }

  @override
  RecursionTreeNodeEntity buildTree(int input) {
    _nodeIdCounter = 0;
    return _buildFactorialTree(input, 0, null);
  }

  RecursionTreeNodeEntity _buildFactorialTree(int n, int depth, String? parentId) {
    final nodeId = _generateNodeId();

    if (n <= 1) {
      return RecursionTreeNodeEntity(
        id: nodeId,
        label: '$n!',
        argument: '$n',
        returnValue: '1',
        depth: depth,
        parentId: parentId,
      );
    }

    final child = _buildFactorialTree(n - 1, depth + 1, nodeId);

    return RecursionTreeNodeEntity(
      id: nodeId,
      label: '$n!',
      argument: '$n',
      depth: depth,
      children: [child],
      parentId: parentId,
    );
  }

  @override
  List<RecursionFrameEntity> generateFrames(RecursionTreeNodeEntity tree) {
    final frames = <RecursionFrameEntity>[];
    final nodeStates = <String, RecursionNodeState>{};
    final returnValues = <String, String>{};
    final callStack = <String>[];

    // Initialize all nodes as pending
    _initNodeStates(tree, nodeStates);

    // Add initial frame
    frames.add(RecursionFrameEntity(
      nodeStates: Map.from(nodeStates),
      callStack: List.from(callStack),
      operation: 'Start',
      explanation: 'Starting Factorial calculation for ${tree.label}',
      returnValues: Map.from(returnValues),
    ));

    // Generate frames using DFS traversal
    _generateDfsFrames(tree, frames, nodeStates, returnValues, callStack);

    // Add final frame
    frames.add(RecursionFrameEntity(
      nodeStates: Map.from(nodeStates),
      callStack: [],
      operation: 'Complete',
      explanation: 'Factorial calculation complete! ${tree.label} = ${returnValues[tree.id]}',
      returnValues: Map.from(returnValues),
    ));

    return frames;
  }

  void _initNodeStates(
    RecursionTreeNodeEntity node,
    Map<String, RecursionNodeState> states,
  ) {
    states[node.id] = RecursionNodeState.pending;
    for (final child in node.children) {
      _initNodeStates(child, states);
    }
  }

  void _generateDfsFrames(
    RecursionTreeNodeEntity node,
    List<RecursionFrameEntity> frames,
    Map<String, RecursionNodeState> nodeStates,
    Map<String, String> returnValues,
    List<String> callStack,
  ) {
    final n = int.parse(node.argument!);

    // Push to call stack and mark as active
    callStack.add(node.label);
    nodeStates[node.id] = RecursionNodeState.active;

    frames.add(RecursionFrameEntity(
      nodeStates: Map.from(nodeStates),
      activeNodeId: node.id,
      callStack: List.from(callStack),
      operation: 'Call ${node.label}',
      explanation: 'Entering recursive call for ${node.label}',
      returnValues: Map.from(returnValues),
    ));

    if (node.children.isEmpty) {
      // Base case (0! or 1!)
      nodeStates[node.id] = RecursionNodeState.computing;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Base case',
        explanation: '${node.label} is a base case ($n! = 1). Returning 1',
        returnValues: Map.from(returnValues),
      ));

      returnValues[node.id] = '1';
      nodeStates[node.id] = RecursionNodeState.completed;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Return 1',
        explanation: '${node.label} returns 1',
        returnValues: Map.from(returnValues),
      ));
    } else {
      // Recursive case
      nodeStates[node.id] = RecursionNodeState.computing;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Compute ${node.label}',
        explanation: '${node.label} = $n × ${n - 1}! Need to calculate ${n - 1}! first',
        returnValues: Map.from(returnValues),
      ));

      // Process child
      _generateDfsFrames(
        node.children[0],
        frames,
        nodeStates,
        returnValues,
        callStack,
      );

      // Calculate result
      final childValue = int.parse(returnValues[node.children[0].id]!);
      final result = n * childValue;

      returnValues[node.id] = '$result';
      nodeStates[node.id] = RecursionNodeState.returning;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Multiply',
        explanation: '${node.label} = $n × ${n - 1}! = $n × $childValue = $result',
        returnValues: Map.from(returnValues),
      ));

      nodeStates[node.id] = RecursionNodeState.completed;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Return $result',
        explanation: '${node.label} returns $result',
        returnValues: Map.from(returnValues),
      ));
    }

    // Pop from call stack
    callStack.removeLast();
  }
}
