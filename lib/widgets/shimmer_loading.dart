// lib/widgets/shimmer_loading.dart

import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
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
    final Color baseColor = widget.baseColor ?? DLColors.bgDarkElevated;
    final Color highlightColor = widget.highlightColor ?? DLColors.shimmer;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(DLRadius.small),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const ShimmerList({
    Key? key,
    required this.itemCount,
    this.itemHeight = 80,
    this.padding = const EdgeInsets.all(DLSpacing.md),
    this.spacing = DLSpacing.md,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(
          itemCount,
              (index) => Column(
            children: [
              ShimmerLoading(
                width: double.infinity,
                height: itemHeight,
                borderRadius: BorderRadius.circular(DLRadius.card),
              ),
              if (index < itemCount - 1) SizedBox(height: spacing),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double itemHeight;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const ShimmerGrid({
    Key? key,
    required this.crossAxisCount,
    required this.itemCount,
    this.itemHeight = 100,
    this.spacing = DLSpacing.md,
    this.padding = const EdgeInsets.all(DLSpacing.md),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return ShimmerLoading(
            width: double.infinity,
            height: itemHeight,
            borderRadius: BorderRadius.circular(DLRadius.card),
          );
        },
      ),
    );
  }
}