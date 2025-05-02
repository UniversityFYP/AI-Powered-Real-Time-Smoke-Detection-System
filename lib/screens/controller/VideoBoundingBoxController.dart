import 'dart:ui';

import 'package:flutter/material.dart';

class VideoBoundingBoxPainter extends CustomPainter {
  final Size videoSize;
  final List<dynamic> detections;
  final Paint Function(String) getClassPaint;

  VideoBoundingBoxPainter({
    required this.videoSize,
    required this.detections,
    required this.getClassPaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / videoSize.width;
    final scaleY = size.height / videoSize.height;

    for (final detection in detections) {
      final bbox = detection['bbox'];
      final rect = Rect.fromLTRB(
        bbox[0].toDouble() * scaleX,
        bbox[1].toDouble() * scaleY,
        bbox[2].toDouble() * scaleX,
        bbox[3].toDouble() * scaleY,
      );

      // Draw bounding box
      final boxPaint = getClassPaint(detection['class_name']);
      canvas.drawRect(rect, boxPaint);

      // Draw label
      final textSpan = TextSpan(
        text: '${detection['class_name']} ${(detection['confidence'] * 100).toStringAsFixed(1)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          backgroundColor: Colors.black54,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left, rect.top - textPainter.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}