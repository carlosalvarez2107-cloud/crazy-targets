import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../crazy_targets_game.dart';

abstract class BaseTarget extends SpriteComponent
    with TapCallbacks, HasGameReference<CrazyTargetsGame> {
  final double speed;
  final int points;
  int health;
  bool isHit = false;

  BaseTarget({
    required Vector2 position,
    required Vector2 size,
    required this.speed,
    required this.points,
    this.health = 1,
  }) : super(position: position, size: size);

  void move(double dt);

  @override
  void update(double dt) {
    super.update(dt);
    if (!isHit) {
      move(dt);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTargetShot();
  }

  void onTargetShot() {
    health--;
    if (health <= 0) {
      isHit = true;
      onEliminated();
    }
  }

  void onEliminated() {
    removeFromParent();
  }
}
