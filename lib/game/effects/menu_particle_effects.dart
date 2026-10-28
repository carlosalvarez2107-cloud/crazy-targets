import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Capa de efectos animados para el menú principal.
///
/// Contiene cuatro tipos de efectos:
/// 1. Destellos
/// 2. Estrellas
/// 3. Partículas flotantes
/// 4. Estrellas fugaces
///
/// No utiliza imágenes externas. Todo se dibuja mediante CustomPainter.
class MenuParticles extends StatefulWidget {
  const MenuParticles({super.key, this.density = 1.0});

  /// Permite aumentar o disminuir la cantidad general de partículas.
  final double density;

  @override
  State<MenuParticles> createState() => _MenuParticlesState();
}

class _MenuParticlesState extends State<MenuParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_MenuParticle> _particles;
  late final List<_ShootingStar> _shootingStars;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = _createParticles();
    _shootingStars = _createShootingStars();
  }

  List<_MenuParticle> _createParticles() {
    final random = math.Random(2026);

    final count = (30 * widget.density).round().clamp(16, 45);

    final particles = <_MenuParticle>[];

    for (int i = 0; i < count; i++) {
      final double x;
      final double y;

      /*
       * Distribuimos las partículas principalmente en los laterales
       * y zonas libres del menú.
       *
       * Evitamos llenar el centro porque allí están:
       * - CRAZY TARGETS
       * - el pato principal
       * - los botones principales
       */

      final bool leftSide = random.nextBool();

      if (leftSide) {
        x = random.nextDouble() * 0.27;
      } else {
        x = 0.73 + random.nextDouble() * 0.27;
      }

      y = 0.05 + random.nextDouble() * 0.72;

      final double size = 1.0 + random.nextDouble() * 2.8;

      final double speed = 0.15 + random.nextDouble() * 0.45;

      final double phase = random.nextDouble();

      final double opacity = 0.25 + random.nextDouble() * 0.55;

      final _ParticleType type;

      final int typeValue = random.nextInt(3);

      switch (typeValue) {
        case 0:
          type = _ParticleType.sparkle;
          break;
        case 1:
          type = _ParticleType.star;
          break;
        default:
          type = _ParticleType.floating;
          break;
      }

      particles.add(
        _MenuParticle(
          x: x,
          y: y,
          size: size,
          speed: speed,
          phase: phase,
          opacity: opacity,
          type: type,
        ),
      );
    }

    return particles;
  }

  List<_ShootingStar> _createShootingStars() {
    return const [
      _ShootingStar(
        startX: 0.08,
        startY: 0.17,
        directionX: 0.16,
        directionY: 0.10,
        delay: 0.08,
        duration: 0.18,
      ),
      _ShootingStar(
        startX: 0.84,
        startY: 0.12,
        directionX: -0.13,
        directionY: 0.09,
        delay: 0.56,
        duration: 0.16,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: SizedBox.expand(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _MenuParticlesPainter(
                  progress: _controller.value,
                  particles: _particles,
                  shootingStars: _shootingStars,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

enum _ParticleType { sparkle, star, floating }

class _MenuParticle {
  const _MenuParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
    required this.type,
  });

  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final double opacity;
  final _ParticleType type;
}

class _ShootingStar {
  const _ShootingStar({
    required this.startX,
    required this.startY,
    required this.directionX,
    required this.directionY,
    required this.delay,
    required this.duration,
  });

  final double startX;
  final double startY;
  final double directionX;
  final double directionY;
  final double delay;
  final double duration;
}

class _MenuParticlesPainter extends CustomPainter {
  _MenuParticlesPainter({
    required this.progress,
    required this.particles,
    required this.shootingStars,
  });

  final double progress;
  final List<_MenuParticle> particles;
  final List<_ShootingStar> shootingStars;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    _drawParticles(canvas, size);
    _drawShootingStars(canvas, size);
  }

  void _drawParticles(Canvas canvas, Size size) {
    for (final particle in particles) {
      final double cycle = (progress * particle.speed + particle.phase) % 1.0;

      /*
       * Movimiento vertical extremadamente suave.
       * La amplitud es pequeña para que el fondo no parezca una
       * pantalla llena de objetos flotando.
       */
      final double verticalMovement = math.sin(cycle * math.pi * 2) * 0.012;

      /*
       * Parpadeo individual.
       */
      final double twinkle =
          0.55 + math.sin((cycle + particle.phase) * math.pi * 2) * 0.45;

      final double x = particle.x * size.width;

      final double y = (particle.y + verticalMovement) * size.height;

      final double opacity = (particle.opacity * twinkle).clamp(0.05, 0.90);

      switch (particle.type) {
        case _ParticleType.sparkle:
          _drawSparkle(canvas, Offset(x, y), particle.size, opacity);
          break;

        case _ParticleType.star:
          _drawStar(canvas, Offset(x, y), particle.size, opacity);
          break;

        case _ParticleType.floating:
          _drawFloatingParticle(canvas, Offset(x, y), particle.size, opacity);
          break;
      }
    }
  }

  void _drawSparkle(
    Canvas canvas,
    Offset position,
    double size,
    double opacity,
  ) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    /*
     * Pequeña cruz luminosa.
     */
    canvas.drawCircle(position, size * 0.45, paint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.75)
      ..strokeWidth = size * 0.55
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      position.translate(-size * 2.0, 0),
      position.translate(size * 2.0, 0),
      linePaint,
    );

    canvas.drawLine(
      position.translate(0, -size * 2.0),
      position.translate(0, size * 2.0),
      linePaint,
    );
  }

  void _drawStar(Canvas canvas, Offset position, double size, double opacity) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path();

    /*
     * Estrella de cuatro puntas.
     */
    path.moveTo(position.dx, position.dy - size * 2.4);

    path.lineTo(position.dx + size * 0.65, position.dy - size * 0.65);

    path.lineTo(position.dx + size * 2.4, position.dy);

    path.lineTo(position.dx + size * 0.65, position.dy + size * 0.65);

    path.lineTo(position.dx, position.dy + size * 2.4);

    path.lineTo(position.dx - size * 0.65, position.dy + size * 0.65);

    path.lineTo(position.dx - size * 2.4, position.dy);

    path.lineTo(position.dx - size * 0.65, position.dy - size * 0.65);

    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawFloatingParticle(
    Canvas canvas,
    Offset position,
    double size,
    double opacity,
  ) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.55)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, size * 0.65, paint);
  }

  void _drawShootingStars(Canvas canvas, Size size) {
    for (final shootingStar in shootingStars) {
      final double localProgress = (progress - shootingStar.delay) % 1.0;

      /*
       * Solo mostramos la estrella durante una pequeña parte
       * del ciclo. El resto del tiempo permanece invisible.
       */
      if (localProgress > shootingStar.duration) {
        continue;
      }

      final double normalized = localProgress / shootingStar.duration;

      /*
       * Entrada y salida suaves.
       */
      final double fade = math.sin(normalized * math.pi);

      final double currentX =
          shootingStar.startX + shootingStar.directionX * normalized;

      final double currentY =
          shootingStar.startY + shootingStar.directionY * normalized;

      final Offset head = Offset(currentX * size.width, currentY * size.height);

      final Offset tail = Offset(
        (currentX - shootingStar.directionX * 0.35) * size.width,
        (currentY - shootingStar.directionY * 0.35) * size.height,
      );

      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: fade * 0.75)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(tail, head, linePaint);

      final headPaint = Paint()
        ..color = Colors.white.withValues(alpha: fade)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(head, 2.0, headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MenuParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
