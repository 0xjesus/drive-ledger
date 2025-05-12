// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drive_ledger/widgets/dl_card.dart';
import 'package:drive_ledger/widgets/dl_button.dart';
import 'package:drive_ledger/controllers/phantom_wallet_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletController = Get.find<PhantomWalletController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account section
          _buildSectionHeader(context, 'Account'),

          Obx(() => DLCard(
            child: Column(
              children: [
                _buildSettingItem(
                  context,
                  title: 'Wallet',
                  subtitle: walletController.isConnected.value
                      ? 'Connected to Phantom'
                      : 'Not connected',
                  icon: Icons.account_balance_wallet_rounded,
                  trailing: Switch(
                    value: walletController.isConnected.value,
                    onChanged: (value) {
                      if (value) {
                        walletController.connectWallet();
                      } else {
                        walletController.disconnectWallet();
                      }
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                _buildDivider(),
                _buildSettingItem(
                  context,
                  title: 'Profile',
                  subtitle: 'Manage your profile information',
                  icon: Icons.person_rounded,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  context,
                  title: 'Notifications',
                  subtitle: 'Configure notification preferences',
                  icon: Icons.notifications_rounded,
                  onTap: () {},
                ),
              ],
            ),
          )),

          const SizedBox(height: 24),

          // Data Preferences
          _buildSectionHeader(context, 'Data Preferences'),

          DLCard(
            child: Column(
              children: [
                _buildSettingItem(
                  context,
                  title: 'Location Data',
                  subtitle: 'Share GPS and location data',
                  icon: Icons.location_on_rounded,
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                _buildDivider(),
                _buildSettingItem(
                  context,
                  title: 'Performance Data',
                  subtitle: 'Share engine and performance metrics',
                  icon: Icons.speed_rounded,
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                _buildDivider(),
                _buildSettingItem(
                  context,
                  title: 'Diagnostic Info',
                  subtitle: 'Share error codes and system health',
                  icon: Icons.build_rounded,
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                _buildDivider(),
                _buildSettingItem(
                  context,
                  title: 'Fuel/Battery Data',
                  subtitle: 'Share consumption and efficiency data',
                  icon: Icons.local_gas_station_rounded,
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // App Preferences
          _buildSectionHeader(context, 'App Preferences'),

          DLCard(
            child: Column(
              children: [
                _buildSettingItem(
                  context,
                  title: 'Dark Mode',
                  subtitle: 'Toggle dark/light theme',
                  icon: Icons.dark_mode_rounded,
                  trailing: Switch(
                    value: theme.brightness == Brightness.dark,
                    onChanged: (value) {
                      Get.changeThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                _buildDivider(),
                _buildSettingItem(
                  context,
                  title: 'Currency',
                  subtitle: 'USD',
                  icon: Icons.attach_money_rounded,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  context,
                  title: 'Language',
                  subtitle: 'English',
                  icon: Icons.language_rounded,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Support & About
          _buildSectionHeader(context, 'Support & About'),

          DLCard(
            child: Column(
              children: [
                _buildSettingItem(
                  context,
                  title: 'Help & Support',
                  subtitle: 'Get assistance and view FAQs',
                  icon: Icons.help_outline_rounded,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  context,
                  title: 'Privacy Policy',
                  subtitle: 'View our privacy policy',
                  icon: Icons.privacy_tip_rounded,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  context,
                  title: 'Terms of Service',
                  subtitle: 'View our terms of service',
                  icon: Icons.gavel_rounded,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  context,
                  title: 'About Drive-Ledger',
                  subtitle: 'Version 1.0.0',
                  icon: Icons.info_outline_rounded,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Logout button
          DLButton(
            text: 'Log Out',
            onPressed: () {
              // Show confirmation dialog
              Get.dialog(
                AlertDialog(
                  title: Text(
                    'Log Out',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Are you sure you want to log out? This will disconnect your wallet and reset your session.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        walletController.disconnectWallet();
                        Get.offAllNamed('/welcome');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
            backgroundColor: theme.colorScheme.error,
            icon: Icons.logout_rounded,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 60,
    );
  }
}