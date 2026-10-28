import 'dart:math';
import 'package:flame/components.dart';
import '../crazy_targets_game.dart';
import '../components/classic_duck.dart';
import '../components/bomb_target.dart';
import '../components/golden_duck.dart';

class TargetSpawner extends Component with HasGameReference<CrazyTargetsGame> {
  final Random _random = Random();
  double _timer = 0.0;

  /// 1. FRECUENCIA DINÁMICA DE APARICIÓN (Aparecen más rápido con más puntos)
  double get currentSpawnInterval {
    final score = game.gameState.levelScore;
    // Empieza en 1.0 segundo y baja hasta 0.35s conforme sube el puntaje
    double calculatedInterval = 1.0 - (score / 600) * 0.10;

    // Tope mínimo: jamás bajará de 0.4s para evitar amontonamiento extremo
    return calculatedInterval.clamp(0.35, 1.0);
  }

  /// 2. VELOCIDAD GRADUAL DE LOS PATOS CLÁSICOS
  double get currentDuckSpeed {
    final score = game.gameState.levelScore;
    // Velocidad base de 150.0 + incremento progresivo de 25.0 por cada 500 puntos
    double baseSpeed = 150.0 + (score / 500) * 25.0;

    // Variación aleatoria para que no todos vayan exactamente a la misma velocidad
    return baseSpeed.clamp(150.0, 380.0) + _random.nextDouble() * 40.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.size.x == 0 || game.size.y == 0) return;

    _timer += dt;
    if (_timer >= currentSpawnInterval) {
      _timer = 0.0;
      _spawnRandomTarget();
    }
  }

  void _spawnRandomTarget() {
    // 3 Carriles de lanzamiento
    final double screenHeight = game.size.y;
    final List<double> lanes = [
      screenHeight * 0.25,
      screenHeight * 0.50,
      screenHeight * 0.70,
    ];

    final int laneIndex = _random.nextInt(lanes.length);
    final double spawnY = lanes[laneIndex];
    final Vector2 spawnPosition = Vector2(-90, spawnY);

    final bool canSpawnTraps = game.gameState.levelScore >= 1500;
    final double roll = _random.nextDouble();

    if (canSpawnTraps && roll < 0.25) {
      // 25% Probabilidad: Bomba (Solo si score >= 1500)
      game.add(
        BombTarget(
          position: spawnPosition,
          lane: laneIndex,
          speed: currentDuckSpeed,
        ),
      );
    } else if (roll < 0.35) {
      // 10% Probabilidad: Pato Dorado con velocidad fija
      const double goldenDuckSpeed = 300.0;

      game.add(
        GoldenDuck(
          position: spawnPosition,
          lane: laneIndex,
          speed: goldenDuckSpeed,
        ),
      );
    }
    // 65% Probabilidad: Pato Clásico con VELOCIDAD GRADUAL
    game.add(
      ClassicDuck(
        position: spawnPosition,
        lane: laneIndex,
        speed: currentDuckSpeed,
      ),
    );
  }
}
