// lib/widgets/dl_animated_card.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/theme_constants.dart';

class DLAnimatedCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double elevation;
  final Color? color;
  final Color? borderColor;
  final bool isShimmerActive;
  final bool isGlowActive;
  final Color? glowColor;
  final VoidCallback? onTap;
  final bool isInteractive;
  final Gradient? gradient;

  const DLAnimatedCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(DLSpacing.md),
    this.borderRadius,
    this.elevation = 0,
    this.color,
    this.borderColor,
    this.isShimmerActive = false,
    this.isGlowActive = false,
    this.glowColor,
    this.onTap,
    this.isInteractive = true,
    this.gradient,
  }) : super(key: key);

  @override
  State<DLAnimatedCard> createState() => _DLAnimatedCardState();
}

class _DLAnimatedCardState extends State<DLAnimatedCard> with SingleTickerProviderStateMixin {
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    if (widget.isInteractive && widget.onTap != null) {
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
    final BorderRadius borderRadius = widget.borderRadius ?? BorderRadius.circular(DLRadius.card);
    final Color cardColor = widget.color ?? Theme.of(context).cardTheme.color ?? DLColors.bgDarkCard;
    final Color borderColor = widget.borderColor ?? DLColors.cardBorder;
    final Color glowColor = widget.glowColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.5);

    Widget cardWidget = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: widget.gradient,
        color: widget.gradient == null ? cardColor : null,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
        boxShadow: widget.isGlowActive ? [
          BoxShadow(
            color: glowColor,
            blurRadius: 16,
            spreadRadius: -4,
          )
        ] : (widget.elevation > 0 ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2 * widget.elevation / 10),
            blurRadius: 12 * widget.elevation / 10,
            offset: Offset(0, 4 * widget.elevation / 10),
          )
        ] : []),
      ),
      child: widget.isShimmerActive
          ? _ShimmerEffect(child: widget.child)
          : widget.child,
    );

    if (widget.onTap == null || !widget.isInteractive) {
      return cardWidget;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: cardWidget,
          );
        },
      ),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  final Widget child;

  const _ShimmerEffect({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            DLColors.bgDarkCard,
            DLColors.bgDarkCard.withOpacity(0.5),
            DLColors.bgDarkCard,
          ],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlidingGradientTransform(
            slidePercent: _controller.value,
          ),
        ).createShader(bounds);
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent - 0.5) * 2, 0, 0);
  }
}