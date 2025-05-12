// lib/widgets/data_stream_card.dart
import 'package:flutter/material.dart';
import 'package:drive_ledger/widgets/dl_card.dart';
import 'dart:math' as math;

/// A specialized card that displays vehicle data streams with animations
class DataStreamCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final bool isActive;
  final VoidCallback? onTap;

  const DataStreamCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    this.subtitle,
    required this.icon,
    this.color,
    this.isActive = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<DataStreamCard> createState() => _DataStreamCardState();
}

class _DataStreamCardState extends State<DataStreamCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color dataColor = widget.color ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DLCard(
        onTap: widget.onTap,
        // Add glow effect for active streams
        glowColor: widget.isActive ? dataColor.withOpacity(0.2) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.isActive
                        ? theme.textTheme.titleMedium?.color
                        : theme.textTheme.titleMedium?.color?.withOpacity(0.5),
                  ),
                ),
                AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.isActive
                              ? dataColor
                              .withOpacity(0.1 + _pulseAnimation.value * 0.1)
                              : theme.colorScheme.onSurface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 20,
                          color: widget.isActive
                              ? dataColor
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      );
                    }
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    widget.value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.isActive
                          ? dataColor
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  widget.unit,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: widget.isActive
                        ? dataColor.withOpacity(0.8)
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(
                    widget.isActive ? 0.7 : 0.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (widget.isActive) _buildDataStreamIndicator(dataColor, theme),
            // Add "Live" indicator for active streams
            if (widget.isActive) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Live',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataStreamIndicator(Color color, ThemeData theme) {
    return SizedBox(
      height: 4,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, 4),
            painter: DataStreamPainter(
              progress: _animationController.value,
              color: color,
              backgroundColor: theme.colorScheme.surface,
            ),
          );
        },
      ),
    );
  }
}

class DataStreamPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  DataStreamPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(2),
      ),
      backgroundPaint,
    );

    // Calculate wave
    final path = Path();
    final amplitude = size.height / 2;
    final frequency = 6.0;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final waveProgress = (x / size.width) + progress;
      final y = size.height / 2 +
          math.sin(waveProgress * math.pi * frequency) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant DataStreamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}