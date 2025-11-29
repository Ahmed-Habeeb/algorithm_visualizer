import 'dart:math' as math;

import '../../domain/entities/data_structure_entity.dart';
import '../../domain/entities/ds_visualization_frame_entity.dart';
import '../../domain/interfaces/data_structure.dart';

class _BSTNode {
  int value;
  _BSTNode? left;
  _BSTNode? right;

  _BSTNode(this.value);
}

class BinarySearchTree implements DataStructure {
  @override
  DataStructureEntity get info => const DataStructureEntity(
        id: 'bst',
        name: 'Binary Search Tree',
        description:
            'A Binary Search Tree (BST) is a hierarchical data structure where each node has at most two children. For each node, all values in the left subtree are smaller, and all values in the right subtree are larger.',
        category: 'non_linear',
        operations: ['insert', 'delete', 'search', 'inorder'],
        timeComplexities: {
          'insert': 'O(log n) avg, O(n) worst',
          'delete': 'O(log n) avg, O(n) worst',
          'search': 'O(log n) avg, O(n) worst',
        },
        spaceComplexity: 'O(n)',
        pseudocode: [
          'insert(root, value):',
          '  if root is null:',
          '    return new Node(value)',
          '  if value < root.value:',
          '    root.left = insert(root.left, value)',
          '  else:',
          '    root.right = insert(root.right, value)',
          '  return root',
          '',
          'search(root, value):',
          '  if root is null or root.value == value:',
          '    return root',
          '  if value < root.value:',
          '    return search(root.left, value)',
          '  return search(root.right, value)',
        ],
      );

  @override
  List<DSVisualizationFrameEntity> insert(List<int> currentData, int value) {
    final frames = <DSVisualizationFrameEntity>[];
    final data = List<int>.from(currentData);

    // Build initial tree
    _BSTNode? root = _buildTree(data);

    frames.add(DSVisualizationFrameEntity(
      operation: 'Insert Start',
      explanation: 'Inserting $value into the BST.',
      nodes: _treeToNodes(root, null, null),
      edges: _treeToEdges(root),
    ));

    // Insert the new value with visualization
    if (root == null) {
      root = _BSTNode(value);
      data.add(value);
      frames.add(DSVisualizationFrameEntity(
        operation: 'Create Root',
        explanation: 'Tree was empty. $value becomes the root.',
        nodes: _treeToNodes(root, value.toString(), null),
        edges: _treeToEdges(root),
      ));
    } else {
      _BSTNode current = root;
      while (true) {
        frames.add(DSVisualizationFrameEntity(
          operation: 'Compare',
          explanation: 'Comparing $value with ${current.value}. ${value < current.value ? "Going left" : "Going right"}.',
          nodes: _treeToNodes(root, current.value.toString(), null),
          edges: _treeToEdges(root),
        ));

        if (value < current.value) {
          if (current.left == null) {
            current.left = _BSTNode(value);
            data.add(value);
            frames.add(DSVisualizationFrameEntity(
              operation: 'Insert Left',
              explanation: 'Inserted $value as left child of ${current.value}.',
              nodes: _treeToNodes(root, value.toString(), null),
              edges: _treeToEdges(root),
            ));
            break;
          }
          current = current.left!;
        } else {
          if (current.right == null) {
            current.right = _BSTNode(value);
            data.add(value);
            frames.add(DSVisualizationFrameEntity(
              operation: 'Insert Right',
              explanation: 'Inserted $value as right child of ${current.value}.',
              nodes: _treeToNodes(root, value.toString(), null),
              edges: _treeToEdges(root),
            ));
            break;
          }
          current = current.right!;
        }
      }
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Complete',
      explanation: 'Insert complete. Tree now has ${data.length} nodes.',
      nodes: _treeToNodes(root, null, null),
      edges: _treeToEdges(root),
    ));

