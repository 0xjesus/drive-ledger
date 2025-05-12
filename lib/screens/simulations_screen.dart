// lib/screens/simulations_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/drive_ledger_controller.dart';
import '../controllers/phantom_wallet_controller.dart';
import '../database/models.dart';

class SimulationsScreen extends StatefulWidget {
  const SimulationsScreen({Key? key}) : super(key: key);

  @override
  State<SimulationsScreen> createState() => _SimulationsScreenState();
}

class _SimulationsScreenState extends State<SimulationsScreen> with SingleTickerProviderStateMixin {
  final DriveLedgerController _controller = Get.find<DriveLedgerController>();
  final PhantomWalletController _walletController = Get.find<PhantomWalletController>();
  late TabController _tabController;
  int _selectedRouteIndex = 0;
  int _durationMinutes = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    await _controller.getAvailableRoutes();

    // Asegurar que el índice seleccionado sea válido después de cargar las rutas
    if (_controller.availableRoutes.isNotEmpty) {
      if (_selectedRouteIndex >= _controller.availableRoutes.length) {
        setState(() {
          _selectedRouteIndex = 0; // Seleccionar la primera ruta si el índice actual no es válido
        });
      }
      // Log de la ruta inicialmente seleccionada
      final initialRoute = _controller.availableRoutes[_selectedRouteIndex];
      print("Initially selected route: ${initialRoute.name}, type: ${initialRoute.routeType ?? 'NULL'}, id: ${initialRoute.id}");
    } else {
      print("No routes available after loading");
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
        title: const Text('Simulations'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New Simulation'),
            Tab(text: 'History'),
          ],
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewSimulationTab(theme),
          _buildHistoryTab(theme),
        ],
      ),
    );
  }

  Widget _buildNewSimulationTab(ThemeData theme) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.availableRoutes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.route_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No routes available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Try reloading the page'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRoutes,
                child: const Text('Reload'),
              ),
            ],
          ),
        );
      }

      // If there's an active simulation, show its status
      if (_controller.currentSimulationStatus.value != null &&
          _controller.currentSimulationStatus.value!.isActive) {
        return _buildActiveSimulationView(theme);
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRoutesSection(theme),
            const SizedBox(height: 20),
            _buildDurationSection(theme),
            const SizedBox(height: 20),
            _buildWalletSection(theme),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _startSimulation(),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text('Start Simulation',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionStep(1, 'Select a route for your simulation.'),
                    _buildInstructionStep(2, 'Choose the simulation duration.'),
                    _buildInstructionStep(3, 'Connect your wallet to receive rewards.'),
                    _buildInstructionStep(4, 'Start the simulation and earn DRVL tokens.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesSection(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Route',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _controller.availableRoutes.length,
                itemBuilder: (context, index) {
                  final route = _controller.availableRoutes[index];
                  return _buildRouteCard(route, index, theme);
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(SimulationRoute route, int index, ThemeData theme) {
    bool isSelected = _selectedRouteIndex == index;
    // Usa el ID para identificar el tipo de ruta para colores e iconos
    final routeIdentifier = route.id;
    final color = _getRouteColor(routeIdentifier);
    final icon = _getRouteIcon(routeIdentifier);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRouteIndex = index;
          // Log cuando el usuario selecciona una ruta
          print("User selected route: ${route.name}, id: ${route.id}, index: $index");
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${route.distance} km • ${route.estimatedTime} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Speed: ${route.averageSpeed} km/h',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Selected',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRouteColor(String routeIdentifier) {
    switch (routeIdentifier) {
      case 'URBAN':
        return Colors.blue;
      case 'HIGHWAY':
        return Colors.green.shade600;
      case 'MOUNTAIN':
        return Colors.orange.shade700;
      case 'RURAL':
        return Colors.teal;
      default:
        return Colors.purple;
    }
  }

  IconData _getRouteIcon(String routeType) {
    switch (routeType) {
      case 'URBAN':
        return Icons.location_city;
      case 'HIGHWAY':
        return Icons.bolt;
      case 'MOUNTAIN':
        return Icons.terrain;
      case 'RURAL':
        return Icons.nature;
      default:
        return Icons.map;
    }
  }

  Widget _buildDurationSection(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulation Duration',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select how long you want to simulate',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [5, 10, 15, 30, 60].map((duration) {
                bool isSelected = _durationMinutes == duration;
                return _buildDurationOption(duration, isSelected, theme);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(int duration, bool isSelected, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _durationMinutes = duration;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Text(
              '$duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'min',
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSection(ThemeData theme) {
    return Obx(() {
      final isConnected = _walletController.isConnected.value;

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isConnected
                ? Colors.green.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
            width: 1,
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
                    isConnected ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
                    color: isConnected ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Wallet Connected' : 'Wallet Not Connected',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isConnected ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isConnected)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rewards will be sent to: ${_walletController.formatAddress(_walletController.walletAddress.value)}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current Balance: ${_walletController.walletBalance.value} DRVL',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connect your wallet to receive rewards',
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
      );
    });
  }

  Widget _buildActiveSimulationView(ThemeData theme) {
    return Obx(() {
      final status = _controller.currentSimulationStatus.value!;

      return Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: status.progress != null ? status.progress! / 100 : null,
            backgroundColor: Colors.grey.shade200,
            color: theme.colorScheme.primary,
            minHeight: 6,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.2),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Simulation in Progress',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              status.route ?? 'Route: Unknown',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Main indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSimulationStat(
                                  'Time',
                                  '${(status.elapsedMinutes ?? 0).toStringAsFixed(1)} min',
                                  Icons.timer,
                                  theme,
                                ),
                                _buildSimulationStat(
                                  'Distance',
                                  '${(status.distanceCovered ?? 0).toStringAsFixed(2)} km',
                                  Icons.straighten,
                                  theme,
                                ),
                                _buildSimulationStat(
                                  'Speed',
                                  '${(status.averageSpeed ?? 0).toStringAsFixed(1)} km/h',
                                  Icons.speed,
                                  theme,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Current vehicle data
                            if (status.currentData != null) ...[
                              const Divider(),
                              const SizedBox(height: 16),
                              const Text(
                                'Real-Time Vehicle Data',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildVehicleDataGrid(status.currentData!, theme),
                            ],

                            const SizedBox(height: 24),

                            // Action buttons
                            ElevatedButton.icon(
                              onPressed: () => _stopSimulation(),
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop Simulation'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reward information
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.attach_money, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Estimated Rewards',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Rewards are calculated based on the distance traveled, driving time, and quality of collected data.',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You will receive your DRVL tokens when the simulation ends.',
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Estimated: ${((status.distanceCovered ?? 0) * 0.1).toStringAsFixed(2)} DRVL',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSimulationStat(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleDataGrid(Map<String, dynamic> data, ThemeData theme) {
    // Data to display from the vehicle
    final Map<String, dynamic> displayData = {
      'Speed': '${data['speed_kmph'] ?? 0} km/h',
      'RPM': data['engine_rpm'] ?? 0,
      'Temperature': '${data['engine_temp_c'] ?? 0} °C',
      'Fuel': '${data['fuel_level_pct'] ?? 0}%',
    };

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: displayData.entries.map((entry) {
        return Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryTab(ThemeData theme) {
    return FutureBuilder(
      future: _walletController.isConnected.value ? _controller.getUserSimulations() : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_walletController.isConnected.value == false) {
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
                  'Connect your wallet to view simulation history',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/wallet'),
                  child: const Text('Connect Wallet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error loading simulations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(snapshot.error.toString()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        }

        return Obx(() {
          if (_controller.userSimulations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No previous simulations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Complete your first simulation'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _tabController.animateTo(0),
                    child: const Text('New Simulation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.userSimulations.length,
            itemBuilder: (context, index) {
              final simulation = _controller.userSimulations[index];
              return _buildHistoryCard(simulation, theme);
            },
          );
        });
      },
    );
  }

  Widget _buildHistoryCard(DriveSimulation simulation, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: simulation.status == SimulationStatus.COMPLETED
              ? Colors.green.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
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
                  _getRouteIcon(simulation.routeType),
                  color: _getRouteColor(simulation.routeType),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${simulation.routeType} Simulation',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: simulation.status == SimulationStatus.COMPLETED
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    simulation.status.toString().split('.').last,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: simulation.status == SimulationStatus.COMPLETED
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSimulationDetail('Duration', '${simulation.durationMinutes?.toStringAsFixed(1) ?? "0"} min', theme),
                _buildSimulationDetail('Distance', '${simulation.distanceKm?.toStringAsFixed(2) ?? "0"} km', theme),
                _buildSimulationDetail('Speed', '${simulation.avgSpeedKmph?.toStringAsFixed(1) ?? "0"} km/h', theme),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${simulation.startedAt.day}/${simulation.startedAt.month}/${simulation.startedAt.year} ${simulation.startedAt.hour}:${simulation.startedAt.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (simulation.status == SimulationStatus.COMPLETED)
                  ElevatedButton(
                    onPressed: () => _claimReward(simulation.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Claim Reward'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationDetail(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _startSimulation() async {
    if (_controller.availableRoutes.isEmpty) {
      Get.snackbar(
        'Error',
        'No routes available for simulation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Imprimir información de depuración
    print("Available routes: ${_controller.availableRoutes.length}, Selected index: $_selectedRouteIndex");

    final selectedRoute = _controller.availableRoutes[_selectedRouteIndex];
    // Usar el ID como routeType
    final routeType = selectedRoute.id;

    print("Selected route: ${selectedRoute.name}, type: ${selectedRoute.routeType ?? 'NULL'}, id: ${routeType}");

    // Verificar si la wallet está conectada
    if (!_walletController.isConnected.value) {
      Get.dialog(
        AlertDialog(
          title: const Text('Wallet not connected'),
          content: const Text(
            'A wallet connection is required to start a simulation. Would you like to connect your wallet now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/wallet');
              },
              child: const Text('Connect Wallet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Verificar que tengamos una dirección de wallet válida
    if (_walletController.walletAddress.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Wallet address is missing. Please reconnect your wallet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Asegurar que el controlador tenga la dirección de la wallet
    _controller.setWalletAddress(_walletController.walletAddress.value);

    // Ahora podemos iniciar la simulación
    final simulation = await _controller.startSimulation(
      routeType,
      _durationMinutes,
    );

    if (simulation != null) {
      Get.snackbar(
        'Simulation Started',
        'The simulation has been started successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Could not start simulation: ${_controller.errorMessage.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _stopSimulation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Stop Simulation'),
        content: const Text(
          'Are you sure you want to stop the current simulation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final result = await _controller.stopSimulation();
              if (result) {
                Get.snackbar(
                  'Simulation Stopped',
                  'The simulation has been stopped successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Could not stop simulation: ${_controller.errorMessage.value}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  void _claimReward(String simulationId) async {
    if (!_walletController.isConnected.value) {
      Get.snackbar(
        'Wallet not connected',
        'Connect your wallet to claim the reward',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show loading dialog
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Processing reward...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final reward = await _controller.generateReward(simulationId);
      Get.back(); // Close loading dialog

      if (reward != null) {
        Get.dialog(
          AlertDialog(
            title: const Text('Reward Claimed!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(
                  'You received ${reward.amount} DRVL',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The reward has been sent to your wallet.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not claim reward: ${_controller.errorMessage.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Error processing reward: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}