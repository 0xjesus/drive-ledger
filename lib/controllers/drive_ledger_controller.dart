// lib/controllers/drive_ledger_controller.dart

import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';

// Import network service and models
import '../database/models.dart';
import '../services/network_service.dart';
import '../utils/logger.dart'; // Añadir esta importación para el sistema de logs

class DriveLedgerController extends GetxController {
  final NetworkService _networkService = NetworkService();
  final Logger _logger = Logger('DriveLedgerController'); // Utilizar un logger centralizado

  // UI reactive variables
  final RxBool isInitialized = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString walletAddress = ''.obs;

  // Variables for data storage
  final Rx<TokenBalance?> tokenBalance = Rx<TokenBalance?>(null);
  final RxList<SimulationRoute> availableRoutes = <SimulationRoute>[].obs;
  final Rx<SimulationStatusModel?> currentSimulationStatus = Rx<SimulationStatusModel?>(null);
  final Rx<DriveSimulation?> activeSimulation = Rx<DriveSimulation?>(null);
  final RxList<DriveSimulation> userSimulations = <DriveSimulation>[].obs;
  final RxList<DataType> dataTypes = <DataType>[].obs;
  final RxList<Listing> marketplaceListings = <Listing>[].obs;
  final RxList<Subscription> userSubscriptions = <Subscription>[].obs;
  final RxList<Transaction> userTransactions = <Transaction>[].obs;
  final Rx<MarketStatistics?> marketStatistics = Rx<MarketStatistics?>(null);

  // Timer for refreshing simulation status
  Timer? _simulationTimer;

  @override
  void onInit() {
    _logger.info('onInit called');
    super.onInit();
    initializeServices();
  }

  @override
  void onClose() {
    _logger.info('onClose called');
    _stopSimulationTimer();
    super.onClose();
  }

