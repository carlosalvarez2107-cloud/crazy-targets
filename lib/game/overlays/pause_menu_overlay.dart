import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../crazy_targets_game.dart';

class PauseMenuOverlay extends StatefulWidget {
  final CrazyTargetsGame game;

  const PauseMenuOverlay({super.key, required this.game});

  @override
  State<PauseMenuOverlay> createState() => _PauseMenuOverlayState();
}

class _PauseMenuOverlayState extends State<PauseMenuOverlay> {
  final _audioService = AudioService();

  late double _bgmVolume;
  late double _sfxVolume;

  @override
  void initState() {
    super.initState();

    // Los sliders comienzan con los valores reales del AudioService.
    _bgmVolume = _audioService.bgmVolume;
    _sfxVolume = _audioService.sfxVolume;
  }

  void _playClick() {
    _audioService.playButtonClick();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D43),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF88F3FF), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. TÍTULO PAUSE
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB703),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Text(
                  'PAUSA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // SLIDER BGM
              _buildVolumeSlider('música Volume', _bgmVolume, (value) {
                setState(() {
                  _bgmVolume = value;
                });

                // Aplicar inmediatamente el volumen real de la música.
                _audioService.bgmVolume = value;
              }),

              // SLIDER SFX
              _buildVolumeSlider('Efectos Volume', _sfxVolume, (value) {
                setState(() {
                  _sfxVolume = value;
                });

                // Aplicar inmediatamente el volumen real de los efectos.
                _audioService.sfxVolume = value;
              }),

              const SizedBox(height: 10),

              // 2. BOTÓN RESUME
              _buildMenuButton(
                text: 'REANUDAR',
                backgroundColor: const Color(0xFF4EA8DE),
                onPressed: () {
                  _playClick();

                  _audioService.resumeBGM();

                  widget.game.resumeEngine();
                  widget.game.overlays.remove('PauseMenu');
                },
              ),

              const SizedBox(height: 12),

              // 3. BOTÓN RESTART
              _buildMenuButton(
                text: 'REINICIAR',
                backgroundColor: const Color(0xFF4EA8DE),
                onPressed: () {
                  _playClick();

                  widget.game.overlays.remove('PauseMenu');
                  widget.game.restartGame();
                  widget.game.resumeEngine();
                },
              ),

              const SizedBox(height: 12),

              // 4. BOTÓN OPTIONS
              _buildMenuButton(
                text: 'OPCIONES',
                backgroundColor: const Color(0xFF4EA8DE),
                onPressed: () {
                  _playClick();
                },
              ),

              const SizedBox(height: 12),

              // 5. BOTÓN EXIT
              _buildMenuButton(
                text: 'SALIR',
                backgroundColor: const Color(0xFFE63946),
                onPressed: () {
                  _playClick();

                  // Finaliza correctamente la partida actual
                  // y regresa al menú principal.
                  widget.game.exitToMainMenu();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          activeColor: const Color(0xFFFFB703),
          inactiveColor: Colors.white24,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required String text,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
