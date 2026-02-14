import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sokoban_game/core/enums.dart';

class ArrowButtonVisual extends PositionComponent {
  final Direction direction;
  final bool isPressed;
  final double radius;

  ArrowButtonVisual({
    required this.direction,
    this.radius = 30,
    this.isPressed = false,
  }) : super(size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // Draw background circle
    final Paint bgPaint = Paint()
      ..color = isPressed
          ? Colors.grey.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(radius, radius), radius, bgPaint);

    // Draw Arrow
    final Paint arrowPaint = Paint()
      ..color = isPressed ? Colors.white : Colors.black
      ..style = PaintingStyle.fill; // Or stroke

    final Path path = Path();

    // Create an arrow pointing RIGHT by default, then rotate
    // Arrow shape: Triangle pointing right
    // Center is (radius, radius)
    // Size of arrow is roughly radius * 0.6

    double arrowSize = radius * 0.6;

    // Triangle points:
    // Tip: (radius + arrowSize/2, radius)
    // Top-Back: (radius - arrowSize/2, radius - arrowSize/2)
    // Bottom-Back: (radius - arrowSize/2, radius + arrowSize/2)

    path.moveTo(radius + arrowSize / 2, radius);
    path.lineTo(radius - arrowSize / 2, radius - arrowSize / 2);
    path.lineTo(radius - arrowSize / 2, radius + arrowSize / 2);
    path.close();

    // Rotate canvas based on direction
    canvas.save();
    canvas.translate(radius, radius);

    double angle = 0;
    switch (direction) {
      case Direction.right:
        angle = 0;
        break;
      case Direction.down:
        angle = pi / 2;
        break;
      case Direction.left:
        angle = pi;
        break;
      case Direction.up:
        angle = -pi / 2;
        break;
    }

    canvas.rotate(angle);
    canvas.translate(-radius, -radius);

    canvas.drawPath(path, arrowPaint);
    canvas.restore();
  }
}
