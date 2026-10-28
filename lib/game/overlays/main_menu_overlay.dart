import 'dart:io';

import 'package:image_picker/image_picker.dart';
import '../../services/profile_image_service.dart';

import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../services/user_service.dart';
import '../crazy_targets_game.dart';
import '../effects/menu_particle_effects.dart';

extension UserServiceEmailRegistration on UserService {
  Future<void> registerWithEmail(
    String email,
    String password,
    String username,
  ) async {
    final trimmedEmail = email.trim();
    final trimmedUsername = username.trim();

    if (trimmedEmail.isEmpty) {
      throw Exception('El correo electrónico es obligatorio.');
    }

    if (password.isEmpty) {
      throw Exception('La contraseña es obligatoria.');
    }

    if (trimmedUsername.isEmpty) {
      throw Exception('El nombre de usuario es obligatorio.');
    }

    await loginWithEmail(trimmedEmail, password);

    if (currentUser == null) {
      return;
    }

    await updateProfile(newUsername: trimmedUsername);
  }
}

class MainMenuOverlay extends StatefulWidget {
  final CrazyTargetsGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  final _userService = UserService();
  final _audioService = AudioService();

  double? _previousSfxVolume;
  double? _previousBgmVolume;

  // =========================================================
  // FOTO DE PERFIL
  // =========================================================

