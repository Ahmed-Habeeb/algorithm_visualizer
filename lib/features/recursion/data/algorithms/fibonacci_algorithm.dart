import '../../domain/entities/recursion_tree_node_entity.dart';
import '../../domain/entities/recursion_frame_entity.dart';
import '../../domain/interfaces/recursion_algorithm.dart';

class FibonacciAlgorithm implements RecursionAlgorithm {
  @override
  String get name => 'Fibonacci';

  @override
  String get description =>
      'Calculate the nth Fibonacci number recursively: F(n) = F(n-1) + F(n-2)';

  int _nodeIdCounter = 0;

  String _generateNodeId() {
    return 'fib_${_nodeIdCounter++}';
  }

  @override
  RecursionTreeNodeEntity buildTree(int input) {
    _nodeIdCounter = 0;
    return _buildFibTree(input, 0, null);
  }

  RecursionTreeNodeEntity _buildFibTree(int n, int depth, String? parentId) {
    final nodeId = _generateNodeId();

    if (n <= 1) {
      return RecursionTreeNodeEntity(
        id: nodeId,
        label: 'fib($n)',
        argument: '$n',
        returnValue: '$n',
        depth: depth,
        parentId: parentId,
      );
    }

    final leftChild = _buildFibTree(n - 1, depth + 1, nodeId);
    final rightChild = _buildFibTree(n - 2, depth + 1, nodeId);

    return RecursionTreeNodeEntity(
      id: nodeId,
      label: 'fib($n)',
      argument: '$n',
      depth: depth,
      children: [leftChild, rightChild],
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
      explanation: 'Starting Fibonacci calculation for ${tree.label}',
      returnValues: Map.from(returnValues),
    ));

    // Generate frames using DFS traversal
    _generateDfsFrames(tree, frames, nodeStates, returnValues, callStack);

    // Add final frame
    frames.add(RecursionFrameEntity(
      nodeStates: Map.from(nodeStates),
      callStack: [],
      operation: 'Complete',
      explanation:
          'Fibonacci calculation complete! ${tree.label} = ${returnValues[tree.id]}',
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
      // Base case
      nodeStates[node.id] = RecursionNodeState.computing;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Base case',
        explanation:
            '${node.label} is a base case. Returning ${node.returnValue}',
        returnValues: Map.from(returnValues),
      ));

      returnValues[node.id] = node.returnValue!;
      nodeStates[node.id] = RecursionNodeState.completed;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Return ${node.returnValue}',
        explanation: '${node.label} returns ${node.returnValue}',
        returnValues: Map.from(returnValues),
      ));
    } else {
      // Recursive case - process children
      nodeStates[node.id] = RecursionNodeState.computing;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Compute ${node.label}',
        explanation:
            '${node.label} needs to compute children first: fib(${int.parse(node.argument!) - 1}) + fib(${int.parse(node.argument!) - 2})',
        returnValues: Map.from(returnValues),
      ));

      // Process left child (n-1)
      _generateDfsFrames(
        node.children[0],
        frames,
        nodeStates,
        returnValues,
        callStack,
      );

      // Process right child (n-2)
      _generateDfsFrames(
        node.children[1],
        frames,
        nodeStates,
        returnValues,
        callStack,
      );

      // Calculate result
      final leftValue = int.parse(returnValues[node.children[0].id]!);
      final rightValue = int.parse(returnValues[node.children[1].id]!);
      final result = leftValue + rightValue;

      returnValues[node.id] = '$result';
      nodeStates[node.id] = RecursionNodeState.returning;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Combine results',
        explanation:
            '${node.label} = fib(${int.parse(node.argument!) - 1}) + fib(${int.parse(node.argument!) - 2}) = $leftValue + $rightValue = $result',
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
