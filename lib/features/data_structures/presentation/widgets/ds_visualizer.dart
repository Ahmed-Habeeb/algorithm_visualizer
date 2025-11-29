import 'package:flutter/material.dart';

import '../../domain/entities/ds_visualization_frame_entity.dart';

class DSVisualizer extends StatelessWidget {
  final DSVisualizationFrameEntity frame;
  final String structureId;

  const DSVisualizer({
    super.key,
    required this.frame,
    required this.structureId,
  });

  @override
  Widget build(BuildContext context) {
    if (structureId == 'stack' || structureId == 'queue') {
      return _buildLinearVisualization(context);
    } else if (structureId == 'linked_list') {
      return _buildLinkedListVisualization(context);
    } else if (structureId == 'bst') {
      return _buildTreeVisualization(context);
    }
    return const Center(child: Text('Unknown structure'));
  }

  Widget _buildLinearVisualization(BuildContext context) {
    final data = frame.arrayData ?? [];
    final theme = Theme.of(context);
    final isStack = structureId == 'stack';

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isStack ? Icons.layers_clear : Icons.inbox,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isStack ? 'Stack is empty' : 'Queue is empty',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth / (data.length + 1)).clamp(60.0, 100.0);
        final itemHeight = itemWidth * 0.8;

        if (isStack) {
          // Stack: vertical layout (bottom to top)
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ...List.generate(data.length, (index) {
                    final reverseIndex = data.length - 1 - index;
                    final isTop = reverseIndex == frame.topIndex;
                    final isCurrent = reverseIndex == frame.currentIndex;

                    return _buildStackItem(
                      context,
                      data[reverseIndex],
                      isTop,
                      isCurrent,
                      itemWidth,
                      itemHeight,
                      reverseIndex,
                    );
                  }),
                  const SizedBox(height: 8),
                  Container(
                    width: itemWidth * 1.2,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Base', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          );
        } else {
          // Queue: horizontal layout (left to right)
          return Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_forward, color: Colors.green),
                      const Text('Front', style: TextStyle(fontSize: 12, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(data.length, (index) {
                    final isHead = index == frame.headIndex;
                    final isTail = index == frame.tailIndex;
                    final isCurrent = index == frame.currentIndex;

                    return _buildQueueItem(
                      context,
                      data[index],
                      isHead,
                      isTail,
                      isCurrent,
                      itemWidth,
                      itemHeight,
                      index,
                    );
                  }),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.red),
                      const Text('Rear', style: TextStyle(fontSize: 12, color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildStackItem(
    BuildContext context,
    int value,
    bool isTop,
    bool isCurrent,
    double width,
    double height,
    int index,
  ) {
    Color bgColor = Theme.of(context).cardTheme.color ?? Colors.grey.shade200;
    Color borderColor = Colors.grey;

    if (isCurrent) {
      bgColor = Colors.orange;
      borderColor = Colors.orange.shade700;
    } else if (isTop) {
      bgColor = Colors.green.shade100;
      borderColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrent ? Colors.white : null,
              ),
            ),
          ),
          if (isTop)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, size: 16, color: Colors.green),
                  Text(' TOP', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(
    BuildContext context,
    int value,
    bool isHead,
    bool isTail,
    bool isCurrent,
    double width,
    double height,
    int index,
  ) {
    Color bgColor = Theme.of(context).cardTheme.color ?? Colors.grey.shade200;
    Color borderColor = Colors.grey;

    if (isCurrent) {
      bgColor = Colors.orange;
      borderColor = Colors.orange.shade700;
    } else if (isHead) {
      bgColor = Colors.green.shade100;
      borderColor = Colors.green;
    } else if (isTail) {
      bgColor = Colors.red.shade100;
      borderColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrent ? Colors.white : null,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '[$index]',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedListVisualization(BuildContext context) {
    final nodes = frame.nodes;

    if (nodes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Linked List is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: LinkedListPainter(
            nodes: nodes,
            edges: frame.edges,
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          ),
        );
      },
    );
  }

  Widget _buildTreeVisualization(BuildContext context) {
    final nodes = frame.nodes;

    if (nodes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Tree is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: TreePainter(
            nodes: nodes,
            edges: frame.edges,
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          ),
        );
      },
    );
  }
}

class LinkedListPainter extends CustomPainter {
  final List<DSNodeData> nodes;
  final List<DSEdgeData> edges;
  final bool isDarkMode;

