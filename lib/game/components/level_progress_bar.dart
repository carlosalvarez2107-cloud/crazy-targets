import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelProgressBar extends PositionComponent with HasGameReference {
  double progress = 0.0;
  String userInitial;

  final Vector2 barSize;

  LevelProgressBar({
    required Vector2 position,
    Vector2? size,
    this.userInitial = 'C', // Inicial del usuario por defecto
  }) : barSize = size ?? Vector2(170, 22),
       super(position: position, size: size ?? Vector2(170, 22), priority: 15);

  /// Actualiza el progreso y opcionalmente la inicial del usuario
  void updateProgress(int currentScore, int targetScore, {String? initial}) {
    if (targetScore <= 0) return;
    progress = (currentScore / targetScore).clamp(0.0, 1.0);
    if (initial != null && initial.isNotEmpty) {
      userInitial = initial[0].toUpperCase();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    const double badgeRadius = 18.0; // Tamaño del medallón circular
    final double barX = badgeRadius;
    final double barWidth = barSize.x - badgeRadius;
    final double barHeight = barSize.y;

    // 1. Cápsula de Fondo (Riel)
    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, (barSize.y - barHeight) / 2, barWidth, barHeight),
      Radius.circular(barHeight / 2),
    );

    final bgPaint = Paint()
      ..color = const Color(0xFF0F111A).withAlpha(230)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bgRRect, bgPaint);

    // 2. Relleno Neón en Degradado (Progreso)
    if (progress > 0) {
      final fillWidth = barWidth * progress;
      if (fillWidth > 4) {
        final fillRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            barX,
            (barSize.y - barHeight) / 2,
            fillWidth,
            barHeight,
          ),
          Radius.circular(barHeight / 2),
        );

        final fillPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF00FF66), Color(0xFF88FF00)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(barX, 0, fillWidth, barHeight))
          ..style = PaintingStyle.fill;

        canvas.drawRRect(fillRRect, fillPaint);
      }
    }

    // 3. Borde Dorado Neón de la Cápsula
    final borderPaint = Paint()
      ..color = const Color(0xFFFFB703)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(bgRRect, borderPaint);

    // 4. Medallón Circular en Relieve (Izquierda)
    final badgeCenter = Offset(badgeRadius, barSize.y / 2);

    // Gradiente dorado del medallón
    final badgeOuterPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE066), Color(0xFFFFB703)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: badgeCenter, radius: badgeRadius));
    canvas.drawCircle(badgeCenter, badgeRadius, badgeOuterPaint);

    // Anillo interior blanco brillante
    final badgeBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(badgeCenter, badgeRadius, badgeBorderPaint);

    // Centro oscuro del medallón
    final badgeInnerPaint = Paint()
      ..color = const Color(0xFF181B26)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(badgeCenter, badgeRadius - 3.5, badgeInnerPaint);

    // Texto con la inicial del usuario en el centro (Ej. "C")
    final displayChar = userInitial.isNotEmpty
        ? userInitial[0].toUpperCase()
        : 'U';
    final textPainter = TextPainter(
      text: TextSpan(
        text: displayChar,
        style: const TextStyle(
          color: Color(0xFFFFB703),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      badgeCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // 5. Texto Porcentaje sobre la barra
    final pctPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toInt()}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    pctPainter.layout();
    pctPainter.paint(
      canvas,
      Offset(
        barX + (barWidth / 2) - (pctPainter.width / 2),
        (barSize.y / 2) - (pctPainter.height / 2),
      ),
    );
  }
}
