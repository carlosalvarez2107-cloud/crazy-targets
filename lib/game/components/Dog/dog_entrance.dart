import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Componente de entrada/salida del perro (mascota narrativa).
///
/// Anima al perro cruzando la pantalla de derecha a izquierda mientras
/// se encoge (efecto de alejamiento). La duración visual real la marca
/// [_elapsed], que solo avanza una vez que el componente ya está montado
/// (es decir, despues de cargar el sprite). Por eso quien dispare esta
/// animacion NO debe usar un temporizador externo fijo para decidir
/// cuando remover el componente: debe esperar [onFinished].
class DogEntranceComponent extends SpriteAnimationComponent
    with HasGameReference<FlameGame> {
  // Anchor.bottomCenter: la posicion Y representa donde pisan las patas
  // del perro, no su centro. Asi, aunque el sprite se encoja durante el
  // recorrido, se mantiene "parado" sobre la misma linea de suelo en vez
  // de flotar hacia arriba a medida que se hace mas chico.
  DogEntranceComponent()
    : super(size: Vector2.all(512), anchor: Anchor.bottomCenter);

  double _elapsed = 0.0;
  bool _finished = false;

  late double _startX;
  late double _endX;
  late double _startY;

  static const double _startSize = 300.0;
  static const double _endSize = 120.0;

  /// Que tan abajo en pantalla "pisa" el perro (0.0 = borde superior,
  /// 1.0 = borde inferior). Los carriles de objetivos llegan hasta 0.70
  /// (ver target_spawner.dart), asi que lo dejamos bien por debajo de eso,
  /// casi pegado al borde inferior de la pantalla.
  static const double _groundYFactor = 0.94;

  /// Duracion total del recorrido. La animacion de sprites se reparte en
  /// partes iguales dentro de este mismo tiempo (ver stepTime en onLoad).
  static const double _duration = 2.2;

  final Completer<void> _entranceCompleter = Completer<void>();

  /// Se completa en el momento exacto en que el perro termino su
  /// recorrido en pantalla (ni antes ni despues). Quien dispare esta
  /// animacion debe esperar este future antes de remover el componente.
  Future<void> get onFinished => _entranceCompleter.future;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _startX = game.size.x + 150;
    _endX = -100;
    _startY = game.size.y * _groundYFactor;

    position = Vector2(_startX, _startY);

    final image = await game.images.load('dog_run.png');

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 12,
        stepTime: _duration / 12,
        textureSize: Vector2(512, 512),
        loop: false,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    final progress = (_elapsed / _duration).clamp(0.0, 1.0);

    position.x = _startX + ((_endX - _startX) * progress);

    final currentSize = _startSize + ((_endSize - _startSize) * progress);
    size = Vector2.all(currentSize);

    if (progress >= 1.0 && !_finished) {
      _finished = true;
      _entranceCompleter.complete();
    }
  }
}
