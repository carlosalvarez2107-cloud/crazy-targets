import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../crazy_targets_game.dart';
import '../../services/audio_service.dart';
import 'score_text_effect.dart';

class BombTarget extends SpriteAnimationComponent
    with TapCallbacks, HasGameReference<CrazyTargetsGame> {
  final double speed;
  final int lane;

  BombTarget({
    required this.speed,
    required this.lane,
    required Vector2 position,
  }) : super(position: position, size: Vector2(45, 45), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'bomb_animation.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.08,
        textureSize: Vector2(256, 256),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x += speed * dt;

    if (position.x > game.size.x + 50) {
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // 1. Intenta consumir 1 bala
    final bool fired = game.gameState.consumeAmmo();
    if (!fired) return;

    // 2. Marca el evento como manejado
    event.handled = true;

    // 3. Reproduce el sonido pasando por AudioService.
    //    Ahora respeta el volumen SFX configurado.
    AudioService().playSfx('explosion.mp3');

    game.add(
      ScoreTextEffect(
        points: 250,
        position: position + Vector2(-15, 0),
        isNegative: true,
      ),
    );

    game.add(BoomTextEffect(position: position + Vector2(15, 0)));

    game.addScore(-250);
    game.loseLife();
    removeFromParent();
  }
}

// Corregido: Se añade el tipo <CrazyTargetsGame>
class BoomTextEffect extends TextComponent
    with HasGameReference<CrazyTargetsGame> {
  double _timer = 0.0;
  static const double duration = 0.8;

  BoomTextEffect({required Vector2 position})
    : super(
        text: '¡BOOM!',
        position: position,
        anchor: Anchor.center,
        priority: 25,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    textRenderer = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFF5500),
        fontSize: 22,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    position.y -= 45 * dt;

    if (_timer >= duration) {
      removeFromParent();
    }
  }
}
