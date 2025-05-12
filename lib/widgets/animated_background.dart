// lib/widgets/animated_background.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool showGrid;
  final bool showParticles;

  const AnimatedBackground({
    Key? key,
    required this.child,
    this.primaryColor,
    this.secondaryColor,
    this.showGrid = true,
    this.showParticles = true,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _gridController;
  late AnimationController _particlesController;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Grid animation
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    // Particles animation
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.showGrid) {
      _gridController.repeat();
    }

    if (widget.showParticles) {
      _generateParticles();
      _particlesController.repeat();
    }
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        position: Offset(
          _random.nextDouble() * 1000,
          _random.nextDouble() * 1000,
        ),
        speed: 0.5 + _random.nextDouble() * 1.5,
        radius: 1 + _random.nextDouble() * 2,
        color: _random.nextBool()
            ? (widget.primaryColor ?? DLColors.primary).withOpacity(0.3 + _random.nextDouble() * 0.3)
            : (widget.secondaryColor ?? DLColors.secondary).withOpacity(0.2 + _random.nextDouble() * 0.2),
      ));
    }
  }

  @override
  void dispose() {
    _gridController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(color: DLColors.bgDark),

        // Animated grid
        if (widget.showGrid)
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: GridPainter(
                  primaryColor: widget.primaryColor ?? DLColors.primary,
                  secondaryColor: widget.secondaryColor ?? DLColors.secondary,
                  progress: _gridController.value,
                ),
              );
            },
          ),

        // Animated particles
        if (widget.showParticles)
          AnimatedBuilder(
            animation: _particlesController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ParticlesPainter(
                  particles: _particles,
                  progress: _particlesController.value,
                ),
              );
            },
          ),

        // Main content
        widget.child,
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double progress;

  GridPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = primaryColor.withOpacity(0.15)
      ..strokeWidth = 1;

    final Paint glowPaint = Paint()
      ..color = secondaryColor.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Grid spacing
    const double spacing = 30;
    const double movedSpacing = 70;

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      final double adjustedY = y + (movedSpacing * sin(progress * 2 * pi + y / 100));
      canvas.drawLine(Offset(0, adjustedY), Offset(size.width, adjustedY), linePaint);
    }

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      final double adjustedX = x + (movedSpacing * cos(progress * 2 * pi + x / 100));
      canvas.drawLine(Offset(adjustedX, 0), Offset(adjustedX, size.height), linePaint);
    }

    // Draw larger circles that pulse
    for (int i = 0; i < 5; i++) {
      final double x = (size.width / 6) * (i + 1) + (20 * sin(progress * 2 * pi + i));
      final double y = (size.height / 2) + (50 * cos(progress * 2 * pi + i * 0.7));
      final double radius = 70 + 20 * sin(progress * 2 * pi * 2 + i);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Particle {
  Offset position;
  final double speed;
  final double radius;
  final Color color;

  Particle({
    required this.position,
    required this.speed,
    required this.radius,
    required this.color,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlesPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Update position
      particle.position = Offset(
        (particle.position.dx + particle.speed) % size.width,
        particle.position.dy,
      );

      final Paint particlePaint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      // Draw the particle with subtle animation
      final double animatedRadius = particle.radius * (0.8 + 0.4 * sin(progress * 2 * pi * particle.speed));

      canvas.drawCircle(
        particle.position,
        animatedRadius,
        particlePaint,
      );

      // Connect nearby particles with faint lines
      for (final other in particles) {
        final double distance = (particle.position - other.position).distance;
        if (distance < 100 && distance > 0) {
          canvas.drawLine(
            particle.position,
            other.position,
            Paint()
              ..color = particle.color.withOpacity(0.1 * (1 - distance / 100))
              ..strokeWidth = 0.5,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}