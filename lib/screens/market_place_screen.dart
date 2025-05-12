// lib/screens/marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/drive_ledger_controller.dart';
import '../controllers/phantom_wallet_controller.dart';
import '../database/models.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  final DriveLedgerController _controller = Get.find<DriveLedgerController>();
  final PhantomWalletController _walletController = Get.find<PhantomWalletController>();
  late TabController _tabController;

  // Filters for marketplace listings
  String? _selectedDataType;
  double? _maxPrice;
  double? _minRating;
  bool _onlyActive = true;

  // Variable to hold transaction hash from user input
  String? _transactionHash;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

// En MarketplaceScreen.dart, modificar el método _loadData() para eliminar la segunda llamada:

  Future<void> _loadData() async {
    if (_controller.walletAddress.isEmpty && _walletController.isConnected.value) {
      _controller.setWalletAddress(_walletController.walletAddress.value);
    }

    await Future.wait([
      _controller.getDataTypes(),
      _controller.getMarketplaceListings(active: _onlyActive),
    ]);

    if (_walletController.isConnected.value) {
      await _controller.getUserSubscriptions();
      // Eliminar la segunda llamada a getMarketplaceListings
    }
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(theme),
            tooltip: 'Filter Listings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Explore'),
            Tab(text: 'My Listings'),
            Tab(text: 'My Subscriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExploreTab(theme),
          _buildMyListingsTab(theme),
          _buildMySubscriptionsTab(theme),
        ],
      ),
      floatingActionButton: Obx(() => _walletController.isConnected.value
          ? FloatingActionButton(
        onPressed: () => _showCreateListingDialog(theme),
        child: const Icon(Icons.add),
        tooltip: 'Create Listing',
      )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildExploreTab(ThemeData theme) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.marketplaceListings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No listings available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedDataType != null || _maxPrice != null || _minRating != null
                    ? 'Try changing your filters'
                    : 'Be the first to create a data listing',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadData(),
                child: const Text('Refresh'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.marketplaceListings.length,
          itemBuilder: (context, index) {
            final listing = _controller.marketplaceListings[index];
            return _buildListingCard(listing, theme);
          },
        ),
      );
    });
  }

  Widget _buildMyListingsTab(ThemeData theme) {
    return Obx(() {
      if (!_walletController.isConnected.value) {
        return _buildWalletConnectPrompt(theme);
      }

      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final myListings = _controller.marketplaceListings
          .where((listing) => listing.seller == _walletController.walletAddress.value)
          .toList();

      if (myListings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No listings created',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Create your first data listing'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showCreateListingDialog(theme),
                child: const Text('Create Listing'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myListings.length,
        itemBuilder: (context, index) {
          final listing = myListings[index];
          return _buildMyListingCard(listing, theme);
        },
      );
    });
  }

  Widget _buildMySubscriptionsTab(ThemeData theme) {
    return Obx(() {
      if (!_walletController.isConnected.value) {
        return _buildWalletConnectPrompt(theme);
      }

      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.userSubscriptions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.subscriptions_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No active subscriptions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Subscribe to data listings to access vehicle data'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _tabController.animateTo(0),
                child: const Text('Explore Listings'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.userSubscriptions.length,
        itemBuilder: (context, index) {
          final subscription = _controller.userSubscriptions[index];
          return _buildSubscriptionCard(subscription, theme);
        },
      );
    });
  }

  Widget _buildWalletConnectPrompt(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Wallet not connected',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect your wallet to access your listings and subscriptions',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed('/wallet'),
            child: const Text('Connect Wallet'),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(Listing listing, ThemeData theme) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showListingDetailsDialog(listing, theme),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section with data type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getDataTypeColor(listing.dataType).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getDataTypeIcon(listing.dataType),
                    color: _getDataTypeColor(listing.dataType),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      listing.typeName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (listing.avgRating != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          listing.avgRating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seller and price info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_circle, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Seller: ${_formatAddress(listing.seller)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        '${listing.pricePerPoint} DRVL/point',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description
                  if (listing.description != null && listing.description!.isNotEmpty) ...[
                    Text(
                      listing.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Statistics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatisticItem(
                        'Privacy Impact',
                        listing.privacyImpact,
                        _getPrivacyImpactColor(listing.privacyImpact),
                        theme,
                      ),
                      _buildStatisticItem(
                        'Subscribers',
                        '${listing.purchaseCount}',
                        null,
                        theme,
                      ),
                      _buildStatisticItem(
                        'Ratings',
                        '${listing.ratingCount}',
                        null,
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Footer with subscribe button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showListingDetailsDialog(listing, theme),
                    child: const Text('Details'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: !listing.active
                        ? null
                        : () => _showSubscriptionDialog(listing, theme),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: const Text('Subscribe'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyListingCard(Listing listing, ThemeData theme) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section with data type and status toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getDataTypeColor(listing.dataType).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getDataTypeIcon(listing.dataType),
                  color: _getDataTypeColor(listing.dataType),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    listing.typeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: listing.active,
                  onChanged: (value) => _updateListingStatus(listing.id, value),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price info and stats button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${listing.pricePerPoint} DRVL/point',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showListingStatsDialog(listing, theme),
                      icon: const Icon(Icons.analytics, size: 16),
                      label: const Text('Statistics'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Description
                if (listing.description != null && listing.description!.isNotEmpty) ...[
                  Text(
                    listing.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                // Status badges
                Row(
                  children: [
                    _buildStatusBadge(
                      listing.active ? 'Active' : 'Inactive',
                      listing.active ? Colors.green : Colors.grey,
                      theme,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(
                      'Subscribers: ${listing.purchaseCount}',
                      null,
                      theme,
                    ),
                    if (listing.avgRating != null) ...[
                      const SizedBox(width: 8),
                      _buildStatusBadge(
                        '${listing.avgRating!.toStringAsFixed(1)}★',
                        Colors.amber,
                        theme,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Footer with action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showListingDetailsDialog(listing, theme),
                  child: const Text('Details'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showEditListingDialog(listing, theme),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(Subscription subscription, ThemeData theme) {
    final bool isSubscriber = subscription.isSubscriber ?? true;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with status and role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(subscription.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSubscriber ? Icons.download : Icons.upload,
                  color: _getStatusColor(subscription.status),
                ),
                const SizedBox(width: 8),
                Text(
                  isSubscriber ? 'Subscription' : 'Data Provider',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(subscription.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subscription.status.toString().split('.').last,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: _getStatusColor(subscription.status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Counterparty info
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      isSubscriber
                          ? 'Provider: ${_formatAddress(subscription.seller)}'
                          : 'Subscriber: ${_formatAddress(subscription.buyer)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Subscription details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSubscriptionDetail('Data Points/Day', '${subscription.pointsPerDay}', theme),
                    _buildSubscriptionDetail('Duration', '${subscription.durationDays} days', theme),
                    _buildSubscriptionDetail('Total Price', '${subscription.totalPrice} DRVL', theme),
                  ],
                ),
                const SizedBox(height: 12),
                // Date range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Start: ${_formatDate(subscription.startDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      'End: ${_formatDate(subscription.endDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer with action button
          if (isSubscriber && subscription.status == SubscriptionStatus.ACTIVE)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _showRatingDialog(subscription),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: const Text('Rate Provider'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String label, String value, Color? valueColor, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.brightness == Brightness.dark
                ? Colors.grey.shade300
                : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color? color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color ?? theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetail(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.brightness == Brightness.dark
                ? Colors.grey.shade300
                : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(ThemeData theme) {
    String? tempDataType = _selectedDataType;
    double? tempMaxPrice = _maxPrice;
    double? tempMinRating = _minRating;
    bool tempOnlyActive = _onlyActive;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Filter Listings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Data type filter
              const Text('Data Type'),
              DropdownButton<String>(
                value: tempDataType,
                isExpanded: true,
                hint: const Text('All Types'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Types'),
                  ),
                  ..._controller.dataTypes.map((DataType type) {
                    return DropdownMenuItem<String>(
                      value: type.id,
                      child: Text(type.name),
                    );
                  }).toList(),
                ],
                onChanged: (String? newValue) {
                  tempDataType = newValue;
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // Max price filter
              const Text('Maximum Price per Point (DRVL)'),
              Slider(
                value: tempMaxPrice ?? 0.2,
                min: 0.01,
                max: 0.2,
                divisions: 19,
                label: tempMaxPrice?.toStringAsFixed(2) ?? 'No limit',
                onChanged: (value) {
                  tempMaxPrice = value == 0.2 ? null : value;
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // Min rating filter
              const Text('Minimum Rating'),
              Slider(
                value: tempMinRating ?? 0,
                min: 0,
                max: 5,
                divisions: 10,
                label: tempMinRating?.toStringAsFixed(1) ?? 'No minimum',
                onChanged: (value) {
                  tempMinRating = value == 0 ? null : value;
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // Only active
              Row(
                children: [
                  Checkbox(
                    value: tempOnlyActive,
                    onChanged: (value) {
                      tempOnlyActive = value!;
                      setState(() {});
                    },
                  ),
                  const Text('Only show active listings'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Clear filters
              setState(() {
                _selectedDataType = null;
                _maxPrice = null;
                _minRating = null;
                _onlyActive = true;
              });
              _controller.getMarketplaceListings(active: true);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _selectedDataType = tempDataType;
                _maxPrice = tempMaxPrice;
                _minRating = tempMinRating;
                _onlyActive = tempOnlyActive;
              });
              _applyFilters();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
  void _applyFilters() {
    _controller.getMarketplaceListings(
      dataType: _selectedDataType,
      maxPrice: _maxPrice,
      minRating: _minRating,
      active: _onlyActive,
    );
  }

  void _showCreateListingDialog(ThemeData theme) {
    if (_controller.dataTypes.isEmpty) {
      Get.snackbar(
        'Error',
        'Could not load data types',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String dataType = _controller.dataTypes.first.id;
    double pricePerPoint = 0.05;
    String description = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Listing'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Data type
                const Text('Data Type'),
                DropdownButton<String>(
                  value: dataType,
                  isExpanded: true,
                  items: _controller.dataTypes.map((DataType type) {
                    return DropdownMenuItem<String>(
                      value: type.id,
                      child: Text('${type.name} (${type.baseValue} DRVL)'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // Usamos setDialogState en lugar de setState
                      setDialogState(() {
                        dataType = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Price per point
                const Text('Price per data point (DRVL)'),
                Slider(
                  value: pricePerPoint,
                  min: 0.01,
                  max: 0.2,
                  divisions: 19,
                  label: pricePerPoint.toStringAsFixed(2),
                  onChanged: (value) {
                    setDialogState(() {
                      pricePerPoint = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Description
                const Text('Description'),
                TextField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Describe your data...',
                  ),
                  onChanged: (value) {
                    description = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final result = await _controller.createListing(
                  dataType: dataType,
                  pricePerPoint: pricePerPoint,
                  description: description,
                );
                if (result != null) {
                  Get.snackbar(
                    'Success',
                    'Listing created successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  // Move to My Listings tab
                  _tabController.animateTo(1);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
  void _showEditListingDialog(Listing listing, ThemeData theme) {
    double pricePerPoint = listing.pricePerPoint;
    String description = listing.description ?? '';

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Listing'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Type: ${listing.typeName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Price per point
              const Text('Price per data point (DRVL)'),
              Slider(
                value: pricePerPoint,
                min: 0.01,
                max: 0.2,
                divisions: 19,
                label: pricePerPoint.toStringAsFixed(2),
                onChanged: (value) {
                  pricePerPoint = value;
                },
              ),
              const SizedBox(height: 16),

              // Description
              const Text('Description'),
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Describe your data...',
                ),
                controller: TextEditingController(text: description),
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final result = await _controller.updateListing(
                listing.id,
                pricePerPoint: pricePerPoint,
                description: description,
              );
              if (result != null) {
                Get.snackbar(
                  'Success',
                  'Listing updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateListingStatus(String listingId, bool active) async {
    final result = await _controller.updateListing(
      listingId,
      active: active,
    );
    if (result != null) {
      Get.snackbar(
        'Success',
        'Listing status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void _showListingStatsDialog(Listing listing, ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Listing Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatItem('Data Type', listing.typeName),
            _buildStatItem('Total Subscriptions', '${listing.purchaseCount}'),
            _buildStatItem('Average Rating', listing.avgRating != null ? '${listing.avgRating!.toStringAsFixed(1)}/5.0' : 'N/A'),
            _buildStatItem('Number of Ratings', '${listing.ratingCount}'),
            _buildStatItem('Price per Point', '${listing.pricePerPoint} DRVL'),
            _buildStatItem('Status', listing.active ? 'Active' : 'Inactive'),
            _buildStatItem('Creation Date', _formatDate(listing.createdAt)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  void _showListingDetailsDialog(Listing listing, ThemeData theme) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getDataTypeColor(listing.dataType).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDataTypeIcon(listing.dataType),
                      color: _getDataTypeColor(listing.dataType),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        listing.typeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!listing.active)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Inactive',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seller info
                    Row(
                      children: [
                        const Icon(Icons.account_circle, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Seller: ${_formatAddress(listing.seller)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Description
                    if (listing.description != null && listing.description!.isNotEmpty) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(listing.description!),
                      const SizedBox(height: 16),
                    ],
                    // Data details
                    const Text(
                      'Data Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Data Type', listing.typeName),
                    _buildDetailRow('Privacy Impact', listing.privacyImpact),
                    _buildDetailRow('Price per Point', '${listing.pricePerPoint} DRVL'),
                    const SizedBox(height: 16),
                    // Stats
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Subscriptions', '${listing.purchaseCount}'),
                    _buildDetailRow('Rating', listing.avgRating != null ? '${listing.avgRating!.toStringAsFixed(1)}/5.0 (${listing.ratingCount} ratings)' : 'No ratings yet'),
                    _buildDetailRow('Created', _formatDate(listing.createdAt)),
                    if (listing.createdAt != listing.updatedAt)
                      _buildDetailRow('Last Updated', _formatDate(listing.updatedAt)),
                    const SizedBox(height: 16),
                    // Sample data section
                    if (listing.samples != null && listing.samples!.isNotEmpty) ...[
                      const Text(
                        'Sample Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: listing.samples!.take(1).map((sample) {
                            return Text(
                              sample.toString(),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    if (listing.active)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showSubscriptionDialog(listing, theme);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: const Text('Subscribe'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(Listing listing, ThemeData theme) {
    if (!_walletController.isConnected.value) {
      Get.snackbar(
        'Wallet not connected',
        'Connect your wallet to subscribe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.toNamed('/wallet');
      return;
    }

    int durationDays = 30;
    int pointsPerDay = 10;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Subscribe to ${listing.typeName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Listing info
              Text(
                'Seller: ${_formatAddress(listing.seller)}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Price per point: ${listing.pricePerPoint} DRVL',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Duration
              const Text('Subscription duration (days)'),
              Slider(
                value: durationDays.toDouble(),
                min: 1,
                max: 90,
                divisions: 89,
                label: durationDays.toString(),
                onChanged: (value) {
                  durationDays = value.toInt();
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // Points per day
              const Text('Data points per day'),
              Slider(
                value: pointsPerDay.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: pointsPerDay.toString(),
                onChanged: (value) {
                  pointsPerDay = value.toInt();
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subscription Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSubscriptionSummaryItem('Duration', '$durationDays days'),
                    _buildSubscriptionSummaryItem('Points per day', '$pointsPerDay points'),
                    _buildSubscriptionSummaryItem('Total points', '${durationDays * pointsPerDay} points'),
                    const Divider(),
                    _buildSubscriptionSummaryItem(
                      'Total cost',
                      '${(durationDays * pointsPerDay * listing.pricePerPoint).toStringAsFixed(2)} DRVL',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final result = await _controller.createSubscription(
                listingId: listing.id,
                durationDays: durationDays,
                pointsPerDay: pointsPerDay,
              );
              if (result != null) {
                _showTransactionDialog(result['transactionId'], result['encodedTransaction']);
              }
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
  Widget _buildSubscriptionSummaryItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDialog(String? transactionId, String? encodedTransaction) {
    if (transactionId == null || encodedTransaction == null) {
      Get.snackbar(
        'Error',
        'Could not create transaction',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirm Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'The transaction has been prepared. Please confirm the transaction in your Phantom wallet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Close dialog first to avoid UI issues
                Navigator.pop(dialogContext);

                // Sign the transaction with Phantom
                bool success = await _walletController.signAndSendTransaction(encodedTransaction);

                if (success) {
                  // Show a loading dialog while waiting for the transaction
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext loadingContext) => AlertDialog(
                      title: const Text('Processing Transaction'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Please wait while the transaction is processed...'),
                        ],
                      ),
                    ),
                  );

                  // Add a delay to allow the transaction to process
                  await Future.delayed(Duration(seconds: 5));

                  // Close the loading dialog
                  Navigator.of(context, rootNavigator: true).pop();

                  // Automatically confirm the transaction
                  final result = await _controller.confirmTransaction(
                    transactionId,
                    "AUTO_CONFIRMED_" + DateTime.now().millisecondsSinceEpoch.toString(),
                  );

                  if (result) {
                    Get.snackbar(
                      'Success',
                      'Subscription confirmed successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    // Update subscriptions
                    await _controller.getUserSubscriptions();
                    // Move to My Subscriptions tab
                    _tabController.animateTo(2);
                  }
                }
              },
              child: const Text('Sign with Phantom'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }


  void _showRatingDialog(subscription) {
    double rating = 3.0;
    String comment = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Rate Data Provider'),
        content: Container(
          width: double.maxFinite,  // Asegura que el contenido tenga ancho flexible
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rate the quality of the received data',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Usar Wrap en lugar de Row para evitar overflow
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,  // Espaciado horizontal entre estrellas
                children: List.generate(5, (index) {
                  return IconButton(
                    padding: EdgeInsets.zero,  // Reduce el padding
                    constraints: BoxConstraints(),  // Minimiza restricciones
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 30,  // Tamaño reducido de 36 a 30
                    ),
                    onPressed: () {
                      rating = index + 1.0;
                      setState(() {});
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Comments (optional)',
                ),
                onChanged: (value) {
                  comment = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final result = await _controller.rateDataProvider(
                subscription.id,
                rating,
                comment: comment.isNotEmpty ? comment : null,
              );
              if (result) {
                Get.snackbar(
                  'Success',
                  'Rating submitted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Submit Rating'),
          ),
        ],
      ),
    );
  }


  // Helper methods
  Color _getDataTypeColor(String dataType) {
    switch (dataType) {
      case 'LOCATION':
        return Colors.red;
      case 'PERFORMANCE':
        return Colors.blue;
      case 'DIAGNOSTIC':
        return Colors.purple;
      case 'FUEL':
        return Colors.orange;
      case 'COMPLETE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getDataTypeIcon(String dataType) {
    switch (dataType) {
      case 'LOCATION':
        return Icons.location_on;
      case 'PERFORMANCE':
        return Icons.speed;
      case 'DIAGNOSTIC':
        return Icons.build;
      case 'FUEL':
        return Icons.local_gas_station;
      case 'COMPLETE':
        return Icons.dashboard;
      default:
        return Icons.data_usage;
    }
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.PENDING:
        return Colors.orange;
      case SubscriptionStatus.ACTIVE:
        return Colors.green;
      case SubscriptionStatus.EXPIRED:
        return Colors.red;
      case SubscriptionStatus.CANCELLED:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getPrivacyImpactColor(String impact) {
    switch (impact.toUpperCase()) {
      case 'HIGH':
      case 'VERY HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
      case 'VERY LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatAddress(String address) {
    if (address.length <= 8) return address;
    return "${address.substring(0, 4)}...${address.substring(address.length - 4)}";
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}