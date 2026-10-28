import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import '../crazy_targets_game.dart';
import '../../services/audio_service.dart';

class SplashScreenOverlay extends StatefulWidget {
  final CrazyTargetsGame game;

  const SplashScreenOverlay({super.key, required this.game});

  @override
  State<SplashScreenOverlay> createState() => _SplashScreenOverlayState();
}

class _SplashScreenOverlayState extends State<SplashScreenOverlay> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  /// Sistema de precarga real de recursos.
  ///
  /// IMPORTANTE: la inicializacion de audio (FlameAudio.bgm.initialize())
  /// y la precarga de los archivos de audio viven en UN SOLO lugar:
  /// CrazyTargetsGame.onLoad(). Antes tambien se hacian aqui, lo que
  /// generaba dos inicializaciones compitiendo entre si y provocaba que
  /// la musica se detuviera justo al llegar al menu. Esta pantalla ahora
  /// solo espera a que el juego termine de cargar (widget.game.loaded).
  Future<void> _loadAssets() async {
    // 1. Lista de imágenes a precargar (para la barra de progreso visual)
    final images = [
      'background_1.png',
      // Aquí agregaremos background_2.png, etc., en el futuro.
    ];

    // +1 paso = esperar a que CrazyTargetsGame.onLoad() termine
    // (ahí se inicializa el audio y se precargan los sonidos).
    final totalSteps = images.length + 1;
    int completedSteps = 0;

    // Precargar Imágenes
    for (final image in images) {
      await Flame.images.load(image);
      completedSteps++;
      if (mounted) {
        setState(() => _progress = completedSteps / totalSteps);
      }
    }

    // Esperar a que el juego (audio incluido) termine de cargar
    await widget.game.loaded;
    completedSteps++;
    if (mounted) {
      setState(() => _progress = completedSteps / totalSteps);
    }

    // 3. Transición al terminar de cargar
    if (mounted) {
      // Pasa al menú principal
      widget.game.overlays.remove('SplashScreen');
      widget.game.overlays.add('MainMenu');

      // Inicia la música del menú principal
      AudioService().playBGM('bgm_1.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181B26), // Fondo sólido de resguardo
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Imagen de fondo con BoxFit.contain para evitar recortes
            Image.asset(
              'assets/images/splash.png',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),

            // Barra de Progreso y Porcentaje
            Positioned(
              bottom: 60,
              child: Column(
                children: [
                  Text(
                    'CARGANDO... ${(_progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFFFFB800),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 300,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F111A).withAlpha(200),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF88F3FF),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFB800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
