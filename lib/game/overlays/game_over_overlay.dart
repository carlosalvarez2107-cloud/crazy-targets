import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../crazy_targets_game.dart';

class GameOverOverlay extends StatefulWidget {
  final CrazyTargetsGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  @override
  void initState() {
    super.initState();
    _playGameOverSound();
  }

  /// Reproduce el audio de Game Over asegurando la carga del hilo
  Future<void> _playGameOverSound() async {
    try {
      await FlameAudio.play('game_over.mp3');
    } catch (e) {
      debugPrint('Error reproduciendo game_over.mp3: $e');
    }
  }

  int _calculateStars() {
    final state = widget.game.gameState;
    final halfTarget = state.targetScoreForCurrentLevel / 2;

    if (state.lives == 3 &&
        state.levelScore >= state.targetScoreForCurrentLevel) {
      return 3;
    } else if (state.levelScore >= halfTarget) {
      return 2;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.game.gameState;
    final stars = _calculateStars();

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. TÍTULO GAME OVER EN TRES CAPAS (ESTILO PIXEL)
              const _StrokeText(
                text: 'GAME OVER',
                fontSize: 44,
                fillColor: Color(0xFFFF0033),
                strokeColor: Colors.black,
                strokeWidth: 12,
                innerStrokeColor: Colors.white,
              ),
              const SizedBox(height: 20),

              // 2. SISTEMA DE ESTRELLAS DE DESEMPEÑO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isEarned = index < stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Icon(
                      Icons.star_rounded,
                      size: index == 1 ? 52 : 42,
                      color: isEarned
                          ? const Color(0xFFFFD700)
                          : Colors.white24,
                      shadows: isEarned
                          ? [
                              const Shadow(
                                color: Color(0xFFFFB703),
                                blurRadius: 15,
                              ),
                            ]
                          : [],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // 3. TEXTO DE PUNTAJE LIMPIO
              Text(
                '${state.totalGlobalScore} PTS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 4. TRÍO DE BOTONES CIRCULARES (BACK, RESTART, NEXT BLOQUEADO)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón BACK (Menú Principal - Activo)
                  _IconButtonArcade(
                    icon: Icons.arrow_back_rounded,
                    label: 'BACK',
                    onTap: () {
                      // Acción para volver al menú principal
                    },
                  ),
                  const SizedBox(width: 16),

                  // Botón RESTART (Reintentar - Destacado al centro)
                  _IconButtonArcade(
                    icon: Icons.refresh_rounded,
                    label: 'RESTART',
                    isPrimary: true,
                    onTap: () => widget.game.restartGame(),
                  ),
                  const SizedBox(width: 16),

                  // Botón NEXT (Deshabilitado / Semitransparente)
                  const _IconButtonArcade(
                    icon: Icons.play_arrow_rounded,
                    label: 'NEXT',
                    isEnabled: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para botones circulares estilo arcade (Soporta estado deshabilitado)
class _IconButtonArcade extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isEnabled;

  const _IconButtonArcade({
    required this.icon,
    required this.label,
    this.onTap,
    this.isPrimary = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isPrimary ? 68.0 : 56.0;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.35,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: isEnabled
                ? () async {
                    // Espera a que el driver de audio inicie 'hit.mp3' antes de destruir la pantalla
                    try {
                      await FlameAudio.play('hit.mp3');
                    } catch (_) {}
                    onTap?.call();
                  }
                : null,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isEnabled
                    ? const LinearGradient(
                        colors: [Color(0xFFFFE066), Color(0xFFFFB703)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF777777), Color(0xFF444444)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                border: Border.all(
                  color: isEnabled ? Colors.white : Colors.white38,
                  width: 3,
                ),
                boxShadow: isEnabled
                    ? const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.8),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                size: isPrimary ? 36 : 28,
                color: isEnabled ? const Color(0xFF4A2800) : Colors.white54,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isEnabled ? const Color(0xFFFFB703) : Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Auxiliar para texto en capas estilo Pixel
class _StrokeText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final Color? innerStrokeColor;

  const _StrokeText({
    required this.text,
    required this.fontSize,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    this.innerStrokeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        if (innerStrokeColor != null)
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth / 2.2
                ..color = innerStrokeColor!,
            ),
          ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: fillColor,
          ),
        ),
      ],
    );
  }
}
