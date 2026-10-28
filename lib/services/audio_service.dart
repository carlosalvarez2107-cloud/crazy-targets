import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  AudioService._internal();

  bool isMuted = false;

  double _bgmVolume = 0.5;
  double _sfxVolume = 1.0;

  String _currentTrack = 'bgm_1.mp3';

  bool _bgmPaused = false;

  // ============================================================
  // PERSISTENCIA
  // ============================================================

  static const String _bgmVolumeKey = 'bgm_volume';
  static const String _sfxVolumeKey = 'sfx_volume';
  static const String _muteKey = 'audio_muted';

  bool _settingsLoaded = false;

  /// Carga la configuración de audio guardada.
  Future<void> loadSettings() async {
    if (_settingsLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      _bgmVolume = prefs.getDouble(_bgmVolumeKey) ?? 0.5;
      _sfxVolume = prefs.getDouble(_sfxVolumeKey) ?? 1.0;
      isMuted = prefs.getBool(_muteKey) ?? false;

      _settingsLoaded = true;
    } catch (_) {
      // Si ocurre un error, se mantienen los valores predeterminados.
    }
  }

  /// Guarda la configuración actual de audio.
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setDouble(_bgmVolumeKey, _bgmVolume);
      await prefs.setDouble(_sfxVolumeKey, _sfxVolume);
      await prefs.setBool(_muteKey, isMuted);
    } catch (_) {
      // Un problema al guardar preferencias no debe detener el juego.
    }
  }

  Future<void> restoreDefaultSettings() async {
    _bgmVolume = 0.5;
    _sfxVolume = 1.0;
    isMuted = false;
    _bgmPaused = false;

    await _saveSettings();
  }

  // ============================================================
  // VOLUMEN BGM
  // ============================================================

  double get bgmVolume => _bgmVolume;

  set bgmVolume(double value) {
    _bgmVolume = value.clamp(0.0, 1.0);

    if (!isMuted && !_bgmPaused) {
      _applyBgmVolume();
    }

    _saveSettings();
  }

  // ============================================================
  // VOLUMEN SFX
  // ============================================================

  double get sfxVolume => _sfxVolume;

  set sfxVolume(double value) {
    _sfxVolume = value.clamp(0.0, 1.0);

    _saveSettings();
  }

  // ============================================================
  // SFX GENERAL
  // ============================================================

  Future<void> playSfx(String fileName) async {
    if (isMuted || _sfxVolume <= 0) return;

    try {
      await FlameAudio.play(fileName, volume: _sfxVolume);
    } catch (_) {
      // El audio no debe detener el juego si ocurre un problema.
    }
  }

  // ============================================================
  // SONIDO DE BOTONES
  // ============================================================

  Future<void> playButtonClick() async {
    await playSfx('buttons.mp3');
  }

  // ============================================================
  // BGM
  // ============================================================

  void playBGM([String fileName = 'bgm_1.mp3']) {
    _currentTrack = fileName;
    _bgmPaused = false;

    if (isMuted || _bgmVolume <= 0) {
      return;
    }

    try {
      FlameAudio.bgm.play(_currentTrack, volume: _bgmVolume);
    } catch (_) {}
  }

  // ============================================================
  // PAUSAR BGM
  // ============================================================

  void stopBGM() {
    try {
      FlameAudio.bgm.pause();
      _bgmPaused = true;
    } catch (_) {}
  }

  // ============================================================
  // REANUDAR BGM
  // ============================================================

  void resumeBGM() {
    if (isMuted || _bgmVolume <= 0) {
      return;
    }

    try {
      FlameAudio.bgm.resume();
      _bgmPaused = false;

      _applyBgmVolume();
    } catch (_) {
      playBGM(_currentTrack);
    }
  }

  // ============================================================
  // APLICAR VOLUMEN A LA PISTA ACTUAL
  // ============================================================

  void _applyBgmVolume() {
    if (isMuted || _bgmPaused) {
      return;
    }

    try {
      FlameAudio.bgm.audioPlayer.setVolume(_bgmVolume);
    } catch (_) {}
  }

  // ============================================================
  // MUTE / UNMUTE
  // ============================================================

  void toggleMute() {
    isMuted = !isMuted;

    if (isMuted) {
      stopBGM();
    } else {
      resumeBGM();
    }

    _saveSettings();
  }
}
