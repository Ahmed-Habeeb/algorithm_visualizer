import 'package:flutter/material.dart';

import '../../domain/entities/visualization_frame_entity.dart';
import 'array_painter.dart';

class ArrayVisualizer extends StatelessWidget {
  final VisualizationFrameEntity frame;

  const ArrayVisualizer({
    super.key,
    required this.frame,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: ArrayPainter(
            data: frame.data,
            activeIndices: frame.activeIndices,
            comparedIndices: frame.comparedIndices,
            sortedIndices: frame.sortedIndices,
            isDarkMode: isDarkMode,
          ),
        );
      },
    );
  }
}
