// lib/widgets/dl_card.dart

import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class DLCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? borderColor;
  final double elevation;
  final VoidCallback? onTap;
  final bool isGlowing;
  final Gradient? gradient;
  final Color? glowColor;

  const DLCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.elevation = 0,
    this.onTap,
    this.isGlowing = false,
    this.gradient,
    this.glowColor,
  }) : super(key: key);

  @override
  State<DLCard> createState() => _DLCardState();
}

class _DLCardState extends State<DLCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color cardColor = widget.color ?? theme.cardTheme.color ?? DLColors.bgDarkCard;
    final Color borderColor = widget.borderColor ?? DLColors.cardBorder;
    final BorderRadius borderRadius = widget.borderRadius ?? BorderRadius.circular(DLRadius.card);
    final EdgeInsetsGeometry padding = widget.padding ?? const EdgeInsets.all(DLSpacing.md);
    final Color glowColor = widget.glowColor ?? theme.colorScheme.primary.withOpacity(0.5);

    final BoxDecoration decoration = BoxDecoration(
      color: widget.gradient != null ? null : cardColor,
      gradient: widget.gradient,
      borderRadius: borderRadius,
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        if (widget.isGlowing)
          BoxShadow(
            color: glowColor,
            blurRadius: 16,
            spreadRadius: -4,
          )
        else if (widget.elevation > 0)
          BoxShadow(
            color: Colors.black.withOpacity(0.1 * widget.elevation / 2),
            blurRadius: 8 * widget.elevation / 2,
            offset: Offset(0, 2 * widget.elevation / 2),
          ),
      ],
    );

    Widget cardContent = Container(
      margin: widget.margin,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            splashColor: widget.onTap != null ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: borderRadius,
            child: Padding(
              padding: padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.onTap == null) {
      return cardContent;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: cardContent,
          );
        },
      ),
    );
  }
}