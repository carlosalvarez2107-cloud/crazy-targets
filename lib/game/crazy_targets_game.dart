import 'package:flame/events.dart'; // <--- Importante para capturar toques
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

import '../models/game_state.dart';
import '../services/score_repository.dart';
import 'components/classic_duck.dart';
import 'components/bomb_target.dart';
import 'components/golden_duck.dart';
import 'components/heart_lives.dart';
import 'components/ammo_hud.dart'; // <--- Importación del HUD de Munición
import 'components/level_progress_bar.dart';
import 'managers/target_spawner.dart';
import '../services/audio_service.dart';
import 'components/Dog/dog_entrance.dart';

class CrazyTargetsGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  // Modelos de Estado y Backend
  late GameState gameState;
  late ScoreRepository scoreRepository;

  // Componentes de la Interfaz (HUD) y Escenario
  late TextComponent scoreText;
  late HeartLivesComponent heartsDisplay;
  late AmmoHudComponent ammoDisplay;
  late LevelProgressBar levelProgressBar;
  late SpriteComponent backgroundComponent;

  DogEntranceComponent? _dogEntrance;

  @override
  Color backgroundColor() => const Color(0xFF181B26);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Paso 3: Congelamos el motor inmediatamente al cargar para evitar ejecución fantasma en el menú principal
    pauseEngine();

    // 1. Inicialización y Precarga Completa de Audios
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'hit.mp3',
      'special_hit.mp3',
      'explosion.mp3',
      'victory.mp3',
      'game_over.mp3',
      'dog_bark.mp3',
      'bgm.mp3',
      'bgm_1.mp3',
      'cuak.mp3',
    ]);

    // 2. Inicialización de Arquitectura y Backend
    gameState = GameState();
    scoreRepository = ScoreRepository();

    // 3. Fondo Ilustrado del Escenario (background_1.png)
    backgroundComponent = SpriteComponent(
      sprite: await loadSprite('background_1.png'),
      size: size,
      priority: -10,
    );
    add(backgroundComponent);

    // 3.1 Precarga del sprite del perro (mascota). Al tenerlo en cache
    // desde ya, la primera aparicion de DogEntranceComponent no tiene
    // que cargarlo "al vuelo", que era la causa de la desincronizacion.
    await images.load('dog_run.png');

    // 4. Tarjeta de Fondo del Marcador (HUD)
    final hudCard = RectangleComponent(
      position: Vector2(15, 15),
      size: Vector2(180, 75),
      paint: Paint()
        ..color = const Color(0xFF0F111A).withAlpha(210)
        ..style = PaintingStyle.fill,
    );
    add(hudCard);

    // 5. Borde Neón HUD
    final hudBorder = RectangleComponent(
      position: Vector2(15, 15),
      size: Vector2(180, 75),
      paint: Paint()
        ..color = const Color(0xFFFFB703)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    add(hudBorder);

    // 6. Texto del Puntaje
    scoreText = TextComponent(
      text: 'PUNTOS: 0000',
      position: Vector2(28, 24),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFB703),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
    add(scoreText);

    // 7. Muestra de Corazones (Vidas)
    heartsDisplay = HeartLivesComponent(
      lives: gameState.lives,
      position: Vector2(28, 52),
      heartSize: 18.0,
    );
    add(heartsDisplay);

    // 7.1 Muestra de Munición (Balas)
    ammoDisplay = AmmoHudComponent(position: Vector2(115, 52));
    add(ammoDisplay);

    // 8. Barra de Progreso del Nivel con Inicial del Usuario
    levelProgressBar = LevelProgressBar(
      position: Vector2(205, 40),
      size: Vector2(165, 22),
      userInitial: 'C',
    );
    add(levelProgressBar);

    // 9. Generador de Tráfico por Carriles
    add(TargetSpawner());
  }

  /// Captura toques en pantalla y gestiona disparos al aire.
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    // Si el toque impactó a una diana (handled = true), no se procesa como tiro al aire
    if (event.handled) {
      _updateScoreHud();
      return;
    }

    // Procesa el disparo al aire descontando 1 bala
    final bool fired = gameState.consumeAmmo();
    _updateScoreHud(); // Actualiza el conteo de balas en la pantalla inmediatamente

    if (!fired) {
      // Si intentó disparar y no tiene balas, evalúa si debe mostrar recarga
      _checkOutOfAmmoCondition();
    } else {
      // Revisa si la última bala se consumió al aire
      if (!gameState.hasAmmo) {
        _checkOutOfAmmoCondition();
      }
    }
  }

  /// Verifica si el jugador se quedó sin munición antes de completar el nivel
  void _checkOutOfAmmoCondition() {
    if (!gameState.hasAmmo &&
        gameState.levelScore < gameState.targetScoreForCurrentLevel) {
      clearAllTargets();
      AudioService().stopBGM();
      pauseEngine();
      overlays.remove('GameHud'); // Oculta botón de pausa al quedarse sin balas
      overlays.add('OutOfAmmo');
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      backgroundComponent.size = size;
    }
  }

  Future<void> _playDogEntrance() async {
    final dog = DogEntranceComponent();
    _dogEntrance = dog;

    add(dog);
    AudioService().playSfx('dog_bark.mp3');
    resumeEngine();

    // Esperamos el reloj REAL de la animacion (no un timer externo
    // adivinado), asi nunca se corta antes de terminar su recorrido.
    await dog.onFinished;

    dog.removeFromParent();
    if (identical(_dogEntrance, dog)) {
      _dogEntrance = null;
    }
  }

  /// Suma puntos (o resta si es bomba) y verifica la meta del nivel
  void addScore(int points) {
    gameState.addPoints(points);
    _updateScoreHud();

    if (gameState.levelScore >= gameState.targetScoreForCurrentLevel) {
      completeLevel();
    }
  }

  /// Quita una vida, actualiza el HUD y evalúa Game Over
  void loseLife() {
    if (gameState.lives > 0) {
      gameState.lives--;
      heartsDisplay.updateLives(gameState.lives);

      if (gameState.lives <= 0) {
        triggerGameOver();
      }
    }
  }

  /// Otorga una vida extra (Pato Dorado) sin superar el máximo de 3
  void addLife() {
    if (gameState.lives < 3) {
      gameState.lives++;
      heartsDisplay.updateLives(gameState.lives);
    }
  }

  /// Actualiza visualmente el marcador, la barra de progreso y la munición
  void _updateScoreHud() {
    final formattedScore = gameState.levelScore.toString().padLeft(4, '0');
    scoreText.text = 'PUNTOS: $formattedScore';

    // Actualiza las balas en pantalla
    ammoDisplay.updateAmmo(gameState.levelAmmo + gameState.extraAmmo);

    levelProgressBar.updateProgress(
      gameState.levelScore,
      gameState.targetScoreForCurrentLevel,
    );
  }

  /// Limpia objetivos activos en pantalla sin borrar el HUD
  void clearAllTargets() {
    children
        .where((c) => c is ClassicDuck || c is BombTarget || c is GoldenDuck)
        .toList()
        .forEach((c) => c.removeFromParent());
  }

  /// Detiene el tráfico, apaga la música y muestra MissionPassed
  void completeLevel() {
    clearAllTargets();
    AudioService().stopBGM();
    pauseEngine();
    overlays.remove('GameHud'); // Oculta botón de pausa en pantalla de victoria
    overlays.add('MissionPassed');

    scoreRepository.saveGlobalScore(gameState);
  }

  /// Detiene el tráfico, apaga la música y muestra GameOver
  void triggerGameOver() {
    clearAllTargets();
    AudioService().stopBGM();
    pauseEngine();
    overlays.remove('GameHud'); // Oculta botón de pausa en Game Over
    overlays.add('GameOver');

    scoreRepository.saveGlobalScore(gameState);
  }

  /// startNextLevel()Pasa al siguiente nivel, reanuda la música de fondo y desbloquea el juego
  Future<void> startNextLevel() async {
    gameState.completeCurrentLevel();
    _updateScoreHud();

    overlays.remove('MissionPassed');
    overlays.add('GameHud');

    final audioService = AudioService();

    audioService.stopBGM();
    audioService.playBGM('bgm.mp3');

    await _playDogEntrance();

    resumeEngine();
  }

  /// Método para reiniciar completamente el nivel actual (RESTART)
  Future<void> restartGame() async {
    gameState = GameState();

    _updateScoreHud();
    heartsDisplay.updateLives(gameState.lives);

    clearAllTargets();

    overlays.remove('GameOver');
    overlays.remove('OutOfAmmo');
    overlays.remove('PauseMenu');
    overlays.add('GameHud');

    // El AudioService es ahora el único encargado
    // de iniciar nuevamente la música.
    final audioService = AudioService();

    audioService.stopBGM();
    audioService.playBGM('bgm.mp3');

    await _playDogEntrance();
    resumeEngine();
  }

  /// Método para salir de forma segura al Menú Principal (EXIT - Paso 5)
  void exitToMainMenu() {
    pauseEngine();
    clearAllTargets();

    gameState = GameState();
    _updateScoreHud();
    heartsDisplay.updateLives(gameState.lives);

    final audioService = AudioService();
    audioService.stopBGM();
    audioService.playBGM('bgm_1.mp3');

    overlays.remove('PauseMenu');
    overlays.remove('GameOver');
    overlays.remove('OutOfAmmo');
    overlays.remove('GameHud');
    overlays.add('MainMenu');
  }
}
