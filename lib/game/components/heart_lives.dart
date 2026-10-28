import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HeartLivesComponent extends PositionComponent {
  int lives;
  final double heartSize;

  HeartLivesComponent({
    required this.lives,
    required Vector2 position,
    this.heartSize = 20.0,
  }) : super(position: position);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = const Color(0xFFFF0055)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < lives; i++) {
      final double offsetX = i * (heartSize + 8.0);
      _drawHeart(canvas, Offset(offsetX, 0), heartSize, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset offset, double size, Paint paint) {
    final path = Path();
    final width = size;
    final height = size;

    path.moveTo(offset.dx + width / 2, offset.dy + height / 5);

    path.cubicTo(
      offset.dx + width / 7, offset.dy - height / 3,
      offset.dx - width / 3, offset.dy + height / 2,
      offset.dx + width / 2, offset.dy + height,
    );

    path.cubicTo(
      offset.dx + width + width / 3, offset.dy + height / 2,
      offset.dx + width - width / 7, offset.dy - height / 3,
      offset.dx + width / 2, offset.dy + height / 5,
    );

    canvas.drawPath(path, paint);
  }

  void updateLives(int newLives) {
    lives = newLives;
  }
}