class UserModel {
  final String uid;
  final String email;
  String username;
  String? photoUrl;
  int globalScore;
  int ammoBalance;
  int dailyAdsWatched;
  DateTime? lastAdWatchDate;

  // Configuraciones de juego y audio
  double sensitivity;
  double bgmVolume;
  double sfxVolume;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.photoUrl,
    this.globalScore = 0,
    this.ammoBalance = 50, // Munición inicial de regalo
    this.dailyAdsWatched = 0,
    this.lastAdWatchDate,
    this.sensitivity = 1.0,
    this.bgmVolume = 0.5,
    this.sfxVolume = 1.0,
  });

  /// Obtiene la letra inicial en mayúscula para el avatar por defecto
  String get initialLetter {
    if (username.isNotEmpty) {
      return username[0].toUpperCase();
    } else if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'P'; // 'P' de Player por defecto
  }

  /// Convierte el objeto a un Map para guardar en Base de Datos
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'globalScore': globalScore,
      'ammoBalance': ammoBalance,
      'dailyAdsWatched': dailyAdsWatched,
      'lastAdWatchDate': lastAdWatchDate?.toIso8601String(),
      'sensitivity': sensitivity,
      'bgmVolume': bgmVolume,
      'sfxVolume': sfxVolume,
    };
  }

  /// Crea un objeto UserModel a partir de datos de Base de Datos
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? 'Jugador',
      photoUrl: map['photoUrl'],
      globalScore: map['globalScore'] ?? 0,
      ammoBalance: map['ammoBalance'] ?? 50,
      dailyAdsWatched: map['dailyAdsWatched'] ?? 0,
      lastAdWatchDate: map['lastAdWatchDate'] != null
          ? DateTime.tryParse(map['lastAdWatchDate'])
          : null,
      sensitivity: (map['sensitivity'] ?? 1.0).toDouble(),
      bgmVolume: (map['bgmVolume'] ?? 0.5).toDouble(),
      sfxVolume: (map['sfxVolume'] ?? 1.0).toDouble(),
    );
  }
}