  LinkedListPainter({
    required this.nodes,
    required this.edges,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeRadius = size.height * 0.15;
    final nodePositions = <String, Offset>{};

    // Calculate positions
    for (final node in nodes) {
      nodePositions[node.id] = Offset(
        node.x * size.width,
        node.y * size.height,
      );
    }

    // Draw edges (arrows)
    final edgePaint = Paint()
      ..color = isDarkMode ? Colors.white70 : Colors.black54
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final edge in edges) {
      final from = nodePositions[edge.fromId];
      final to = nodePositions[edge.toId];
      if (from != null && to != null) {
        final direction = (to - from).direction;
        final start = from + Offset.fromDirection(direction, nodeRadius);
        final end = to - Offset.fromDirection(direction, nodeRadius + 8);

        canvas.drawLine(start, end, edgePaint);

        // Draw arrowhead
        final arrowPath = Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(end.dx - 8 * cos(direction - 0.4), end.dy - 8 * sin(direction - 0.4))
          ..moveTo(end.dx, end.dy)
          ..lineTo(end.dx - 8 * cos(direction + 0.4), end.dy - 8 * sin(direction + 0.4));
        canvas.drawPath(arrowPath, edgePaint);
      }
    }

    // Draw nodes
    for (final node in nodes) {
      final center = nodePositions[node.id]!;

      Color fillColor;
      Color borderColor;

      switch (node.state) {
        case DSNodeState.highlighted:
          fillColor = Colors.green;
          borderColor = Colors.green.shade700;
          break;
        case DSNodeState.current:
          fillColor = Colors.orange;
          borderColor = Colors.orange.shade700;
          break;
        case DSNodeState.found:
          fillColor = Colors.blue;
          borderColor = Colors.blue.shade700;
          break;
        default:
          fillColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
          borderColor = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500;
      }

      // Draw node circle
      canvas.drawCircle(center, nodeRadius, Paint()..color = fillColor);
      canvas.drawCircle(center, nodeRadius, Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);

      // Draw value
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${node.value}',
          style: TextStyle(
            color: node.state == DSNodeState.normal
                ? (isDarkMode ? Colors.white : Colors.black)
                : Colors.white,
            fontSize: nodeRadius * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));

      // Draw label
      if (node.label != null) {
        final labelPainter = TextPainter(
          text: TextSpan(
            text: node.label,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 12,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        labelPainter.layout();
        labelPainter.paint(canvas, Offset(center.dx - labelPainter.width / 2, center.dy + nodeRadius + 8));
      }
    }
  }

  double cos(double angle) => angle.cos();
  double sin(double angle) => angle.sin();

  @override
  bool shouldRepaint(LinkedListPainter oldDelegate) => true;
}

extension on double {
  double cos() => cos();
  double sin() => sin();
}

class TreePainter extends CustomPainter {
  final List<DSNodeData> nodes;
  final List<DSEdgeData> edges;
  final bool isDarkMode;

  TreePainter({
    required this.nodes,
    required this.edges,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeRadius = size.width * 0.03;
    final nodePositions = <String, Offset>{};

    // Calculate positions
    for (final node in nodes) {
      nodePositions[node.id] = Offset(
        node.x * size.width,
        node.y * size.height,
      );
    }

    // Draw edges
    final edgePaint = Paint()
      ..color = isDarkMode ? Colors.white70 : Colors.black54
      ..strokeWidth = 2;

    for (final edge in edges) {
      final from = nodePositions[edge.fromId];
      final to = nodePositions[edge.toId];
      if (from != null && to != null) {
        canvas.drawLine(from, to, edgePaint);
      }
    }

    // Draw nodes
    for (final node in nodes) {
      final center = nodePositions[node.id]!;

      Color fillColor;
      Color borderColor;

      switch (node.state) {
        case DSNodeState.highlighted:
          fillColor = Colors.green;
          borderColor = Colors.green.shade700;
          break;
        case DSNodeState.current:
          fillColor = Colors.orange;
          borderColor = Colors.orange.shade700;
          break;
        case DSNodeState.found:
          fillColor = Colors.blue;
          borderColor = Colors.blue.shade700;
          break;
        default:
          fillColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
          borderColor = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500;
      }

      // Draw node circle
      canvas.drawCircle(center, nodeRadius, Paint()..color = fillColor);
      canvas.drawCircle(center, nodeRadius, Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);

      // Draw value
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${node.value}',
          style: TextStyle(
            color: node.state == DSNodeState.normal
                ? (isDarkMode ? Colors.white : Colors.black)
                : Colors.white,
            fontSize: nodeRadius * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) => true;
}
