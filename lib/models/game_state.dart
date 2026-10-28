class GameState {
  final String userId;
  int currentLevel;
  int levelScore;
  int globalScore;
  int lives;

  // 🎯 NUEVAS VARIABLES DE MUNICIÓN
  int levelAmmo;
  int maxLevelAmmo;
  int extraAmmo;

  GameState({
    this.userId = 'player_01',
    this.currentLevel = 1,
    this.levelScore = 0,
    this.globalScore = 0,
    this.lives = 3,
    this.levelAmmo = 0,
    this.maxLevelAmmo = 0,
    this.extraAmmo = 0,
  }) {
    // Inicializa la munición del nivel al instanciar el estado
    initLevelAmmo();
  }

  /// Meta de puntos para pasar el nivel actual (Nivel 1 = 12000, Nivel 2 = 27000, etc.)
  int get targetScoreForCurrentLevel => 12000 + ((currentLevel - 1) * 15000);

  /// Suma total acumulada para mostrar o enviar al backend
  int get totalGlobalScore => globalScore + levelScore;

  // -----------------------------------------------------------------
  // 🔫 LÓGICA Y CÁLCULOS DE MUNICIÓN
  // -----------------------------------------------------------------

  /// Calcula dinámicamente las balas del nivel (500 pts por pato + 25% de margen)
  void initLevelAmmo() {
    final int minShots = (targetScoreForCurrentLevel / 500).ceil();
    final int margin = (minShots * 0.25).ceil();

    maxLevelAmmo = minShots + margin; // Nivel 1 = 30 balas
    levelAmmo = maxLevelAmmo;
  }

  /// Indica si al jugador le queda alguna bala (de nivel o comprada)
  bool get hasAmmo => (levelAmmo + extraAmmo) > 0;

  /// Consume 1 bala priorizando las de nivel. Retorna true si pudo disparar.
  bool consumeAmmo() {
    if (levelAmmo > 0) {
      levelAmmo--;
      return true;
    } else if (extraAmmo > 0) {
      extraAmmo--;
      return true;
    }
    return false; // Sin munición disponible
  }

  /// Reinicia el nivel actual manteniendo vidas a 3 y restaurando las balas del nivel
  void resetCurrentLevel() {
    levelScore = 0;
    lives = 3;
    initLevelAmmo();
  }

  // -----------------------------------------------------------------
  // 📊 MÉTODOS DE FLUJO EXISTENTES
  // -----------------------------------------------------------------

  /// Suma puntos al nivel actual evitando números negativos
  void addPoints(int points) {
    levelScore += points;
    if (levelScore < 0) {
      levelScore = 0;
    }
  }

  /// Registra el paso de nivel y acumula el puntaje en el global
  void completeCurrentLevel() {
    globalScore += levelScore;
    levelScore = 0;
    currentLevel++;
    initLevelAmmo(); // Recalcula las balas para la meta del nuevo nivel
  }

  /// Convierte el estado a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_level': currentLevel,
      'level_score': levelScore,
      'global_score': totalGlobalScore,
      'level_ammo': levelAmmo,
      'extra_ammo': extraAmmo,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
