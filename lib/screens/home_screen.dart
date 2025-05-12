// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../controllers/drive_ledger_controller.dart';
import '../controllers/phantom_wallet_controller.dart';
import '../theme/theme_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DriveLedgerController controller = Get.find<DriveLedgerController>();
  final PhantomWalletController walletController = Get.find<PhantomWalletController>();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.car_crash,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Drive-Ledger',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              walletController.isConnected.value
                  ? Icons.account_balance_wallet
                  : Icons.account_balance_wallet_outlined,
              color: walletController.isConnected.value
                  ? Colors.green
                  : Colors.grey,
            ),
            onPressed: () => Get.toNamed('/wallet'),
            tooltip: walletController.isConnected.value
                ? 'Wallet Connected'
                : 'Connect Wallet',
          )),
        ],
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderSection(theme),
              const SizedBox(height: 20),
              _buildStatusCard(walletController, theme),
              const SizedBox(height: 20),
              _buildFeatureGrid(context, theme),
              const SizedBox(height: 20),
              _buildRecentActivity(controller, theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Drive-Ledger',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monetize your vehicle data securely',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => Get.toNamed('/simulations'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Simulation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => Get.toNamed('/marketplace'),
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Marketplace'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(PhantomWalletController walletController, ThemeData theme) {
    return Obx(() => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: walletController.isConnected.value
              ? Colors.green.withOpacity(0.5)
              : Colors.orange.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  walletController.isConnected.value
                      ? Icons.check_circle
                      : Icons.warning,
                  color: walletController.isConnected.value
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Wallet Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: walletController.isConnected.value
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (walletController.isConnected.value)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected to: ${walletController.formatAddress(walletController.walletAddress.value)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Obx(() => Text(
                    'Balance: ${walletController.walletBalance.value} DRVL',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/wallet'),
                    child: const Text('Manage Wallet',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No wallet connected. Connect your wallet to access all features.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/wallet'),
                    child: const Text('Connect Wallet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ));
  }

  Widget _buildFeatureGrid(BuildContext context, ThemeData theme) {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.directions_car,
        'title': 'Simulations',
        'description': 'Simulate drives and earn tokens',
        'route': '/simulations',
        'color': theme.colorScheme.primary,
      },
      {
        'icon': Icons.store,
        'title': 'Marketplace',
        'description': 'Buy and sell vehicle data',
        'route': '/marketplace',
        'color': Colors.green,
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Wallet',
        'description': 'Manage your digital assets',
        'route': '/wallet',
        'color': Colors.purple,
      },
      {
        'icon': Icons.bar_chart,
        'title': 'Statistics',
        'description': 'Analyze your activity and earnings',
        'route': '/stats',
        'color': Colors.orange,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Services',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.25,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return _buildFeatureCard(
              features[index]['icon'],
              features[index]['title'],
              features[index]['description'],
              features[index]['route'],
              features[index]['color'],
              theme,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
      IconData icon,
      String title,
      String description,
      String route,
      Color color,
      ThemeData theme,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(route),
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(DriveLedgerController controller, ThemeData theme) {
    // Sample activity for the UI
    final List<Map<String, dynamic>> activities = [
      {
        'icon': Icons.directions_car,
        'title': 'Simulation completed',
        'description': 'Urban route - 12.5 km',
        'time': '25 minutes',
        'reward': '+0.75 DRVL',
      },
      {
        'icon': Icons.shopping_bag,
        'title': 'Subscription purchased',
        'description': 'Performance data',
        'time': '2 hours',
        'reward': '-5.00 DRVL',
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Airdrop received',
        'description': 'Welcome to Drive-Ledger',
        'time': '1 day',
        'reward': '+10.00 DRVL',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(activities[index]['icon'], color: theme.colorScheme.primary),
                ),
                title: Text(
                  activities[index]['title'],
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '${activities[index]['description']} • ${activities[index]['time']}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  activities[index]['reward'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: activities[index]['reward'].startsWith('-')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.scaffoldBackgroundColor,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.7),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Simulation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break; // Already on Home
            case 1:
              Get.toNamed('/simulations');
              break;
            case 2:
              Get.toNamed('/marketplace');
              break;
            case 3:
              Get.toNamed('/wallet');
              break;
          }
        },
      ),
    );
  }
}