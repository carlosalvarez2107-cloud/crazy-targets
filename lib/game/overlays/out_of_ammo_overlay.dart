import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../crazy_targets_game.dart';

class OutOfAmmoOverlay extends StatelessWidget {
  final CrazyTargetsGame game;

  const OutOfAmmoOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. TÍTULO PRINCIPAL
              const _StrokeText(
                text: 'SIN BALAS',
                fontSize: 38,
                fillColor: Color(0xFFFFB703),
                strokeColor: Colors.black,
                strokeWidth: 12,
                innerStrokeColor: Colors.white,
              ),
              const SizedBox(height: 8),

              // 2. SUBTÍTULO
              const Text(
                '¡Te has quedado sin balas!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),

              // 3. BOTÓN PRINCIPAL
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB703),
                  foregroundColor: const Color(0xFF4A2800),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                onPressed: () {
                  // Otorga 10 balas de inventario extra
                  game.gameState.extraAmmo += 10;

                  // Oculta la pantalla y reanuda el juego
                  game.overlays.remove('OutOfAmmo');
                  FlameAudio.bgm.play('bgm.mp3', volume: 0.4);
                  game.resumeEngine();
                },
                icon: const Icon(
                  Icons.add_shopping_cart_rounded,
                  size: 26,
                  color: Color(0xFF4A2800),
                ),
                label: const Text(
                  'OBTENER MUNICIÓN',
                  style: TextStyle(
                    color: Color(0xFF4A2800),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 4. BOTONES SECUNDARIOS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconButtonArcade(
                    icon: Icons.arrow_back_rounded,
                    label: 'MENÚ',
                    onTap: () {
                      // Acción para salir al menú principal
                    },
                  ),
                  const SizedBox(width: 20),

                  _IconButtonArcade(
                    icon: Icons.refresh_rounded,
                    label: 'REINICIAR',
                    onTap: () => game.restartGame(),
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

  const _IconButtonArcade({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            try {
              await FlameAudio.play('hit.mp3');
            } catch (_) {}
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE066), Color(0xFFFFB703)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.8),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: const Color(0xFF4A2800)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFFB703),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
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
