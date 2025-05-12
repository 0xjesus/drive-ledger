// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../routes/routes.dart';
import '../controllers/phantom_wallet_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final walletController = Get.find<PhantomWalletController>();
  late AnimationController _animController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background with animated particles
          CustomPaint(
            painter: BackgroundParticlesPainter(
              primaryColor: theme.colorScheme.primary,
              secondaryColor: theme.colorScheme.secondary,
            ),
            size: Size.infinite,
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 1),

                  // App logo and name
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeInAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - _fadeInAnimation.value) * 30),
                          child: Center(
                            child: Column(
                              children: [
                                _buildAnimatedLogo(theme),
                                const SizedBox(height: 24),
                                ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary,
                                        Colors.purple,
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: const Text(
                                    'DRIVE-LEDGER',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 1),

                  // Welcome message
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeInAnimation.value,
                        child: Transform.translate(
                          offset: Offset(_slideAnimation.value, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to the Future of',
                                style: theme.textTheme.headlineSmall,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Vehicle ',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.secondary,
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: Text(
                                      'Data Ownership',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Feature bullets with staggered animation
                  _buildAnimatedFeature(
                    index: 0,
                    icon: Icons.data_usage_rounded,
                    title: 'Monetize Your Vehicle Data',
                    description: 'Share and earn rewards for the data your car generates',
                  ),

                  _buildAnimatedFeature(
                    index: 1,
                    icon: Icons.security_rounded,
                    title: 'Full Control & Privacy',
                    description: 'You decide what data to share and with whom',
                  ),

                  _buildAnimatedFeature(
                    index: 2,
                    icon: Icons.token_rounded,
                    title: 'Earn DRVL Tokens',
                    description: 'Get rewarded in our native cryptocurrency',
                  ),

                  const Spacer(flex: 1),

                  // Connect wallet button with animation
                  AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeInAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - _fadeInAnimation.value) * 30),
                            child: Obx(() => _buildConnectButton(theme)),
                          ),
                        );
                      }
                  ),

                  // Alternative options
                  if (!walletController.isConnected.value)
                    Center(
                      child: TextButton(
                        onPressed: () => Get.toNamed(Routes.HOME),
                        child: Text(
                          'Explore in Demo Mode',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular glow
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.7),
                        theme.colorScheme.primary.withOpacity(0.0),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),

                // Logo image
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.scaffoldBackgroundColor,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback icon if logo image is not available
                        return Icon(
                          Icons.directions_car,
                          size: 40,
                          color: theme.colorScheme.primary,
                        );
                      },
                    ),
                  ),
                ),

                // Rotating outer ring
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 2 * math.pi),
                  duration: const Duration(seconds: 30),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: CustomPaint(
                          painter: DashedCirclePainter(
                            color: theme.colorScheme.primary.withOpacity(0.7),
                            dashCount: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedFeature({
    required int index,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final delay = 0.1 + (index * 0.1);

    // Create a custom animation for each feature with a staggered delay
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(_slideAnimation.value * (1 - animation.value), 0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectButton(ThemeData theme) {
    final isConnected = walletController.isConnected.value;
    final isLoading = walletController.isLoading.value;

    return ElevatedButton(
      onPressed: isLoading ? null : () {
        if (isConnected) {
          Get.offAllNamed(Routes.HOME);
        } else {
          walletController.connectWallet();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: theme.colorScheme.primary.withOpacity(0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          else
            Icon(
              isConnected ? Icons.dashboard_rounded : Icons.account_balance_wallet_rounded,
              size: 24,
              color: Colors.white,
            ),
          const SizedBox(width: 12),
          Text(
            isConnected ? 'Continue to Dashboard' : 'Connect Phantom Wallet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background particles and grid
class BackgroundParticlesPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final int gridDensity;
  final int particleCount;

  BackgroundParticlesPainter({
    required this.primaryColor,
    required this.secondaryColor,
    this.gridDensity = 15,
    this.particleCount = 50,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for grid lines
    final gridPaint = Paint()
      ..color = primaryColor.withOpacity(0.05)
      ..strokeWidth = 1;

    // Draw grid
    final cellWidth = size.width / gridDensity;
    final cellHeight = size.height / gridDensity;

    for (var i = 0; i <= gridDensity; i++) {
      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        gridPaint,
      );

      // Vertical lines
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        gridPaint,
      );
    }

    // Draw particles
    final random = math.Random(42); // Seed for reproducible randomness

    for (var i = 0; i < particleCount; i++) {
      final isMainColor = random.nextBool();
      final color = isMainColor ? primaryColor : secondaryColor;
      final size = random.nextDouble() * 3 + 1;

      final particlePaint = Paint()
        ..color = color.withOpacity(random.nextDouble() * 0.2 + 0.1)
        ..style = PaintingStyle.fill;

      final x = random.nextDouble() * 350;
      final y = random.nextDouble() * 750;

      canvas.drawCircle(Offset(x, y), size, particlePaint);

      // Add glow for some particles
      if (random.nextDouble() > 0.7) {
        final glowPaint = Paint()
          ..color = color.withOpacity(0.05)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

        canvas.drawCircle(Offset(x, y), size * 4, glowPaint);
      }
    }

    // Draw large gradient circles for background effect
    for (var i = 0; i < 3; i++) {
      final centerX = random.nextDouble() * size.width;
      final centerY = random.nextDouble() * size.height;
      final radius = 100 + random.nextDouble() * 150;

      final gradientPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            (i % 2 == 0 ? primaryColor : secondaryColor).withOpacity(0.05),
            (i % 2 == 0 ? primaryColor : secondaryColor).withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: radius,
        ));

      canvas.drawCircle(Offset(centerX, centerY), radius, gradientPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Static background doesn't need repainting
  }
}

// Custom painter for dashed circle
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final int dashCount;

  DashedCirclePainter({
    required this.color,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final dashLength = (2 * math.pi) / dashCount;

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * dashLength;
      final endAngle = startAngle + dashLength / 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength / 2,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}