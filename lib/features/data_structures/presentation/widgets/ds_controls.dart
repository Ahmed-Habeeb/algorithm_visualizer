import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DSControls extends StatefulWidget {
  final String structureId;
  final Function(int) onInsert;
  final Function(int) onDelete;
  final Function(int) onSearch;
  final VoidCallback onRandomize;
  final VoidCallback onClear;

  const DSControls({
    super.key,
    required this.structureId,
    required this.onInsert,
    required this.onDelete,
    required this.onSearch,
    required this.onRandomize,
    required this.onClear,
  });

  @override
  State<DSControls> createState() => _DSControlsState();
}

class _DSControlsState extends State<DSControls> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  int? _getInputValue() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  String get _insertLabel {
    switch (widget.structureId) {
      case 'stack':
        return 'Push';
      case 'queue':
        return 'Enqueue';
      default:
        return 'Insert';
    }
  }

  String get _deleteLabel {
    switch (widget.structureId) {
      case 'stack':
        return 'Pop';
      case 'queue':
        return 'Dequeue';
      default:
        return 'Delete';
    }
  }

  bool get _deleteNeedsValue {
    return widget.structureId != 'stack' && widget.structureId != 'queue';
  }

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
            'Operations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Input field
          TextField(
            controller: _inputController,
            decoration: InputDecoration(
              labelText: 'Value (1-99)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
          ),
          const SizedBox(height: 12),

          // Operation buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OperationButton(
                label: _insertLabel,
                icon: Icons.add,
                color: Colors.green,
                onPressed: () {
                  final value = _getInputValue();
                  if (value != null && value > 0 && value <= 99) {
                    widget.onInsert(value);
                    _inputController.clear();
                  } else {
                    _showError(context, 'Please enter a value between 1 and 99');
                  }
                },
              ),
              _OperationButton(
                label: _deleteLabel,
                icon: Icons.remove,
                color: Colors.red,
                onPressed: () {
                  if (_deleteNeedsValue) {
                    final value = _getInputValue();
                    if (value != null) {
                      widget.onDelete(value);
                      _inputController.clear();
                    } else {
                      _showError(context, 'Please enter a value to delete');
                    }
                  } else {
                    widget.onDelete(0); // Value doesn't matter for stack/queue
                  }
                },
              ),
              _OperationButton(
                label: 'Search',
                icon: Icons.search,
                color: Colors.blue,
                onPressed: () {
                  final value = _getInputValue();
                  if (value != null) {
                    widget.onSearch(value);
                  } else {
                    _showError(context, 'Please enter a value to search');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Utility buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onRandomize,
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text('Random'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onClear,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _OperationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _OperationButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
