import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../services/audio_service.dart';
import '../crazy_targets_game.dart';
import 'score_text_effect.dart';

class GoldenDuck extends SpriteAnimationComponent
    with TapCallbacks, HasGameReference<CrazyTargetsGame> {
  final double speed;
  final int lane;

  GoldenDuck({
    required this.speed,
    required this.lane,
    required Vector2 position,
  }) : super(position: position, size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'golden_duck_animation.png',
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

    // Audio: efecto especial del Golden Duck
    AudioService().playSfx('special_hit.mp3');
    AudioService().playSfx('golden_cuak.mp3');

    game.add(
      ScoreTextEffect(
        points: 1000,
        position: position.clone(),
        isNegative: false,
      ),
    );

    game.addScore(1000);
    game.addLife();
    removeFromParent();
  }
}
