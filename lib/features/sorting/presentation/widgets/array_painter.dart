import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/colors_manager.dart';

class ArrayPainter extends CustomPainter {
  final List<int> data;
  final Set<int> activeIndices;
  final Set<int> comparedIndices;
  final Set<int> sortedIndices;
  final bool isDarkMode;

  ArrayPainter({
    required this.data,
    required this.activeIndices,
    required this.comparedIndices,
    required this.sortedIndices,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final barWidth = (size.width - (data.length - 1) * 2) / data.length;
    final maxValue = data.reduce(max);
    final maxBarHeight = size.height * 0.95;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxValue) * maxBarHeight;
      final x = i * (barWidth + 2);
      final y = size.height - barHeight;

      // Determine color based on state
      Color color;
      if (sortedIndices.contains(i)) {
        color = ColorsManager.sortedElement;
      } else if (activeIndices.contains(i)) {
        color = ColorsManager.activeElement;
      } else if (comparedIndices.contains(i)) {
        color = ColorsManager.comparedElement;
      } else {
        color = isDarkMode
            ? ColorsManager.defaultBarDark
            : ColorsManager.defaultBar;
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, paint);

      // Draw value on top of bar if there's enough space
      if (barWidth > 20 && barHeight > 20) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${data[i]}',
            style: TextStyle(
              color: Colors.white,
              fontSize: barWidth > 30 ? 12 : 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final textX = x + (barWidth - textPainter.width) / 2;
        final textY = y + 4;
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArrayPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.activeIndices != activeIndices ||
        oldDelegate.comparedIndices != comparedIndices ||
        oldDelegate.sortedIndices != sortedIndices ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
