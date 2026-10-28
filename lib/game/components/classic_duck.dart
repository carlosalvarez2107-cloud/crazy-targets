import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../services/audio_service.dart';
import '../crazy_targets_game.dart';
import 'score_text_effect.dart';

class ClassicDuck extends SpriteAnimationComponent
    with TapCallbacks, HasGameReference<CrazyTargetsGame> {
  final double speed;
  final int lane;

  // Movimiento vertical de zigzag.
  final double amplitude = 40.0;
  final double frequency = 5.0;
  double _time = 0.0;

  ClassicDuck({
    required this.speed,
    required this.lane,
    required Vector2 position,
  }) : super(
         position: position,
         size: Vector2(50, 50),
         anchor: Anchor.center,
         removeOnFinish: false,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Cargamos la sprite sheet con los 6 frames.
    final image = await game.images.load('classic_duck_animation.png');

    // Animación:
    // Frame 1 → 2 → 3 → 4 → 5 → 6 → repetir.
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.09,
        textureSize: Vector2(256, 256),
        loop: true,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    // Movimiento horizontal.
    position.x += speed * dt;

    // Movimiento vertical en zigzag.
    position.y += sin(_time * frequency) * amplitude * dt;

    // Si sale por la derecha, pierde una vida.
    if (position.x > game.size.x + 50) {
      game.loseLife();
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Consume una bala.
    final bool fired = game.gameState.consumeAmmo();

    if (!fired) return;

    // Evita que el mismo toque sea contado como disparo al aire.
    event.handled = true;

    // Sonido del pato.
    AudioService().playSfx('cuak.mp3');

    // Efecto visual de puntos.
    game.add(
      ScoreTextEffect(
        points: 500,
        position: position.clone(),
        isNegative: false,
      ),
    );

    // Suma 500 puntos.
    game.addScore(500);

    // Elimina el pato alcanzado.
    removeFromParent();
  }
}