  final _imagePicker = ImagePicker();
  final _profileImageService = ProfileImageService();

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _initializeMenu();
  }

  Future<void> _initializeMenu() async {
    if (_userService.currentUser == null) {
      await _userService.loginWithEmail('jugador@ejemplo.com', '123456');
    }

    final user = _userService.currentUser;
    if (user != null) {
      user.bgmVolume = _audioService.bgmVolume;
      user.sfxVolume = _audioService.sfxVolume;
    }

    await _loadProfileImage();

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _loadProfileImage() async {
    try {
      final savedImage = await _profileImageService.getProfileImage();

      if (!mounted) return;

      if (savedImage != null) {
        setState(() {
          _profileImage = savedImage;
        });
      }
    } catch (e) {
      // Si no existe una imagen guardada, se mantiene el avatar con la inicial.
    }
  }
  // =========================================================
  // AUDIO
  // =========================================================

  void _playClick() {
    _audioService.playButtonClick();
  }

  void _toggleSfx() {
    final user = _userService.currentUser;
    if (user == null) return;

    // No reproducimos el click cuando los efectos están apagados.
    if (user.sfxVolume > 0) {
      _playClick();
    }

    setState(() {
      if (user.sfxVolume > 0) {
        _previousSfxVolume = user.sfxVolume;

        user.sfxVolume = 0.0;
        _audioService.sfxVolume = 0.0;
      } else {
        final restoredVolume = _previousSfxVolume ?? 1.0;

        user.sfxVolume = restoredVolume;
        _audioService.sfxVolume = restoredVolume;

        _playClick();
      }
    });
  }

  void _toggleBgm() {
    _playClick();

    final user = _userService.currentUser;
    if (user == null) return;

    setState(() {
      if (user.bgmVolume > 0) {
        _previousBgmVolume = user.bgmVolume;

        user.bgmVolume = 0.0;
        _audioService.bgmVolume = 0.0;
      } else {
        final restoredVolume = _previousBgmVolume ?? 1.0;

        user.bgmVolume = restoredVolume;
        _audioService.bgmVolume = restoredVolume;
        _audioService.playBGM('bgm_1.mp3');
      }
    });
  }

  // =========================================================
  // BOTÓN PRINCIPAL
  // =========================================================

  Widget _buildMainMenuButton({
    required String label,
    required IconData icon,
    required Color baseColor,
    required Color darkColor,
    required VoidCallback onPressed,
    double iconSize = 34,
    double fontSize = 18,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(baseColor, Colors.white, 0.18)!,
                baseColor,
                darkColor,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.5),
              width: 3,
            ),
            boxShadow: [
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 0,
                offset: Offset(0, 7),
              ),
              BoxShadow(
                color: baseColor.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 3,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      shadows: const [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 3,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BOTONES PEQUEÑOS DE LA BARRA INFERIOR
  // =========================================================

  Widget _buildBottomMenuButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
    String? status,
    Color statusColor = const Color(0xFF7CFC00),
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF071225).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 25,
                shadows: const [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
              if (status != null) ...[
                const SizedBox(width: 5),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PERFIL DEL JUGADOR
  // =========================================================

  Widget _buildProfileCard(dynamic user) {
    final width = (MediaQuery.sizeOf(context).width * 0.29)
        .clamp(220.0, 330.0)
        .toDouble();

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showEditProfileDialog,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF071225).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF148CFF), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: const Color(0xFF0D1B2A),
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(
                            _profileImage!,
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                          )
                        : CircleAvatar(
                            backgroundColor: const Color(0xFFFFB703),
                            child: Text(
                              user?.initialLetter ?? 'P',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0D1B2A),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? 'Jugador',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'PERFIL',
                        style: TextStyle(
                          color: Color(0xFFFFB703),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Puntos: ${user?.globalScore ?? 0}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D4C99),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 19),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BOTÓN DE LOGROS SUPERIOR
  // =========================================================

  Widget _buildAchievementButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showAchievementsDialog,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 74,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFF071225).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFB703), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFB703),
                size: 28,
              ),
              SizedBox(height: 2),
              Text(
                'LOGROS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // REGISTRO
  // =========================================================

  void _showRegisterDialog() {
    _playClick();

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();

    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFFFB703), width: 2),
              ),
              title: const Text(
                'REGISTRAR USUARIO',
                style: TextStyle(
                  color: Color(0xFFFFB703),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.facebook, color: Colors.white),
                      label: const Text(
                        'Continuar con Facebook',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        _playClick();

                        try {
                          await _userService.loginWithFacebook();

                          if (!mounted) return;

                          setState(() {});

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        } catch (e) {
                          setModalState(() {
                            errorMessage = e.toString().replaceAll(
                              'Exception: ',
                              '',
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white30)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'O con tu correo',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white30)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFB703)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFB703)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFB703)),
                        ),
                        errorText: errorMessage,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _playClick();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB703),
                  ),
                  onPressed: () async {
                    _playClick();

                    try {
                      await _userService.registerWithEmail(
                        emailController.text,
                        passwordController.text,
                        usernameController.text,
                      );

                      if (!mounted) return;

                      setState(() {});

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    } catch (e) {
                      setModalState(() {
                        errorMessage = e.toString().replaceAll(
                          'Exception: ',
                          '',
                        );
                      });
                    }
                  },
                  child: const Text(
                    'REGISTRAR CORREO',
                    style: TextStyle(
                      color: Color(0xFF0D1B2A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      emailController.dispose();
      passwordController.dispose();
      usernameController.dispose();
    });
  }
  // =========================================================
  // SELECCIONAR FOTO DE PERFIL
  // =========================================================

  Future<void> _pickProfileImage(
    void Function(void Function()) setModalState,
  ) async {
    _playClick();

    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedImage == null) {
        return;
      }

      final selectedFile = File(pickedImage.path);

      final savedFile = await _profileImageService.saveProfileImage(
        selectedFile,
      );

      if (!mounted) return;

      // Actualiza el avatar del diálogo.
      setModalState(() {
        _profileImage = savedFile;
      });

      // Actualiza también el avatar del menú principal.
      setState(() {
        _profileImage = savedFile;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar la imagen: ${e.toString()}'),
        ),
      );
    }
  }
  // =========================================================
  // EDITAR PERFIL
  // =========================================================

  void _showEditProfileDialog() {
    _playClick();

    final user = _userService.currentUser;
    if (user == null) return;

    final controller = TextEditingController(text: user.username);

    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFFFB703), width: 2),
              ),
              title: const Text(
                'EDITAR PERFIL',
                style: TextStyle(
                  color: Color(0xFFFFB703),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // =========================================================
                  // AVATAR + BOTÓN EDITAR FOTO
                  // =========================================================
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: _profileImage != null
                              ? Image.file(
                                  _profileImage!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                              : CircleAvatar(
                                  radius: 35,
                                  backgroundColor: const Color(0xFFFFB703),
                                  child: Text(
                                    user.initialLetter,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D1B2A),
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      // BOTÓN DEL LÁPIZ
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _pickProfileImage(setModalState);
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D4C99),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black87,
                                    blurRadius: 4,
                                    offset: Offset(1, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFFB703)),
                      ),
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _playClick();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB703),
                  ),
                  onPressed: () async {
                    _playClick();

                    try {
                      await _userService.updateProfile(
                        newUsername: controller.text,
                      );

                      if (!mounted) return;

                      setState(() {});

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    } catch (e) {
                      setModalState(() {
                        errorMessage = e.toString().replaceAll(
                          'Exception: ',
                          '',
                        );
                      });
                    }
                  },
                  child: const Text(
                    'GUARDAR',
                    style: TextStyle(
                      color: Color(0xFF0D1B2A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }

  // =========================================================
  // TIENDA DE MUNICIÓN
  //
  // Se conserva porque JUGAR todavía depende de ella
  // cuando el jugador no tiene munición.
  //
  // Ya NO existe un botón de racha/munición arriba.
  // Ahora RECOMPENSAS utiliza esta funcionalidad.
  // =========================================================

  void _showAmmoStoreDialog() {
    _playClick();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setStoreState) {
            final user = _userService.currentUser;

            return AlertDialog(
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFFFB703), width: 2),
              ),
              title: const Text(
                '🎁 RECOMPENSAS',
                style: TextStyle(color: Color(0xFFFFB703)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.ondemand_video,
                      color: Colors.greenAccent,
                    ),
                    title: const Text(
                      'Ver anuncio (+20 balas)',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Hoy: ${user?.dailyAdsWatched ?? 0}/${UserService.maxDailyAds} vistos',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    onTap: () {
                      _playClick();

                      final success = _userService.claimAdAmmo();

                      if (success) {
                        setState(() {});
                        setStoreState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡+20 balas agregadas!'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Límite de anuncios diario alcanzado.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading: const Icon(Icons.payment, color: Colors.amber),
                    title: const Text(
                      'Paquete 100 balas',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      '\$0.99 USD - Sin límite',
                      style: TextStyle(color: Colors.white54),
                    ),
                    onTap: () {
                      _playClick();

                      _userService.addPurchasedAmmo(100);

                      setState(() {});
                      setStoreState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Compra exitosa! +100 balas'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _playClick();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'CERRAR',
                    style: TextStyle(color: Color(0xFFFFB703)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // CONFIGURACIÓN
  // =========================================================

  void _showSettingsDialog() {
    _playClick();

    final user = _userService.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setSettingsState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFFFB703), width: 2),
              ),
              title: const Text(
                '⚙️ CONFIGURACIÓN',
                style: TextStyle(color: Color(0xFFFFB703)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sensibilidad: ${user.sensitivity.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: user.sensitivity,
                    min: 0.5,
                    max: 2.0,
                    activeColor: const Color(0xFFFFB703),
                    onChanged: (v) {
                      setSettingsState(() => user.sensitivity = v);
                      setState(() {});
                    },
                  ),
                  Text(
                    'Música: ${(user.bgmVolume * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: user.bgmVolume,
                    activeColor: const Color(0xFFFFB703),
                    onChanged: (v) {
                      setSettingsState(() => user.bgmVolume = v);

                      _audioService.bgmVolume = v;

                      setState(() {});
                    },
                  ),
                  Text(
                    'Efectos de sonido: ${(user.sfxVolume * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: user.sfxVolume,
                    activeColor: const Color(0xFFFFB703),
                    onChanged: (v) {
                      setSettingsState(() => user.sfxVolume = v);

                      _audioService.sfxVolume = v;

                      setState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _playClick();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'ACEPTAR',
                    style: TextStyle(color: Color(0xFFFFB703)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // LOGROS
  //
  // Estructura inicial.
  // El sistema completo de desbloqueo y compartir se hará
  // posteriormente.
  // =========================================================

  void _showAchievementsDialog() {
    _playClick();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1B2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFFB703), width: 2),
          ),
          title: const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB703)),
              SizedBox(width: 10),
              Text(
                'LOGROS',
                style: TextStyle(
                  color: Color(0xFFFFB703),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.lock_open_rounded,
                  color: Colors.greenAccent,
                ),
                title: Text(
                  'Primer objetivo',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Disponible para completar',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              Divider(color: Colors.white24),
              ListTile(
                leading: Icon(Icons.lock_rounded, color: Colors.white38),
                title: Text(
                  'Cazador experto',
                  style: TextStyle(color: Colors.white54),
                ),
                subtitle: Text(
                  'Bloqueado',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playClick();
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CERRAR',
                style: TextStyle(
                  color: Color(0xFFFFB703),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // CONSTRUCCIÓN DEL MENÚ PRINCIPAL
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final user = _userService.currentUser;

    final sfxOn = (user?.sfxVolume ?? 0) > 0;

    final bgmOn = (user?.bgmVolume ?? 0) > 0;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/splash.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Fondo del menú

            // Partículas animadas
            const Positioned.fill(child: MenuParticles()),

            // =================================================
            // 1. PERFIL
            // =================================================
            Positioned(top: 12, left: 12, child: _buildProfileCard(user)),

            // =================================================
            // 2. LOGROS
            //
            // Sustituye al antiguo botón superior de racha.
            // =================================================
            Positioned(top: 12, right: 12, child: _buildAchievementButton()),

            // =================================================
            // 3. BOTONES PRINCIPALES
            //
            // REGISTRARSE | JUGAR | CONFIGURACIÓN
            // =================================================
            Positioned(
              left: 18,
              right: 18,
              bottom: 88,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // -------------------------------------------
                  // REGISTRARSE
                  // -------------------------------------------
                  Expanded(
                    flex: 10,
                    child: _buildMainMenuButton(
                      label: 'REGISTRARSE',
                      icon: Icons.person_add_alt_1_rounded,
                      baseColor: const Color(0xFF0878E8),
                      darkColor: const Color(0xFF064A9B),
                      iconSize: 30,
                      fontSize: 17,
                      onPressed: _showRegisterDialog,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // -------------------------------------------
                  // JUGAR
                  // -------------------------------------------
                  Expanded(
                    flex: 13,
                    child: _buildMainMenuButton(
                      label: 'JUGAR',
                      icon: Icons.play_arrow_rounded,
                      baseColor: const Color(0xFFFFB703),
                      darkColor: const Color(0xFFD66A00),
                      iconSize: 42,
                      fontSize: 25,
                      onPressed: () async {
                        _playClick();

                        // Se conserva exactamente
                        // la lógica existente:
                        // si no hay balas, abre la tienda.

                        if ((user?.ammoBalance ?? 0) <= 0) {
                          _showAmmoStoreDialog();
                        } else {
                          if (!mounted) return;

                          await widget.game.restartGame();

                          widget.game.overlays.remove('MainMenu');
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // -------------------------------------------
                  // CONFIGURACIÓN
                  // -------------------------------------------
                  Expanded(
                    flex: 11,
                    child: _buildMainMenuButton(
                      label: 'CONFIGURACIÓN',
                      icon: Icons.settings,
                      baseColor: const Color(0xFF62D61F),
                      darkColor: const Color(0xFF2D8A08),
                      iconSize: 30,
                      fontSize: 16,
                      onPressed: _showSettingsDialog,
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // 4. BARRA INFERIOR
            //
            // RECOMPENSAS | DIARIO | EFECTOS | MÚSICA
            //
            // LOGROS fue trasladado arriba.
            // =================================================
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  // -------------------------------------------
                  // RECOMPENSAS
                  //
                  // Conserva la funcionalidad de la tienda
                  // de munición existente.
                  // -------------------------------------------
                  Expanded(
                    child: _buildBottomMenuButton(
                      label: 'RECOMPENSAS',
                      icon: Icons.card_giftcard_rounded,
                      iconColor: const Color(0xFFFFB703),
                      onPressed: _showAmmoStoreDialog,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // -------------------------------------------
                  // DIARIO
                  // -------------------------------------------
                  Expanded(
                    child: _buildBottomMenuButton(
                      label: 'DIARIO',
                      icon: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFFFFE0B2),
                      onPressed: () {
                        _playClick();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'El diario estará disponible próximamente.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // -------------------------------------------
                  // EFECTOS
                  // -------------------------------------------
                  Expanded(
                    child: _buildBottomMenuButton(
                      label: 'EFECTOS',
                      icon: sfxOn
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      iconColor: const Color(0xFF19B5FE),
                      status: sfxOn ? 'ON' : 'OFF',
                      statusColor: sfxOn
                          ? const Color(0xFF7CFC00)
                          : Colors.redAccent,
                      onPressed: _toggleSfx,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // -------------------------------------------
                  // MÚSICA
                  // -------------------------------------------
                  Expanded(
                    child: _buildBottomMenuButton(
                      label: 'MÚSICA',
                      icon: bgmOn
                          ? Icons.music_note_rounded
                          : Icons.music_off_rounded,
                      iconColor: const Color(0xFFFFD21F),
                      status: bgmOn ? 'ON' : 'OFF',
                      statusColor: bgmOn
                          ? const Color(0xFF7CFC00)
                          : Colors.redAccent,
                      onPressed: _toggleBgm,
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