    return frames;
  }

  @override
  List<DSVisualizationFrameEntity> delete(List<int> currentData, int value) {
    final frames = <DSVisualizationFrameEntity>[];
    final data = List<int>.from(currentData);

    _BSTNode? root = _buildTree(data);

    if (root == null) {
      frames.add(const DSVisualizationFrameEntity(
        operation: 'Error',
        explanation: 'Tree is empty! Nothing to delete.',
        nodes: [],
        edges: [],
      ));
      return frames;
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Delete Start',
      explanation: 'Searching for $value to delete.',
      nodes: _treeToNodes(root, null, null),
      edges: _treeToEdges(root),
    ));

    // Search for the node
    _BSTNode? current = root;

    while (current != null && current.value != value) {
      frames.add(DSVisualizationFrameEntity(
        operation: 'Search',
        explanation: 'Comparing $value with ${current.value}.',
        nodes: _treeToNodes(root, current.value.toString(), null),
        edges: _treeToEdges(root),
      ));

      if (value < current.value) {
        current = current.left;
      } else {
        current = current.right;
      }
    }

    if (current == null) {
      frames.add(DSVisualizationFrameEntity(
        operation: 'Not Found',
        explanation: '$value was not found in the tree.',
        nodes: _treeToNodes(root, null, null),
        edges: _treeToEdges(root),
      ));
      return frames;
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Found',
      explanation: 'Found $value. Proceeding with deletion.',
      nodes: _treeToNodes(root, value.toString(), null),
      edges: _treeToEdges(root),
    ));

    // Perform deletion
    data.remove(value);
    root = _buildTree(data);

    frames.add(DSVisualizationFrameEntity(
      operation: 'Complete',
      explanation: 'Deleted $value. Tree restructured.',
      nodes: _treeToNodes(root, null, null),
      edges: _treeToEdges(root),
    ));

    return frames;
  }

  @override
  List<DSVisualizationFrameEntity> search(List<int> currentData, int value) {
    final frames = <DSVisualizationFrameEntity>[];

    _BSTNode? root = _buildTree(currentData);

    if (root == null) {
      frames.add(const DSVisualizationFrameEntity(
        operation: 'Empty',
        explanation: 'Tree is empty! Nothing to search.',
        nodes: [],
        edges: [],
      ));
      return frames;
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Search Start',
      explanation: 'Searching for $value starting from root.',
      nodes: _treeToNodes(root, null, null),
      edges: _treeToEdges(root),
    ));

    _BSTNode? current = root;
    while (current != null) {
      frames.add(DSVisualizationFrameEntity(
        operation: 'Compare',
        explanation: 'Comparing $value with ${current.value}.',
        nodes: _treeToNodes(root, current.value.toString(), null),
        edges: _treeToEdges(root),
      ));

      if (value == current.value) {
        frames.add(DSVisualizationFrameEntity(
          operation: 'Found',
          explanation: 'Found $value!',
          nodes: _treeToNodes(root, null, current.value.toString()),
          edges: _treeToEdges(root),
        ));
        return frames;
      } else if (value < current.value) {
        frames.add(DSVisualizationFrameEntity(
          operation: 'Go Left',
          explanation: '$value < ${current.value}, going left.',
          nodes: _treeToNodes(root, current.value.toString(), null),
          edges: _treeToEdges(root),
        ));
        current = current.left;
      } else {
        frames.add(DSVisualizationFrameEntity(
          operation: 'Go Right',
          explanation: '$value > ${current.value}, going right.',
          nodes: _treeToNodes(root, current.value.toString(), null),
          edges: _treeToEdges(root),
        ));
        current = current.right;
      }
    }

    frames.add(DSVisualizationFrameEntity(
      operation: 'Not Found',
      explanation: '$value was not found in the tree.',
      nodes: _treeToNodes(root, null, null),
      edges: _treeToEdges(root),
    ));

    return frames;
  }

  @override
  List<DSVisualizationFrameEntity> visualize(List<int> data) {
    final root = _buildTree(data);
    return [
      DSVisualizationFrameEntity(
        operation: 'Display',
        explanation: 'Binary Search Tree with ${data.length} nodes.',
        nodes: _treeToNodes(root, null, null),
        edges: _treeToEdges(root),
      ),
    ];
  }

  _BSTNode? _buildTree(List<int> data) {
    if (data.isEmpty) return null;

    _BSTNode? root;
    for (final value in data) {
      root = _insertNode(root, value);
    }
    return root;
  }

  _BSTNode _insertNode(_BSTNode? node, int value) {
    if (node == null) return _BSTNode(value);

    if (value < node.value) {
      node.left = _insertNode(node.left, value);
    } else {
      node.right = _insertNode(node.right, value);
    }
    return node;
  }

  List<DSNodeData> _treeToNodes(_BSTNode? root, String? currentId, String? foundId) {
    if (root == null) return [];

    final nodes = <DSNodeData>[];
    final nodeMap = <int, (double, double, int)>{}; // value -> (x, y, level)

    void assignPositions(_BSTNode? node, double x, double y, double offset, int level) {
      if (node == null) return;

      nodeMap[node.value] = (x, y, level);

      assignPositions(node.left, x - offset / 2, y + 0.15, offset / 2, level + 1);
      assignPositions(node.right, x + offset / 2, y + 0.15, offset / 2, level + 1);
    }

    assignPositions(root, 0.5, 0.1, 0.25, 0);

    void addNodes(_BSTNode? node) {
      if (node == null) return;

      final pos = nodeMap[node.value]!;
      DSNodeState state = DSNodeState.normal;

      if (node.value.toString() == foundId) {
        state = DSNodeState.found;
      } else if (node.value.toString() == currentId) {
        state = DSNodeState.current;
      }

      nodes.add(DSNodeData(
        id: 'node_${node.value}',
        value: node.value,
        x: math.max(0.05, math.min(0.95, pos.$1)),
        y: pos.$2,
        state: state,
      ));

      addNodes(node.left);
      addNodes(node.right);
    }

    addNodes(root);
    return nodes;
  }

  List<DSEdgeData> _treeToEdges(_BSTNode? root) {
    if (root == null) return [];

    final edges = <DSEdgeData>[];

    void addEdges(_BSTNode? node) {
      if (node == null) return;

      if (node.left != null) {
        edges.add(DSEdgeData(
          fromId: 'node_${node.value}',
          toId: 'node_${node.left!.value}',
        ));
        addEdges(node.left);
      }

      if (node.right != null) {
        edges.add(DSEdgeData(
          fromId: 'node_${node.value}',
          toId: 'node_${node.right!.value}',
        ));
        addEdges(node.right);
      }
    }

    addEdges(root);
    return edges;
  }
}
