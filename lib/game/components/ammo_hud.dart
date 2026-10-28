import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../crazy_targets_game.dart';

class AmmoHudComponent extends TextComponent
    with HasGameReference<CrazyTargetsGame> {
  AmmoHudComponent({required Vector2 position})
    : super(text: '🔫 30', position: position, priority: 10);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    textRenderer = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFB703),
        fontSize: 15,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        shadows: [
          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
        ],
      ),
    );
  }

  /// Actualiza la cantidad visual de munición disponible
  void updateAmmo(int totalAmmo) {
    text = '🔫 $totalAmmo';
  }
}