  // Method to start/stop the simulation timer
  void _startSimulationTimer() {
    _logger.info('Starting simulation timer');
    _stopSimulationTimer();
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _logger.debug('Timer tick - Executing getSimulationStatus()');
      getSimulationStatus();
    });
  }

  void _stopSimulationTimer() {
    if (_simulationTimer != null) {
      _logger.info('Stopping simulation timer');
      _simulationTimer?.cancel();
      _simulationTimer = null;
    }
  }

  // Method to clear error messages
  void clearError() {
    _logger.debug('Clearing error messages');
    errorMessage.value = '';
  }

  // Method to set user wallet address
  void setWalletAddress(String address) {
    _logger.info('Setting wallet address: $address');
    walletAddress.value = address;
    update();
  }

  // INITIALIZATION AND CONFIGURATION METHODS

  /// Initialize backend services
  Future<void> initializeServices({String? tokenMintAddress}) async {
    _logger.info('Initializing services with tokenMintAddress: $tokenMintAddress');
    try {
      isLoading.value = true;
      clearError();

      final Map<String, dynamic> data = {};
      if (tokenMintAddress != null) {
        data['tokenMintAddress'] = tokenMintAddress;
      } else {
        // Use default token from backend if not provided
        data['tokenMintAddress'] = "2CdXTtCLWNMfG7EvuMfuQ7FNEjrneUxscg3VgpqQzgAD";
      }

      _logger.debug('initializeServices - Sending request with data: $data');
      final response = await _networkService.post(
        '/api/initialize',
        data: data,
      );
      _logger.debug('initializeServices - Response received: ${_formatResponseLog(response.data)}');

      // Check if the response indicates success
      if (_isSuccessResponse(response.data)) {
        isInitialized.value = true;

        // Get data types right after initialization
        _logger.info('Initialization successful, fetching data types');
        await getDataTypes();

        _showSuccessSnackbar('Services initialized successfully');
      } else {
        // Use a more specific message if available
        String errorMsg = _extractErrorMessage(response.data, 'Error initializing services');
        errorMessage.value = errorMsg;
        _logger.error('Initialization error: $errorMsg');
        _showErrorSnackbar(errorMsg);
      }
    } catch (e) {
      _handleException('initializeServices', e);
    } finally {
      isLoading.value = false;
      update();
      _logger.info('initializeServices completed');
    }
  }

  // ROUTES AND SIMULATIONS METHODS

  /// Get available simulation routes
  Future<List<SimulationRoute>> getAvailableRoutes() async {
    _logger.info('Getting available routes');
    try {
      isLoading.value = true;
      clearError();

      final response = await _networkService.get('/api/routes');
      _logger.debug('getAvailableRoutes - Response received: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final List<dynamic> routesData = response.data['data'];
        _logger.info('Routes found: ${routesData.length}');
        availableRoutes.value = routesData.map((route) => SimulationRoute.fromJson(route)).toList();
        return availableRoutes;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting routes');
        errorMessage.value = errorMsg;
        _logger.error('getAvailableRoutes error: $errorMsg');
        return [];
      }
    } catch (e) {
      _handleException('getAvailableRoutes', e);
      return [];
    } finally {
      isLoading.value = false;
      update();
      _logger.info('getAvailableRoutes completed');
    }
  }

  /// Start a new driving simulation
  Future<DriveSimulation?> startSimulation(String routeType, int durationMinutes) async {
    _logger.info('Starting simulation: $routeType, duration: $durationMinutes mins');
    try {
      isLoading.value = true;
      clearError();

      final Map<String, dynamic> data = {
        'routeType': routeType,
        'durationMinutes': durationMinutes,
      };

      // Add wallet address if available
      if (walletAddress.isNotEmpty) {
        data['walletAddress'] = walletAddress.value;
        _logger.debug('Using wallet: ${walletAddress.value}');
      }

      _logger.debug('startSimulation - Sending request with data: $data');
      final response = await _networkService.post(
        '/api/simulations',
        data: data,
      );
      _logger.debug('startSimulation - Response received: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final simulationData = response.data['data'];
        _logger.info('Simulation created with ID: ${simulationData['simulationId']}');

        // Start the timer to update status
        _startSimulationTimer();

        _showSuccessSnackbar('Simulation started successfully');

        // Update status immediately
        _logger.debug('Getting initial simulation status');
        await getSimulationStatus();

        // Return basic simulation data
        return DriveSimulation(
          id: simulationData['simulationId'],
          userId: simulationData['userId'] ?? '',
          routeType: routeType,
          startedAt: DateTime.parse(simulationData['startedAt']),
          dataPointsCount: 0,
          status: SimulationStatus.RUNNING,
          createdAt: DateTime.parse(simulationData['startedAt']),
          updatedAt: DateTime.parse(simulationData['startedAt']),
          walletAddress: walletAddress.value,
        );
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error starting simulation');
        errorMessage.value = errorMsg;
        _logger.error('startSimulation error: $errorMsg');
        _showErrorSnackbar(errorMsg);
        return null;
      }
    } catch (e) {
      _handleException('startSimulation', e);
      return null;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('startSimulation completed');
    }
  }

  /// Get current simulation status
  Future<SimulationStatusModel?> getSimulationStatus() async {
    _logger.debug('Checking simulation status');
    try {
      // Don't activate isLoading here to avoid blocking UI during periodic updates
      clearError();

      final response = await _networkService.get('/api/simulations/status');
      _logger.debug('getSimulationStatus - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final statusData = response.data['data'];
        currentSimulationStatus.value = SimulationStatusModel.fromJson(statusData);
        _logger.debug('isActive: ${currentSimulationStatus.value?.isActive}, simulationId: ${currentSimulationStatus.value?.simulationId}');

        // If simulation is active, update active simulation ID
        if (currentSimulationStatus.value?.isActive == true &&
            currentSimulationStatus.value?.simulationId != null) {
          // Get complete simulation details if needed
          if (activeSimulation.value?.id != currentSimulationStatus.value?.simulationId) {
            _logger.debug('Getting details for active simulation');
            await getSimulationDetail(currentSimulationStatus.value!.simulationId!);
          }
        } else if (currentSimulationStatus.value?.isActive == false) {
          // Stop timer if simulation is not active
          _logger.info('Simulation not active, stopping timer');
          _stopSimulationTimer();
          activeSimulation.value = null;
        }

        return currentSimulationStatus.value;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting simulation status');
        errorMessage.value = errorMsg;
        _logger.error('getSimulationStatus error: $errorMsg');
        return null;
      }
    } catch (e) {
      _handleException('getSimulationStatus', e);
      return null;
    } finally {
      update();
      _logger.debug('getSimulationStatus completed');
    }
  }

  /// Stop current simulation
  Future<bool> stopSimulation() async {
    _logger.info('Stopping active simulation');
    try {
      isLoading.value = true;
      clearError();

      final response = await _networkService.post('/api/simulations/stop');
      _logger.debug('stopSimulation - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        _stopSimulationTimer();
        activeSimulation.value = null;
        currentSimulationStatus.value = null;

        // Update user simulations
        if (walletAddress.isNotEmpty) {
          _logger.debug('Updating user simulations list');
          await getUserSimulations();
        }

        _showSuccessSnackbar('Simulation stopped successfully');
        return true;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error stopping simulation');
        errorMessage.value = errorMsg;
        _logger.error('stopSimulation error: $errorMsg');
        _showErrorSnackbar(errorMsg);
        return false;
      }
    } catch (e) {
      _handleException('stopSimulation', e);
      return false;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('stopSimulation completed');
    }
  }

  /// Get specific simulation details
  Future<DriveSimulation?> getSimulationDetail(String simulationId) async {
    _logger.info('Getting details for simulation: $simulationId');
    try {
      clearError();

      final response = await _networkService.get('/api/simulations/$simulationId');
      _logger.debug('getSimulationDetail - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final simData = response.data['data'];
        final simulation = DriveSimulation.fromJson(simData);
        _logger.info('Simulation found: ${simulation.id}, type: ${simulation.routeType}');

        // If this is the active simulation, update the corresponding variable
        if (currentSimulationStatus.value?.simulationId == simulationId) {
          activeSimulation.value = simulation;
          _logger.debug('Updated as active simulation');
        }

        return simulation;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting simulation details');
        errorMessage.value = errorMsg;
        _logger.error('getSimulationDetail error: $errorMsg');
        return null;
      }
    } catch (e) {
      _handleException('getSimulationDetail', e);
      return null;
    } finally {
      update();
      _logger.info('getSimulationDetail completed');
    }
  }

  /// Get user simulations
  Future<List<DriveSimulation>> getUserSimulations() async {
    _logger.info('Getting simulations for wallet: ${walletAddress.value}');
    try {
      isLoading.value = true;
      clearError();

      if (walletAddress.isEmpty) {
        errorMessage.value = 'Wallet address required';
        _logger.error('getUserSimulations error: Empty wallet address');
        return [];
      }

      final response = await _networkService.get(
        '/api/users/${walletAddress.value}/simulations',
      );
      _logger.debug('getUserSimulations - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final List<dynamic> simulationsData = response.data['data'];
        _logger.info('Simulations found: ${simulationsData.length}');
        userSimulations.value = simulationsData
            .map((sim) => DriveSimulation.fromJson(sim))
            .toList();
        return userSimulations;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting simulations');
        errorMessage.value = errorMsg;
        _logger.error('getUserSimulations error: $errorMsg');
        return [];
      }
    } catch (e) {
      _handleException('getUserSimulations', e);
      return [];
    } finally {
      isLoading.value = false;
      update();
      _logger.info('getUserSimulations completed');
    }
  }

  // REWARDS AND TOKENS METHODS

  /// Generate reward for user for data collected
  Future<Reward?> generateReward(String? simulationId) async {
    _logger.info('Generating reward for simulation: $simulationId');
    try {
      isLoading.value = true;
      clearError();

      if (walletAddress.isEmpty) {
        errorMessage.value = 'Wallet address required to generate rewards';
        _logger.error('generateReward error: Empty wallet address');
        _showErrorSnackbar(errorMessage.value);
        return null;
      }

      final data = {
        'walletAddress': walletAddress.value,
      };

      if (simulationId != null) {
        data['simulationId'] = simulationId;
      }

      _logger.debug('generateReward - Sending request with data: $data');
      final response = await _networkService.post(
        '/api/rewards',
        data: data,
      );
      _logger.debug('generateReward - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final rewardData = response.data['data'];
        _logger.info('Reward generated: ${rewardData['rewardId']}, amount: ${rewardData['amount']}');

        _showSuccessSnackbar(response.data['message'] ?? 'Reward generated successfully');

        // Update token balance
        _logger.debug('Updating token balance');
        await getTokenBalance();

        return Reward(
          id: rewardData['rewardId'] ?? '',
          userId: '',  // No info in response
          amount: rewardData['amount']?.toDouble() ?? 0,
          status: RewardStatus.PROCESSING,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error generating reward');
        errorMessage.value = errorMsg;
        _logger.error('generateReward error: $errorMsg');
        _showErrorSnackbar(errorMsg);
        return null;
      }
    } catch (e) {
      _handleException('generateReward', e);
      return null;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('generateReward completed');
    }
  }

  /// Execute token airdrop (devnet only)
  Future<bool> executeAirdrop(double amount) async {
    _logger.info('Requesting airdrop of $amount tokens');
    try {
      isLoading.value = true;
      clearError();

      if (walletAddress.isEmpty) {
        errorMessage.value = 'Wallet address required for airdrop';
        _logger.error('executeAirdrop error: Empty wallet address');
        _showErrorSnackbar(errorMessage.value);
        return false;
      }

      final data = {
        'walletAddress': walletAddress.value,
        'amount': amount,
      };

      _logger.debug('executeAirdrop - Sending request with data: $data');
      final response = await _networkService.post(
        '/api/airdrops',
        data: data,
      );
      _logger.debug('executeAirdrop - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        _showSuccessSnackbar('Airdrop completed successfully');

        // Update token balance
        _logger.debug('Updating token balance');
        await getTokenBalance();

        return true;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Airdrop error');
        errorMessage.value = errorMsg;
        _logger.error('executeAirdrop error: $errorMsg');
        _showErrorSnackbar(errorMsg);
        return false;
      }
    } catch (e) {
      _handleException('executeAirdrop', e);
      return false;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('executeAirdrop completed');
    }
  }

  /// Get user token balance
  Future<TokenBalance?> getTokenBalance() async {
    _logger.info('Checking balance for wallet: ${walletAddress.value}');
    try {
      isLoading.value = true;
      clearError();

      if (walletAddress.isEmpty) {
        errorMessage.value = 'Wallet address required to check balance';
        _logger.error('getTokenBalance error: Empty wallet address');
        return null;
      }

      final response = await _networkService.get(
        '/api/balances/${walletAddress.value}',
      );
      _logger.debug('getTokenBalance - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final balanceData = response.data['data'];
        tokenBalance.value = TokenBalance.fromJson(balanceData);
        _logger.info('Current balance: ${tokenBalance.value?.balance} ${tokenBalance.value?.tokenSymbol}');
        return tokenBalance.value;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting balance');
        errorMessage.value = errorMsg;
        _logger.error('getTokenBalance error: $errorMsg');
        return null;
      }
    } catch (e) {
      _handleException('getTokenBalance', e);
      return null;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('getTokenBalance completed');
    }
  }

  // MARKETPLACE METHODS

  /// Get available data types in marketplace
  Future<List<DataType>> getDataTypes() async {
    _logger.info('Getting available data types');
    try {
      isLoading.value = true;
      clearError();

      final response = await _networkService.get('/api/marketplace/datatypes');
      _logger.debug('getDataTypes - Response: ${_formatResponseLog(response.data)}');

      if (response.data != null) {
        // Check if the result is successful (different possible formats)
        bool isSuccess = false;
        if (response.data['success'] == true) {
          isSuccess = true;
        } else if (response.data['result'] == 'success') {
          isSuccess = true;
        }

        if (isSuccess && response.data['data'] != null) {
          final List<dynamic> typesData = response.data['data'];
          _logger.info('Data types found: ${typesData.length}');
          dataTypes.value = typesData.map((type) => DataType.fromJson(type)).toList();
          return dataTypes;
        } else {
          // Try to extract a meaningful error message
          String errorMsg = _extractErrorMessage(response.data, 'Error getting data types');
          errorMessage.value = errorMsg;
          _logger.error('getDataTypes error: $errorMsg');
          return [];
        }
      } else {
        errorMessage.value = 'Null response data';
        _logger.error('getDataTypes error: Null response data');
        return [];
      }
    } catch (e) {
      _handleException('getDataTypes', e);
      return [];
    } finally {
      isLoading.value = false;
      update();
      _logger.info('getDataTypes completed');
    }
  }

  /// Create new marketplace listing
  Future<Listing?> createListing({
    required String dataType,
    required double pricePerPoint,
    String? description,
    List<dynamic>? samples,
  }) async {
    _logger.info('Creating listing for type: $dataType, price: $pricePerPoint');
    try {
      isLoading.value = true;
      clearError();

      if (walletAddress.isEmpty) {
        errorMessage.value = 'Wallet address required to create listing';
        _logger.error('createListing error: Empty wallet address');
        _showErrorSnackbar(errorMessage.value);
        return null;
      }

      // Preparar datos asegurando que no se envíen valores nulos donde se esperan strings
      final Map<String, dynamic> data = {
        'walletAddress': walletAddress.value,
        'dataType': dataType,
        'pricePerPoint': pricePerPoint,
      };

      // Solo agregar description si no es nulo
      if (description != null) {
        data['description'] = description;
      } else {
        data['description'] = ''; // Proporcionar un valor predeterminado si es nulo
      }

      // Solo agregar samples si no es nulo
      if (samples != null && samples.isNotEmpty) {
        data['samples'] = samples;
      }

      _logger.debug('createListing - Sending request with data: $data');
      final response = await _networkService.post(
        '/api/marketplace/listings',
        data: data,
      );
      _logger.debug('createListing - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final listingData = response.data['data'];
        final listing = Listing.fromJson(listingData);
        _logger.info('Listing created: ${listing.id}');

        // Update listings
        _logger.debug('Updating marketplace listings');
        await getMarketplaceListings();

        _showSuccessSnackbar('Listing created successfully');
        return listing;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error creating listing');
        errorMessage.value = errorMsg;
        _logger.error('createListing error: $errorMsg');
        _showErrorSnackbar(errorMsg);
        return null;
      }
    } catch (e) {
      _handleException('createListing', e);
      return null;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('createListing completed');
    }
  }

  /// Get marketplace listings with optional filters
  Future<List<Listing>> getMarketplaceListings({
    String? seller,
    String? dataType,
    bool? active,
    double? maxPrice,
    double? minRating,
  }) async {
    _logger.info('Getting marketplace listings');
    try {
      isLoading.value = true;
      clearError();

      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      if (seller != null) queryParams['seller'] = seller;
      if (dataType != null) queryParams['dataType'] = dataType;
      if (active != null) queryParams['active'] = active.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (minRating != null) queryParams['minRating'] = minRating.toString();

      _logger.debug('getMarketplaceListings - Parameters: $queryParams');

      final response = await _networkService.get(
        '/api/marketplace/listings',
        queryParameters: queryParams,
      );

      _logger.debug('getMarketplaceListings - Status: ${response.statusCode}');
      _logger.debug('getMarketplaceListings - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final List<dynamic> listingsData = response.data['data'];
        _logger.info('Listings found: ${listingsData.length}');

        marketplaceListings.value = listingsData.map((listing) => Listing.fromJson(listing)).toList();
        _logger.debug('Parsed listings count: ${marketplaceListings.length}');

        return marketplaceListings;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting listings');
        errorMessage.value = errorMsg;
        _logger.error('getMarketplaceListings error: $errorMsg');
        return [];
      }
    } catch (e) {
      _handleException('getMarketplaceListings', e);
      return [];
    } finally {
      isLoading.value = false;
      update();
      _logger.info('getMarketplaceListings completed');
    }
  }

  /// Get specific listing details
  Future<Listing?> getListingDetail(String listingId) async {
    _logger.info('Getting details for listing: $listingId');
    try {
      isLoading.value = true;
      clearError();

      final response = await _networkService.get(
        '/api/marketplace/listings/$listingId',
      );
      _logger.debug('getListingDetail - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final listingData = response.data['data'];
        final listing = Listing.fromJson(listingData);
        _logger.info('Listing found: ${listing.id}, seller: ${listing.seller}');
        return listing;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting listing details');
        errorMessage.value = errorMsg;
        _logger.error('getListingDetail error: $errorMsg');
        return null;
      }
    } catch (e) {
      _handleException('getListingDetail', e);
      return null;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('getListingDetail completed');
    }
  }

  /// Update existing listing
  Future<Listing?> updateListing(
      String listingId, {
        double? pricePerPoint,
        String? description,
        bool? active,
      }) async {
    _logger.info('Updating listing: $listingId');
    try {
      isLoading.value = true;
      clearError();

      final Map<String, dynamic> updates = {};
      if (pricePerPoint != null) updates['pricePerPoint'] = pricePerPoint;
      if (description != null) updates['description'] = description;
      if (active != null) updates['active'] = active;

      _logger.debug('updateListing - Update data: $updates');
      final response = await _networkService.put(
        '/api/marketplace/listings/$listingId',
        data: updates,
      );
      _logger.debug('updateListing - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final listingData = response.data['data'];
        final listing = Listing.fromJson(listingData);
        _logger.info('Listing updated: ${listing.id}');

        // Update listings
        _logger.debug('Updating marketplace listings');
        await getMarketplaceListings();

        _showSuccessSnackbar('Listing updated successfully');
        return listing;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error updating listing');
        errorMessage.value = errorMsg;
        _logger.error('updateListing error: $errorMsg');
        _showErrorSnackbar(errorMsg);
        return null;
      }
    } catch (e) {
      _handleException('updateListing', e);
      return null;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('updateListing completed');
    }
  }

  /// Create subscription to a listing
  Future<Map<String, dynamic>?> createSubscription({
    required String listingId,
    required int durationDays,
    required int pointsPerDay,
  }) async {
    _logger.info('Creating subscription for listing: $listingId, duration: $durationDays days, points: $pointsPerDay/day');
    try {
      isLoading.value = true;
      clearError();

      if (walletAddress.isEmpty) {
        errorMessage.value = 'Wallet address required to subscribe';
        _logger.error('createSubscription error: Empty wallet address');
        _showErrorSnackbar(errorMessage.value);
        return null;
      }

      final data = {
        'buyerWalletAddress': walletAddress.value,
        'listingId': listingId,
        'durationDays': durationDays,
        'pointsPerDay': pointsPerDay,
      };

      _logger.debug('createSubscription - Sending request with data: $data');
      final response = await _networkService.post(
        '/api/marketplace/subscriptions',
        data: data,
      );
      _logger.debug('createSubscription - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final subData = response.data['data']['subscription'];
        final txData = response.data['data']['transaction'];
        _logger.info('Subscription created: ${subData['id']}, transaction: ${txData['id']}');

        final subscription = Subscription.fromJson(subData);

        _showSuccessSnackbar('Subscription created. Please confirm the transaction in your wallet');

        // Return both subscription and transaction
        return {
          'subscription': subscription,
          'transaction': txData,
          'encodedTransaction': txData['encodedTransaction'],
          'transactionId': txData['id'],
        };
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error creating subscription');
        errorMessage.value = errorMsg;
        _logger.error('createSubscription error: $errorMsg');
        _showErrorSnackbar(errorMsg);
        return null;
      }
    } catch (e) {
      _handleException('createSubscription', e);
      return null;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('createSubscription completed');
    }
  }

  /// Confirm marketplace transaction
  Future<bool> confirmTransaction(String transactionId, String txHash) async {
    _logger.info('Confirming transaction: $transactionId, hash: $txHash');
    try {
      isLoading.value = true;
      clearError();

      final data = {
        'txHash': txHash,
      };

      _logger.debug('confirmTransaction - Sending request with data: $data');
      final response = await _networkService.post(
        '/api/marketplace/transactions/$transactionId/confirm',
        data: data,
      );
      _logger.debug('confirmTransaction - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        _showSuccessSnackbar('Transaction confirmed successfully');

        // Update subscriptions and transactions
        if (walletAddress.isNotEmpty) {
          _logger.debug('Updating subscriptions and transactions');
          await getUserSubscriptions();
          await getUserTransactions();
        }

        return true;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error confirming transaction');
        errorMessage.value = errorMsg;
        _logger.error('confirmTransaction error: $errorMsg');
        _showErrorSnackbar(errorMsg);
        return false;
      }
    } catch (e) {
      _handleException('confirmTransaction', e);
      return false;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('confirmTransaction completed');
    }
  }

  /// Rate a data provider
  Future<bool> rateDataProvider(String subscriptionId, double rating, {String? comment}) async {
    _logger.info('Rating subscription: $subscriptionId, rating: $rating');
    try {
      isLoading.value = true;
      clearError();

      final data = {
        'rating': rating,
      };

      if (comment != null) {
        data['comment'] = comment as dynamic;
      }

      _logger.debug('rateDataProvider - Sending request with data: $data');
      final response = await _networkService.post(
        '/api/marketplace/subscriptions/$subscriptionId/rate',
        data: data,
      );
      _logger.debug('rateDataProvider - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        _showSuccessSnackbar('Rating submitted successfully');

        // Update subscriptions
        if (walletAddress.isNotEmpty) {
          _logger.debug('Updating subscriptions');
          await getUserSubscriptions();
        }

        return true;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error rating provider');
        errorMessage.value = errorMsg;
        _logger.error('rateDataProvider error: $errorMsg');
        _showErrorSnackbar(errorMsg);
        return false;
      }
    } catch (e) {
      _handleException('rateDataProvider', e);
      return false;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('rateDataProvider completed');
    }
  }

  /// Get user transactions
  Future<List<Transaction>> getUserTransactions() async {
    _logger.info('Getting transactions for wallet: ${walletAddress.value}');
    try {
      isLoading.value = true;
      clearError();

      if (walletAddress.isEmpty) {
        errorMessage.value = 'Wallet address required';
        _logger.error('getUserTransactions error: Empty wallet address');
        return [];
      }

      final response = await _networkService.get(
        '/api/marketplace/users/${walletAddress.value}/transactions',
      );
      _logger.debug('getUserTransactions - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final List<dynamic> txData = response.data['data'];
        _logger.info('Transactions found: ${txData.length}');
        userTransactions.value = txData.map((tx) => Transaction.fromJson(tx)).toList();
        return userTransactions;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting transactions');
        errorMessage.value = errorMsg;
        _logger.error('getUserTransactions error: $errorMsg');
        return [];
      }
    } catch (e) {
      _handleException('getUserTransactions', e);
      return [];
    } finally {
      isLoading.value = false;
      update();
      _logger.info('getUserTransactions completed');
    }
  }

  /// Get user subscriptions
  Future<List<Subscription>> getUserSubscriptions() async {
    _logger.info('Getting subscriptions for wallet: ${walletAddress.value}');
    try {
      isLoading.value = true;
      clearError();

      if (walletAddress.isEmpty) {
        errorMessage.value = 'Wallet address required';
        _logger.error('getUserSubscriptions error: Empty wallet address');
        return [];
      }

      final response = await _networkService.get(
        '/api/marketplace/users/${walletAddress.value}/subscriptions',
      );
      _logger.debug('getUserSubscriptions - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final List<dynamic> subData = response.data['data'];
        _logger.info('Subscriptions found: ${subData.length}');
        userSubscriptions.value = subData.map((sub) => Subscription.fromJson(sub)).toList();
        return userSubscriptions;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting subscriptions');
        errorMessage.value = errorMsg;
        _logger.error('getUserSubscriptions error: $errorMsg');
        return [];
      }
    } catch (e) {
      _handleException('getUserSubscriptions', e);
      return [];
    } finally {
      isLoading.value = false;
      update();
      _logger.info('getUserSubscriptions completed');
    }
  }

  /// Estimate data value
  Future<DataValueEstimate?> estimateDataValue(List<dynamic> dataPoints, {String? dataType}) async {
    _logger.info('Estimating value for ${dataPoints.length} data points, type: $dataType');
    try {
      isLoading.value = true;
      clearError();

      final data = {
        'dataPoints': dataPoints,
      };

      if (dataType != null) {
        data['dataType'] = dataType as dynamic;
      }

      _logger.debug('estimateDataValue - Sending request with data: ${data['dataPoints']?.length} points');
      final response = await _networkService.post(
        '/api/marketplace/estimate-value',
        data: data,
      );
      _logger.debug('estimateDataValue - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final estimateData = response.data['data'];
        final estimate = DataValueEstimate.fromJson(estimateData);
        _logger.info('Estimated value: ${estimate.estimatedValue}');
        return estimate;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error estimating data value');
        errorMessage.value = errorMsg;
        _logger.error('estimateDataValue error: $errorMsg');
        return null;
      }
    } catch (e) {
      _handleException('estimateDataValue', e);
      return null;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('estimateDataValue completed');
    }
  }

  /// Get marketplace statistics
  Future<MarketStatistics?> getMarketplaceStatistics() async {
    _logger.info('Getting marketplace statistics');
    try {
      isLoading.value = true;
      clearError();

      final response = await _networkService.get('/api/marketplace/statistics');
      _logger.debug('getMarketplaceStatistics - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final statsData = response.data['data'];
        marketStatistics.value = MarketStatistics.fromJson(statsData);
        _logger.info('Statistics: Active listings: ${marketStatistics.value?.activeListings}, Transactions: ${marketStatistics.value?.totalTransactions}');
        return marketStatistics.value;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting statistics');
        errorMessage.value = errorMsg;
        _logger.error('getMarketplaceStatistics error: $errorMsg');
        return null;
      }
    } catch (e) {
      _handleException('getMarketplaceStatistics', e);
      return null;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('getMarketplaceStatistics completed');
    }
  }

  // DIAGNOSTIC METHODS

  /// Get diagnostic code information
  Future<DiagnosticCode?> getDiagnosticInfo(String code) async {
    _logger.info('Getting information for diagnostic code: $code');
    try {
      isLoading.value = true;
      clearError();

      final response = await _networkService.get('/api/diagnostics/$code');
      _logger.debug('getDiagnosticInfo - Response: ${_formatResponseLog(response.data)}');

      if (_isSuccessResponse(response.data)) {
        final codeData = response.data['data'];
        final diagnostic = DiagnosticCode.fromJson(codeData);
        _logger.info('Diagnostic: ${diagnostic.code}, Description: ${diagnostic.description}');
        return diagnostic;
      } else {
        String errorMsg = _extractErrorMessage(response.data, 'Error getting diagnostic info');
        errorMessage.value = errorMsg;
        _logger.error('getDiagnosticInfo error: $errorMsg');
        return null;
      }
    } catch (e) {
      _handleException('getDiagnosticInfo', e);
      return null;
    } finally {
      isLoading.value = false;
      update();
      _logger.info('getDiagnosticInfo completed');
    }
  }

  // HELPER METHODS

  // Format response data for logging (limit large data)
  String _formatResponseLog(dynamic data) {
    if (data == null) return 'null';

    if (data is Map) {
      // Create a copy of the map to modify
      final Map<String, dynamic> cleanData = {};

      // Process each key in the map
      data.forEach((key, value) {
        if (value is List && value.length > 10) {
          cleanData[key] = '[List with ${value.length} items]';
        } else if (value is String && value.length > 500) {
          cleanData[key] = '${value.substring(0, 100)}... [${value.length} chars]';
        } else if (value is Map && value.length > 10) {
          cleanData[key] = '{Map with ${value.length} entries}';
        } else {
          cleanData[key] = value;
        }
      });

      return cleanData.toString();
    }

    if (data is List && data.length > 10) {
      return '[List with ${data.length} items]';
    }

    return data.toString();
  }

  // Check if response indicates success
  bool _isSuccessResponse(dynamic data) {
    if (data == null) return false;

    // Check both common success formats
    return (data['success'] == true) || (data['result'] == 'success');
  }

  // Extract meaningful error message from response
  String _extractErrorMessage(dynamic data, String defaultMessage) {
    if (data == null) return defaultMessage;

    if (data['message'] != null && data['message'] is String) {
      return data['message'];
    } else if (data['error'] != null && data['error'] is String) {
      return data['error'];
    }

    return defaultMessage;
  }

  // Handle and log exceptions
  void _handleException(String method, dynamic exception) {
    final errorMsg = 'Error: $exception';
    errorMessage.value = errorMsg;
    _logger.error('$method exception: $exception');

    // Extraer información adicional del error si está disponible
    String stackTrace = '';
    if (exception is Error && exception.stackTrace != null) {
      stackTrace = '\nStack trace: ${exception.stackTrace}';
      _logger.error('$method stack trace: $stackTrace');
    }

    // Mostrar mensaje más detallado en modo desarrollo, pero mensaje simplificado para usuario
    _showErrorSnackbar('Error processing request. Please try again.');
  }

  // Show success snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}