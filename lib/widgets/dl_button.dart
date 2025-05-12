// lib/widgets/dl_button.dart

import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class DLButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double height;
  final bool isLoading;
  final bool isOutlined;
  final bool isGradient;
  final Gradient? gradient;
  final bool isDisabled;
  final double borderRadius;

  const DLButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height = 48.0,
    this.isLoading = false,
    this.isOutlined = false,
    this.isGradient = false,
    this.gradient,
    this.isDisabled = false,
    this.borderRadius = DLRadius.button,
  }) : super(key: key);

  @override
  State<DLButton> createState() => _DLButtonState();
}

class _DLButtonState extends State<DLButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DLAnimations.quick,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isEnabled = !widget.isDisabled && !widget.isLoading;

    // Determine colors based on props and theme
    final Color backgroundColor = widget.isDisabled
        ? DLColors.bgDarkElevated
        : (widget.backgroundColor ?? theme.colorScheme.primary);

    final Color textColor = widget.isDisabled
        ? DLColors.textDisabled
        : (widget.textColor ?? (widget.isOutlined ? backgroundColor : Colors.white));

    final Color borderColor = widget.borderColor ?? backgroundColor;

    // Create gradient if needed
    final Gradient gradient = widget.gradient ??
        (widget.isGradient ? DLGradients.primaryGradient : LinearGradient(
          colors: [backgroundColor, backgroundColor],
        ));

    return GestureDetector(
      onTapDown: (_) {
        if (isEnabled) {
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (isEnabled) {
          _controller.reverse();
        }
      },
      onTapCancel: () {
        if (isEnabled) {
          _controller.reverse();
        }
      },
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isEnabled ? _scaleAnimation.value : 1.0,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.isOutlined ? null : (widget.isGradient ? gradient : null),
                color: widget.isOutlined || widget.isGradient ? null : backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: widget.isOutlined
                    ? Border.all(color: borderColor, width: 1.5)
                    : null,
                boxShadow: isEnabled && !widget.isOutlined
                    ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: textColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}