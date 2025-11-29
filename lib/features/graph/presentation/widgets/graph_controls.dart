import 'package:flutter/material.dart';

class GraphControls extends StatelessWidget {
  final String? startNode;
  final String? endNode;
  final bool canRun;
  final bool hasRun;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;
  final VoidCallback onRun;
  final VoidCallback onGenerate;

  const GraphControls({
    super.key,
    this.startNode,
    this.endNode,
    required this.canRun,
    required this.hasRun,
    required this.onSelectStart,
    required this.onSelectEnd,
    required this.onRun,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Graph Controls',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Node selection
          Row(
            children: [
              Expanded(
                child: _NodeSelector(
                  label: 'Start',
                  nodeId: startNode,
                  color: Colors.green,
                  onSelect: onSelectStart,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NodeSelector(
                  label: 'End',
                  nodeId: endNode,
                  color: Colors.red,
                  onSelect: onSelectEnd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Graph'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: canRun ? onRun : null,
                  icon: Icon(hasRun ? Icons.replay : Icons.play_arrow),
                  label: Text(hasRun ? 'Re-run' : 'Run'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NodeSelector extends StatelessWidget {
  final String label;
  final String? nodeId;
  final Color color;
  final VoidCallback onSelect;

  const _NodeSelector({
    required this.label,
    this.nodeId,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onSelect,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: nodeId != null ? color : Colors.transparent,
              border: Border.all(color: color, width: 2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            nodeId != null ? '$label: $nodeId' : 'Set $label',
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}
