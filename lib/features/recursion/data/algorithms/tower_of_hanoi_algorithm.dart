import '../../domain/entities/recursion_tree_node_entity.dart';
import '../../domain/entities/recursion_frame_entity.dart';
import '../../domain/interfaces/recursion_algorithm.dart';

class TowerOfHanoiAlgorithm implements RecursionAlgorithm {
  @override
  String get name => 'Tower of Hanoi';

  @override
  String get description =>
      'Move n disks from source peg to destination peg using an auxiliary peg';

  int _nodeIdCounter = 0;
  int _moveCounter = 0;

  String _generateNodeId() {
    return 'hanoi_${_nodeIdCounter++}';
  }

  @override
  RecursionTreeNodeEntity buildTree(int input) {
    _nodeIdCounter = 0;
    return _buildHanoiTree(input, 'A', 'C', 'B', 0, null);
  }

  RecursionTreeNodeEntity _buildHanoiTree(
    int n,
    String source,
    String dest,
    String aux,
    int depth,
    String? parentId,
  ) {
    final nodeId = _generateNodeId();

    if (n == 1) {
      return RecursionTreeNodeEntity(
        id: nodeId,
        label: 'H(1,$source→$dest)',
        argument: '1,$source,$dest,$aux',
        depth: depth,
        parentId: parentId,
      );
    }

    // Move n-1 disks from source to aux
    final leftChild = _buildHanoiTree(n - 1, source, aux, dest, depth + 1, nodeId);
    // Move 1 disk from source to dest (implicit in the node itself)
    // Move n-1 disks from aux to dest
    final rightChild = _buildHanoiTree(n - 1, aux, dest, source, depth + 1, nodeId);

    return RecursionTreeNodeEntity(
      id: nodeId,
      label: 'H($n,$source→$dest)',
      argument: '$n,$source,$dest,$aux',
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
    final moves = <HanoiMove>[];

    // Parse input to get number of disks
    final n = int.parse(tree.argument!.split(',')[0]);

    // Initialize pegs
    final pegs = <String, List<int>>{
      'A': List.generate(n, (i) => n - i),
      'B': [],
      'C': [],
    };

    // Initialize all nodes as pending
    _initNodeStates(tree, nodeStates);
    _moveCounter = 0;

    // Add initial frame
    frames.add(RecursionFrameEntity(
      nodeStates: Map.from(nodeStates),
      callStack: List.from(callStack),
      operation: 'Start',
      explanation: 'Starting Tower of Hanoi with $n disks. Goal: Move all disks from A to C.',
      returnValues: Map.from(returnValues),
      hanoiMoves: List.from(moves),
      hanoiPegs: _copyPegs(pegs),
    ));

    // Generate frames
    _generateHanoiFrames(tree, frames, nodeStates, returnValues, callStack, moves, pegs);

    // Add final frame
    frames.add(RecursionFrameEntity(
      nodeStates: Map.from(nodeStates),
      callStack: [],
      operation: 'Complete',
      explanation: 'Tower of Hanoi solved in $_moveCounter moves!',
      returnValues: Map.from(returnValues),
      hanoiMoves: List.from(moves),
      hanoiPegs: _copyPegs(pegs),
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

  Map<String, List<int>> _copyPegs(Map<String, List<int>> pegs) {
    return {
      'A': List.from(pegs['A']!),
      'B': List.from(pegs['B']!),
      'C': List.from(pegs['C']!),
    };
  }

  void _generateHanoiFrames(
    RecursionTreeNodeEntity node,
    List<RecursionFrameEntity> frames,
    Map<String, RecursionNodeState> nodeStates,
    Map<String, String> returnValues,
    List<String> callStack,
    List<HanoiMove> moves,
    Map<String, List<int>> pegs,
  ) {
    final parts = node.argument!.split(',');
    final n = int.parse(parts[0]);
    final source = parts[1];
    final dest = parts[2];
    final aux = parts[3];

    // Push to call stack and mark as active
    callStack.add(node.label);
    nodeStates[node.id] = RecursionNodeState.active;

    frames.add(RecursionFrameEntity(
      nodeStates: Map.from(nodeStates),
      activeNodeId: node.id,
      callStack: List.from(callStack),
      operation: 'Call ${node.label}',
      explanation: 'Move $n disk(s) from $source to $dest using $aux as auxiliary',
      returnValues: Map.from(returnValues),
      hanoiMoves: List.from(moves),
      hanoiPegs: _copyPegs(pegs),
    ));

    if (n == 1) {
      // Base case: move single disk
      nodeStates[node.id] = RecursionNodeState.computing;

      // Perform the move
      final disk = pegs[source]!.removeLast();
      pegs[dest]!.add(disk);
      _moveCounter++;

      final move = HanoiMove(disk: disk, from: source, to: dest);
      moves.add(move);

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Move disk $disk: $source → $dest',
        explanation: 'Base case: Move disk $disk directly from $source to $dest (Move #$_moveCounter)',
        returnValues: Map.from(returnValues),
        hanoiMoves: List.from(moves),
        hanoiPegs: _copyPegs(pegs),
      ));

      returnValues[node.id] = 'done';
      nodeStates[node.id] = RecursionNodeState.completed;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Return',
        explanation: 'Completed moving disk $disk from $source to $dest',
        returnValues: Map.from(returnValues),
        hanoiMoves: List.from(moves),
        hanoiPegs: _copyPegs(pegs),
      ));
    } else {
      // Recursive case
      nodeStates[node.id] = RecursionNodeState.computing;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Decompose',
        explanation:
            'To move $n disks: 1) Move ${n - 1} disks $source→$aux, 2) Move disk $n $source→$dest, 3) Move ${n - 1} disks $aux→$dest',
        returnValues: Map.from(returnValues),
        hanoiMoves: List.from(moves),
        hanoiPegs: _copyPegs(pegs),
      ));

      // Step 1: Move n-1 disks from source to aux
      _generateHanoiFrames(
        node.children[0],
        frames,
        nodeStates,
        returnValues,
        callStack,
        moves,
        pegs,
      );

      // Step 2: Move bottom disk from source to dest
      final disk = pegs[source]!.removeLast();
      pegs[dest]!.add(disk);
      _moveCounter++;

      final move = HanoiMove(disk: disk, from: source, to: dest);
      moves.add(move);

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Move disk $disk: $source → $dest',
        explanation: 'Move largest disk $disk from $source to $dest (Move #$_moveCounter)',
        returnValues: Map.from(returnValues),
        hanoiMoves: List.from(moves),
        hanoiPegs: _copyPegs(pegs),
      ));

      // Step 3: Move n-1 disks from aux to dest
      _generateHanoiFrames(
        node.children[1],
        frames,
        nodeStates,
        returnValues,
        callStack,
        moves,
        pegs,
      );

      returnValues[node.id] = 'done';
      nodeStates[node.id] = RecursionNodeState.completed;

      frames.add(RecursionFrameEntity(
        nodeStates: Map.from(nodeStates),
        activeNodeId: node.id,
        callStack: List.from(callStack),
        operation: 'Return',
        explanation: 'Completed moving $n disks from $source to $dest',
        returnValues: Map.from(returnValues),
        hanoiMoves: List.from(moves),
        hanoiPegs: _copyPegs(pegs),
      ));
    }

    // Pop from call stack
    callStack.removeLast();
  }
}
