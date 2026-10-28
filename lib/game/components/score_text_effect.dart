import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScoreTextEffect extends TextComponent with HasGameReference {
  final int points;
  final bool isNegative;
  double _timer = 0.0;
  static const double duration = 0.8; // Duración en segundos

  ScoreTextEffect({
    required this.points,
    required Vector2 position,
    this.isNegative = false,
  }) : super(
         text: isNegative ? '-$points' : '+$points',
         position: position,
         anchor: Anchor.center,
         priority: 20, // Aparece por encima de las presas
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Configuración visual: Verde para puntos positivos, Rojo para negativos
    final color = isNegative
        ? const Color(0xFFFF3333)
        : const Color(0xFF00FF66);

    textRenderer = TextPaint(
      style: TextStyle(
        color: color,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // Desplazamiento flotante hacia arriba
    position.y -= 40 * dt;

    // Si termina el tiempo, se remueve de la pantalla
    if (_timer >= duration) {
      removeFromParent();
    }
  }
}
