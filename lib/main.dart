import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';

import 'game/crazy_targets_game.dart';
import 'game/overlays/splash_screen_overlay.dart';
import 'game/overlays/main_menu_overlay.dart';
import 'game/overlays/game_hud_overlay.dart';
import 'game/overlays/pause_menu_overlay.dart';
import 'game/overlays/mission_passed_overlay.dart';
import 'game/overlays/game_over_overlay.dart';
import 'game/overlays/out_of_ammo_overlay.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  // Cargar la configuración de audio guardada
  await AudioService().loadSettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final CrazyTargetsGame _crazyTargetsGame;

  @override
  void initState() {
    super.initState();
    _crazyTargetsGame = CrazyTargetsGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<CrazyTargetsGame>(
        game: _crazyTargetsGame,
        initialActiveOverlays: const ['SplashScreen'],
        overlayBuilderMap: {
          'SplashScreen': (context, game) => SplashScreenOverlay(game: game),
          'MainMenu': (context, game) => MainMenuOverlay(game: game),
          'GameHud': (context, game) => GameHudOverlay(game: game),
          'PauseMenu': (context, game) => PauseMenuOverlay(game: game),
          'MissionPassed': (context, game) => MissionPassedOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
          'OutOfAmmo': (context, game) => OutOfAmmoOverlay(game: game),
        },
      ),
    );
  }
}
