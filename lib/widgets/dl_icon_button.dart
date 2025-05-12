// lib/widgets/dl_icon_button.dart

import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class DLIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final bool isSelected;
  final bool hasBadge;
  final String? badgeText;
  final bool shouldPulse;

  const DLIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 24,
    this.isSelected = false,
    this.hasBadge = false,
    this.badgeText,
    this.shouldPulse = false,
  }) : super(key: key);

  @override
  State<DLIconButton> createState() => _DLIconButtonState();
}

class _DLIconButtonState extends State<DLIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.8),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.shouldPulse) {
      _controller.repeat(period: const Duration(seconds: 2));
    }
  }

  @override
  void didUpdateWidget(DLIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPulse != oldWidget.shouldPulse) {
      if (widget.shouldPulse) {
        _controller.repeat(period: const Duration(seconds: 2));
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.color ??
        (widget.isSelected ? Theme.of(context).colorScheme.primary : DLColors.textSecondary);

    final Color bgColor = widget.backgroundColor ??
        (widget.isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.shouldPulse ? _scaleAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      if (!widget.shouldPulse && !_controller.isAnimating) {
                        _controller.forward().then((_) => _controller.reset());
                      }
                      widget.onPressed();
                    },
                    customBorder: const CircleBorder(),
                    splashColor: iconColor.withOpacity(0.1),
                    highlightColor: iconColor.withOpacity(0.05),
                    child: Container(
                      padding: const EdgeInsets.all(DLSpacing.sm),
                      child: Icon(
                        widget.icon,
                        color: iconColor,
                        size: widget.size,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.hasBadge)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: widget.badgeText != null ?
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2) :
              const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: DLColors.error,
                shape: widget.badgeText != null ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: widget.badgeText != null ? BorderRadius.circular(10) : null,
                border: Border.all(color: DLColors.bgDark, width: 1.5),
              ),
              child: widget.badgeText != null ?
              Text(
                widget.badgeText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ) :
              const SizedBox(width: 0, height: 0),
            ),
          ),
      ],
    );
  }
}