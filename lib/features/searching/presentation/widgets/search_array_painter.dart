import 'package:flutter/material.dart';

import '../../domain/entities/search_visualization_frame_entity.dart';

class SearchArrayPainter extends CustomPainter {
  final SearchVisualizationFrameEntity frame;
  final Color defaultColor;
  final Color currentColor;
  final Color foundColor;
  final Color checkedColor;
  final Color boundColor;
  final Color midColor;

  SearchArrayPainter({
    required this.frame,
    required this.defaultColor,
    required this.currentColor,
    required this.foundColor,
    required this.checkedColor,
    required this.boundColor,
    required this.midColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (frame.data.isEmpty) return;

    final barWidth = size.width / frame.data.length;
    final maxValue = frame.data.reduce((a, b) => a > b ? a : b).toDouble();
    final padding = barWidth * 0.1;

    for (int i = 0; i < frame.data.length; i++) {
      final barHeight = (frame.data[i] / maxValue) * (size.height - 40);
      final x = i * barWidth + padding;
      final y = size.height - barHeight - 20;

      // Determine bar color based on state
      Color barColor = defaultColor;

      // Check if this index has been checked/visited
      if (frame.checkedIndices.contains(i)) {
        barColor = checkedColor;
      }

      // Check if this is within bounds (for binary search)
      if (frame.leftBound != null && frame.rightBound != null) {
        if (i >= frame.leftBound! && i <= frame.rightBound!) {
          barColor = boundColor;
        } else {
          barColor = checkedColor.withValues(alpha: 0.3);
        }
      }

      // Highlight mid index
      if (frame.midIndex != null && i == frame.midIndex) {
        barColor = midColor;
      }

      // Highlight current index being checked
      if (frame.currentIndex != null && i == frame.currentIndex) {
        barColor = currentColor;
      }

      // Highlight found index
      if (frame.foundIndex != null && i == frame.foundIndex) {
        barColor = foundColor;
      }

      // Draw bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth - padding * 2, barHeight),
        const Radius.circular(4),
      );

      final paint = Paint()
        ..color = barColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, paint);

      // Draw value text
      final textPainter = TextPainter(
        text: TextSpan(
          text: frame.data[i].toString(),
          style: TextStyle(
            color: barColor,
            fontSize: barWidth > 30 ? 12 : 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + (barWidth - padding * 2 - textPainter.width) / 2,
          size.height - 15,
        ),
      );

      // Draw index below bar
      final indexPainter = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: defaultColor.withValues(alpha: 0.6),
            fontSize: barWidth > 30 ? 10 : 7,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      indexPainter.layout();
      indexPainter.paint(
        canvas,
        Offset(
          x + (barWidth - padding * 2 - indexPainter.width) / 2,
          y - 15,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SearchArrayPainter oldDelegate) {
    return oldDelegate.frame != frame;
  }
}

class SearchArrayVisualization extends StatelessWidget {
  final SearchVisualizationFrameEntity frame;

  const SearchArrayVisualization({super.key, required this.frame});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomPaint(
      painter: SearchArrayPainter(
        frame: frame,
        defaultColor: colorScheme.primary,
        currentColor: colorScheme.secondary,
        foundColor: Colors.green,
        checkedColor: Colors.grey,
        boundColor: colorScheme.primary.withValues(alpha: 0.7),
        midColor: Colors.orange,
      ),
      size: Size.infinite,
    );
  }
}
