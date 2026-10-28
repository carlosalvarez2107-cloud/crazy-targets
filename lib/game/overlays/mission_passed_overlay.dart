import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../crazy_targets_game.dart';

class MissionPassedOverlay extends StatefulWidget {
  final CrazyTargetsGame game;

  const MissionPassedOverlay({super.key, required this.game});

  @override
  State<MissionPassedOverlay> createState() => _MissionPassedOverlayState();
}

class _MissionPassedOverlayState extends State<MissionPassedOverlay> {
  @override
  void initState() {
    super.initState();
    _playVictorySound();
  }

  /// Reproduce el sonido real de victoria al superar el nivel
  Future<void> _playVictorySound() async {
    try {
      await FlameAudio.play('victory.mp3');
    } catch (e) {
      debugPrint('Error reproduciendo victory.mp3: $e');
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
              // 1. TÍTULO MISSION PASSED (ESTILO PIXEL DORADO ORIGINAL)
              const _StrokeText(
                text: 'MISSION PASSED',
                fontSize: 38,
                fillColor: Color(0xFFFFD700),
                strokeColor: Colors.black,
                strokeWidth: 12,
                innerStrokeColor: Colors.white,
              ),
              const SizedBox(height: 20),

              // 2. ESTRELLAS DE DESEMPEÑO
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

              // 3. PUNTAJE DEL NIVEL
              Text(
                '${state.levelScore} PTS',
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

              // 4. BOTONES CIRCULARES DORADOS (BACK, RESTART, NEXT)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconButtonArcade(
                    icon: Icons.arrow_back_rounded,
                    label: 'BACK',
                    onTap: () {
                      // Acción para volver al menú principal
                    },
                  ),
                  const SizedBox(width: 16),

                  _IconButtonArcade(
                    icon: Icons.refresh_rounded,
                    label: 'RESTART',
                    onTap: () => widget.game.restartGame(),
                  ),
                  const SizedBox(width: 16),

                  _IconButtonArcade(
                    icon: Icons.play_arrow_rounded,
                    label: 'NEXT',
                    isPrimary: true,
                    onTap: () {
                      widget.game.startNextLevel();
                    },
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

/// Botón circular estilo arcade con paleta dorada constante
class _IconButtonArcade extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  bool get isEnabled => onTap != null;

  const _IconButtonArcade({
    required this.icon,
    required this.label,
    this.onTap,
    this.isPrimary = false,
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

/// Texto en capas estilo Pixel
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
