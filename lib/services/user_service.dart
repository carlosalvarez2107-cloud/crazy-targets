import 'dart:async';
import '../models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Usuario cargado en la sesión actual
  UserModel? currentUser;

  // Base de datos simulada de nombres de usuario registrados (para prueba de unicidad)
  final Set<String> _registeredUsernames = {
    'carlos_123',
    'pro_shooter',
    'admin',
    'crazy_duck',
  };

  /// Límite diario de paquetes de munición por ver anuncios
  static const int maxDailyAds = 5;
  static const int ammoPerAd = 20;

  /// 1. Registro / Login con Email
  Future<UserModel> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula red

    // Extrae un username base por defecto a partir del correo
    String defaultUsername = email.split('@').first;
    defaultUsername = _generateUniqueDefaultUsername(defaultUsername);

    currentUser = UserModel(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      username: defaultUsername,
      ammoBalance: 50, // Regalo de bienvenida
    );

    _registeredUsernames.add(currentUser!.username.toLowerCase());
    return currentUser!;
  }

  /// 2. Login con Facebook (Acepta datos reales enviados desde el SDK o Login de Facebook)
  Future<UserModel> loginWithFacebook({
    String? email,
    String? name,
    String? photoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final String userEmail = email ?? 'facebook_user@fb.com';
    final String baseName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : 'fb_player';

    final String defaultUsername = _generateUniqueDefaultUsername(baseName);

    currentUser = UserModel(
      uid: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      email: userEmail,
      username: defaultUsername,
      photoUrl: photoUrl, // Recibe la foto de perfil de Facebook si existe
      ammoBalance: 50,
    );

    _registeredUsernames.add(currentUser!.username.toLowerCase());
    return currentUser!;
  }

  /// 3. Actualización de Perfil con VALIDACIÓN DE NOMBRE ÚNICO y FOTO
  Future<void> updateProfile({
    required String newUsername,
    String? newPhotoUrl,
  }) async {
    if (currentUser == null) return;

    final trimmedUsername = newUsername.trim();
    final lowerNewName = trimmedUsername.toLowerCase();
    final lowerCurrentName = currentUser!.username.toLowerCase();

    // Si cambió el nombre, validamos si ya existe
    if (lowerNewName != lowerCurrentName) {
      if (_registeredUsernames.contains(lowerNewName)) {
        throw Exception(
          'El nombre de usuario "$trimmedUsername" ya está en uso. Por favor elige otro.',
        );
      }

      // Si es válido, liberamos el viejo y registramos el nuevo
      _registeredUsernames.remove(lowerCurrentName);
      _registeredUsernames.add(lowerNewName);
      currentUser!.username = trimmedUsername;
    }

    // Actualiza la foto de perfil (Ruta de archivo local o URL remota)
    if (newPhotoUrl != null) {
      currentUser!.photoUrl = newPhotoUrl;
    }
  }

  /// 4. Reclamar Munición por Anuncios (Con Límite Diario)
  bool claimAdAmmo() {
    if (currentUser == null) return false;

    final now = DateTime.now();
    final lastWatch = currentUser!.lastAdWatchDate;

    // Reiniciar contador si es un nuevo día
    if (lastWatch == null ||
        now.day != lastWatch.day ||
        now.month != lastWatch.month ||
        now.year != lastWatch.year) {
      currentUser!.dailyAdsWatched = 0;
    }

    // Validar si superó el límite diario
    if (currentUser!.dailyAdsWatched >= maxDailyAds) {
      return false; // Límite alcanzado
    }

    // Acreditar munición
    currentUser!.dailyAdsWatched += 1;
    currentUser!.lastAdWatchDate = now;
    currentUser!.ammoBalance += ammoPerAd;
    return true;
  }

  /// 5. Comprar Munición por Google Pay (Sin Límite)
  void addPurchasedAmmo(int ammoAmount) {
    if (currentUser == null) return;
    currentUser!.ammoBalance += ammoAmount;
  }

  /// Helper: Genera un nombre por defecto no repetido si el inicial ya existe
  String _generateUniqueDefaultUsername(String base) {
    String candidate = base;
    int counter = 1;
    while (_registeredUsernames.contains(candidate.toLowerCase())) {
      candidate = '$base$counter';
      counter++;
    }
    return candidate;
  }
}
