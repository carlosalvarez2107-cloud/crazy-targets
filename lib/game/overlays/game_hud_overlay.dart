import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../crazy_targets_game.dart';

class GameHudOverlay extends StatelessWidget {
  final CrazyTargetsGame game;

  const GameHudOverlay({super.key, required this.game});

  void _pauseGame() {
    AudioService().playButtonClick(); // Sonido hit.mp3
    AudioService().stopBGM(); // Pausa la música
    game.pauseEngine(); // Congela la física y ciclo del juego
    game.overlays.add('PauseMenu'); // Muestra el menú de pausa
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Botón de Pausa en la esquina superior derecha
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pauseGame,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFB703),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.pause_rounded,
                    color: Color(0xFFFFB703),
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
