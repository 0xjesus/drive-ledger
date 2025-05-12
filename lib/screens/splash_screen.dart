// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:drive_ledger/routes/routes.dart';
import 'package:drive_ledger/widgets/animated_background.dart';
import 'package:drive_ledger/theme/theme_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    // Navigate to the next screen after animation completes
    Timer(const Duration(milliseconds: 3500), () {
      Get.offAllNamed(Routes.WELCOME);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        showGrid: true,
        showParticles: true,
        primaryColor: DLColors.primary,
        secondaryColor: DLColors.secondary,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeInAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with glow
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: DLColors.primary.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: DLColors.secondary.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: _buildPulsatingLogo(),
                        ),
                        const SizedBox(height: DLSpacing.lg),

                        // App Name
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [
                                DLColors.primary,
                                DLColors.secondary,
                                DLColors.accent,
                              ],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'DRIVE-LEDGER',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: DLColors.primary.withOpacity(0.7),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: DLSpacing.sm),

                        // Tagline
                        Text(
                          'Decentralized Vehicle Data Platform',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: DLSpacing.xl),

                        // Loading indicator
                        _buildLoadingIndicator(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPulsatingLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(DLSpacing.md),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DLColors.bgDarkCard,
              border: Border.all(
                color: DLColors.primary.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 80,
              height: 80,
            ),
          ),
        );
      },
      child: const SizedBox(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating outer circle
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 2 * 3.14159),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(DLColors.primary),
                      strokeWidth: 3,
                    ),
                  );
                },
              ),
              // Counter-rotating inner circle
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: -2 * 3.14159),
                duration: const Duration(seconds: 3),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(DLColors.secondary),
                      strokeWidth: 2,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: DLSpacing.md),
        // Loading text with changing dots
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: 3),
          duration: const Duration(milliseconds: 900),
          builder: (context, value, child) {
            String dots = '';
            for (int i = 0; i < value; i++) {
              dots += '.';
            }
            return Text(
              'Initializing$dots',
              style: const TextStyle(
                color: DLColors.textSecondary,
                fontSize: 14,
              ),
            );
          },
        ),
      ],
    );
  }
}