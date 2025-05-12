// lib/screens/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../controllers/drive_ledger_controller.dart';
import '../controllers/phantom_wallet_controller.dart';
import '../database/models.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  final PhantomWalletController _walletController =
      Get.find<PhantomWalletController>();
  final DriveLedgerController _controller = Get.find<DriveLedgerController>();
  final TextEditingController _airdropAmountController =
      TextEditingController(text: '50');
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animController.forward();

    if (_walletController.isConnected.value) {
      _controller.setWalletAddress(_walletController.walletAddress.value);
      _fetchWalletData();
    }
  }

  @override
  void dispose() {
    _airdropAmountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchWalletData() async {
    await _walletController.getWalletBalance();
    await _controller.getUserTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchWalletData,
          ),
        ],
      ),
      body: Obx(() {
        if (_walletController.isLoading.value || _controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWalletCard(theme),
              const SizedBox(height: 24),
              if (_walletController.isConnected.value) ...[
                _buildBalanceCard(theme),
                const SizedBox(height: 20),
                _buildActionsCard(theme),
                const SizedBox(height: 20),
                _buildTransactionsCard(theme),
              ] else ...[
                _buildConnectPrompt(theme),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWalletCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              final isConnected = _walletController.isConnected.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Wallet icon with glow effect
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: isConnected
                              ? theme.colorScheme.primary.withOpacity(0.5)
                              : Colors.transparent,
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      isConnected
                          ? Icons.account_balance_wallet
                          : Icons.account_balance_wallet_outlined,
                      size: 40,
                      color: isConnected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isConnected ? 'Connected to Phantom' : 'Connect to Phantom',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isConnected) ...[
                    Text(
                      'Wallet Address:',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _walletController.formatAddress(
                                _walletController.walletAddress.value),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: 'monospace',
                              fontSize: 15,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            color: theme.colorScheme.primary,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: _walletController.walletAddress.value));
                              Get.snackbar(
                                'Copied',
                                'Wallet address copied to clipboard',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(8),
                                borderRadius: 8,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _walletController.disconnectWallet();
                        _controller.setWalletAddress('');
                      },
                      icon: const Icon(Icons.link_off),
                      label: const Text(
                        'Disconnect Wallet',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Connect your Phantom wallet to access blockchain features',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _walletController.connectWallet();
                        if (_walletController.isConnected.value) {
                          _controller.setWalletAddress(
                              _walletController.walletAddress.value);
                          _fetchWalletData();
                        }
                      },
                      icon: const Icon(Icons.link, color: Colors.white),
                      label: const Text('Connect to Phantom',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme) {
    return _buildAnimatedCard(
      duration: 300,
      delay: 200,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.cardColor,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Token Balance',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'DRVL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Drive-Ledger Token',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'DRVL',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                          begin: 0, end: _walletController.walletBalance.value),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          value.toStringAsFixed(2),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _fetchWalletData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Balance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCard(ThemeData theme) {
    return _buildAnimatedCard(
      duration: 400,
      delay: 400,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flash_on,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Actions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildActionTile(
                context,
                title: 'Request Airdrop (Devnet)',
                subtitle: 'Get test tokens to try the app',
                icon: Icons.flight_takeoff,
                iconColor: theme.colorScheme.primary,
                onTap: _showAirdropDialog,
              ),
              const Divider(height: 1),
              _buildActionTile(
                context,
                title: 'View on Solscan',
                subtitle: 'Explore your wallet on block explorer',
                icon: Icons.show_chart,
                iconColor: Colors.green,
                onTap: () {
                  // Open wallet on Solscan
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                context,
                title: 'Privacy & Permissions',
                subtitle: 'Manage data sharing preferences',
                icon: Icons.shield,
                iconColor: Colors.orange,
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.arrow_forward,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildTransactionsCard(ThemeData theme) {
    return _buildAnimatedCard(
      duration: 500,
      delay: 600,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (_controller.userTransactions.isEmpty) {
                  return Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.userTransactions.length > 5
                      ? 5
                      : _controller.userTransactions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final transaction = _controller.userTransactions[index];
                    final bool isReceived = transaction.isReceiver ?? false;

                    IconData typeIcon;
                    String typeLabel;

                    switch (transaction.type) {
                      case TransactionType.SUBSCRIPTION:
                        typeIcon = Icons.shopping_cart;
                        typeLabel = 'Subscription';
                        break;
                      case TransactionType.REWARD:
                        typeIcon = Icons.card_giftcard;
                        typeLabel = 'Reward';
                        break;
                      case TransactionType.TRANSFER:
                        typeIcon = Icons.swap_horiz;
                        typeLabel = 'Transfer';
                        break;
                      case TransactionType.AIRDROP:
                        typeIcon = Icons.flight_takeoff;
                        typeLabel = 'Airdrop';
                        break;
                      default:
                        typeIcon = Icons.attach_money;
                        typeLabel = 'Transaction';
                    }

                    return _buildTransactionTile(
                      context,
                      icon: typeIcon,
                      title: typeLabel,
                      subtitle:
                          '${transaction.completedAt != null ? _formatDate(transaction.completedAt!) : _formatDate(transaction.createdAt)} • ${transaction.status.toString().split('.').last}',
                      amount:
                          '${isReceived ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} DRVL',
                      isPositive: isReceived,
                      showLink: transaction.blockchainTxHash != null,
                      onTap: () {
                        // Transaction details
                      },
                      onLinkTap: transaction.blockchainTxHash != null
                          ? () {
                              // Open transaction on Solscan
                            }
                          : null,
                    );
                  },
                );
              }),
              if (_controller.userTransactions.length > 5) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Navigate to full transaction history
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('View All Transactions'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required bool isPositive,
    bool showLink = false,
    required VoidCallback onTap,
    VoidCallback? onLinkTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isPositive ? Colors.green : Colors.red,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          if (showLink && onLinkTap != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onLinkTap,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildConnectPrompt(ThemeData theme) {
    return _buildAnimatedCard(
      duration: 400,
      delay: 200,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
              const SizedBox(height: 24),
              Text(
                'Connect your wallet to get started',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You need to connect your Phantom wallet to access the full features of Drive-Ledger.',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Icon(
                  Icons.arrow_upward,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int duration,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  void _showAirdropDialog() {
    final theme = Theme.of(context);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Row(
          children: [
            Icon(
              Icons.flight_takeoff,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Request Airdrop'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the amount of DRVL tokens to request (Devnet only)',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _airdropAmountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
                labelText: 'Amount',
                suffixText: 'DRVL',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              final amount = double.tryParse(_airdropAmountController.text);
              if (amount == null || amount <= 0) {
                Get.snackbar(
                  'Error',
                  'Please enter a valid amount',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  borderRadius: 8,
                  margin: const EdgeInsets.all(8),
                );
                return;
              }

              // Show loading dialog
              Get.dialog(
                Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Processing airdrop...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              try {
                final result = await _controller.executeAirdrop(amount);
                Get.back(); // Close loading dialog

                if (result) {
                  // Refresh wallet balance
                  await _fetchWalletData();

                  // Show success dialog
                  Get.dialog(
                    Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Airdrop Successful!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: amount),
                              duration: const Duration(milliseconds: 1200),
                              builder: (context, value, _) {
                                return Text(
                                  'You received ${value.toStringAsFixed(2)} DRVL tokens',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => Get.back(),
                              child: const Text('OK'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                minimumSize: const Size(120, 45),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              } catch (e) {
                Get.back(); // Close loading dialog
                Get.snackbar(
                  'Error',
                  'Failed to execute airdrop: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  borderRadius: 8,
                  margin: const EdgeInsets.all(8),
                );
              }
            },
            child: const Text('Request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
