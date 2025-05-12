// lib/widgets/dl_animated_button.dart

import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class DLAnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final bool isLoading;
  final bool isGradient;
  final Gradient? gradient;
  final bool isOutlined;
  final double borderRadius;

  const DLAnimatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48.0,
    this.isLoading = false,
    this.isGradient = false,
    this.gradient,
    this.isOutlined = false,
    this.borderRadius = DLRadius.button,
  }) : super(key: key);

  @override
  State<DLAnimatedButton> createState() => _DLAnimatedButtonState();
}

class _DLAnimatedButtonState extends State<DLAnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

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
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      _controller.forward();
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.backgroundColor ??
        (widget.isOutlined ? Colors.transparent : Theme.of(context).colorScheme.primary);

    final Color textColor = widget.textColor ??
        (widget.isOutlined ? Theme.of(context).colorScheme.primary : Colors.white);

    final Gradient gradient = widget.gradient ??
        (widget.isGradient ? DLGradients.primaryGradient :
        LinearGradient(colors: [backgroundColor, backgroundColor]));

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.isOutlined ? null : (widget.isGradient ? gradient : null),
                color: widget.isOutlined || widget.isGradient ? null : backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: widget.isOutlined ? Border.all(
                  color: textColor,
                  width: 1.5,
                ) : null,
                boxShadow: _isPressed || widget.isLoading ? [] : [
                  BoxShadow(
                    color: (widget.isGradient ? gradient.colors.first : backgroundColor)
                        .withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                        size: 20,
                      ),
                      const SizedBox(width: DLSpacing.sm),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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