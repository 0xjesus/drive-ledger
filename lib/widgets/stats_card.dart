// lib/widgets/stats_card.dart

import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class DLStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double progress;
  final bool showShimmer;
  final bool showGlow;
  final VoidCallback? onTap;

  const DLStatsCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.progress = -1,
    this.showShimmer = false,
    this.showGlow = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? DLColors.bgDarkCard;
    final Color icoColor = iconColor ?? Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: DLAnimations.medium,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(DLRadius.card),
        border: Border.all(color: DLColors.divider),
        boxShadow: showGlow ? DLShadows.glow(icoColor) : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DLRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(DLSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DLSpacing.sm),
                      decoration: BoxDecoration(
                        color: icoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DLRadius.small),
                      ),
                      child: Icon(
                        icon,
                        color: icoColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: DLSpacing.sm),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DLSpacing.md),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (progress >= 0) ...[
                  const SizedBox(height: DLSpacing.md),
                  _buildProgressBar(context, progress),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: DLColors.bgDarkElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: DLSpacing.xs),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}