import 'package:flutter/material.dart';

class CallStackVisualizer extends StatelessWidget {
  final List<String> callStack;
  final String? activeCall;

  const CallStackVisualizer({
    super.key,
    required this.callStack,
    this.activeCall,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.layers,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Call Stack',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Depth: ${callStack.length}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stack frames
          Expanded(
            child: callStack.isEmpty
                ? Center(
                    child: Text(
                      'Empty',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: callStack.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = callStack.length - 1 - index;
                      final call = callStack[reversedIndex];
                      final isTop = reversedIndex == callStack.length - 1;
                      final isActive = call == activeCall;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _buildStackFrame(
                          context,
                          call,
                          reversedIndex,
                          isTop,
                          isActive,
                        ),
                      );
                    },
                  ),
          ),

          // Stack pointer indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Stack grows upward',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackFrame(
    BuildContext context,
    String call,
    int depth,
    bool isTop,
    bool isActive,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isActive || isTop) {
      backgroundColor = Colors.orange.shade50;
      borderColor = Colors.orange;
      textColor = Colors.orange.shade900;
    } else {
      backgroundColor = colorScheme.surfaceContainerHighest;
      borderColor = colorScheme.outlineVariant;
      textColor = colorScheme.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: isTop ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Depth indicator
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$depth',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Call name
          Expanded(
            child: Text(
              call,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),

          // Top indicator
          if (isTop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'TOP',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
