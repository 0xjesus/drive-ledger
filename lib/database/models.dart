// lib/models/user_model.dart
class User {
  final String id;
  final String walletAddress;
  final String? username;
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.walletAddress,
    this.username,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      walletAddress: json['walletAddress'],
      username: json['username'],
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletAddress': walletAddress,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// lib/models/simulation_route_model.dart
class SimulationRoute {
  final String id;
  final String? routeType;  // Cambiado a nullable
  final String name;
  final String description;
  final double averageSpeed;
  final double maxSpeed;
  final String trafficDensity;
  final double distance;
  final int estimatedTime;
  final String fuelConsumption;
  final String elevationChange;
  final DateTime createdAt;
  final DateTime updatedAt;

  SimulationRoute({
    required this.id,
    this.routeType,  // Ya no required
    required this.name,
    required this.description,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.trafficDensity,
    required this.distance,
    required this.estimatedTime,
    required this.fuelConsumption,
    required this.elevationChange,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SimulationRoute.fromJson(Map<String, dynamic> json) {
    return SimulationRoute(
      id: json['id'] ?? '',
      routeType: json['routeType'] ?? 'UNKNOWN',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      averageSpeed: (json['averageSpeed'] ?? 0).toDouble(),
      maxSpeed: (json['maxSpeed'] ?? 0).toDouble(),
      trafficDensity: json['trafficDensity'] ?? 'medium',
      distance: (json['distance'] ?? 0).toDouble(),
      estimatedTime: json['estimatedTime'] ?? 0,
      fuelConsumption: json['fuelConsumption'] ?? 'moderate',
      elevationChange: json['elevationChange'] ?? 'low',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeType': routeType,
      'name': name,
      'description': description,
      'averageSpeed': averageSpeed,
      'maxSpeed': maxSpeed,
      'trafficDensity': trafficDensity,
      'distance': distance,
      'estimatedTime': estimatedTime,
      'fuelConsumption': fuelConsumption,
      'elevationChange': elevationChange,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
// lib/models/simulation_model.dart
enum SimulationStatus { RUNNING, COMPLETED, FAILED, CANCELLED }

class DriveSimulation {
  final String id;
  final String userId;
  final String routeType;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? durationMinutes;
  final double? distanceKm;
  final double? avgSpeedKmph;
  final double? maxSpeedKmph;
  final int? efficiencyScore;
  final int dataPointsCount;
  final Map<String, dynamic>? rawData;
  final Map<String, dynamic>? diagnosticIssues;
  final SimulationStatus status;
  final List<Reward>? rewards;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? walletAddress;

  DriveSimulation({
    required this.id,
    required this.userId,
    required this.routeType,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes,
    this.distanceKm,
    this.avgSpeedKmph,
    this.maxSpeedKmph,
    this.efficiencyScore,
    required this.dataPointsCount,
    this.rawData,
    this.diagnosticIssues,
    required this.status,
    this.rewards,
    required this.createdAt,
    required this.updatedAt,
    this.walletAddress,
  });

  factory DriveSimulation.fromJson(Map<String, dynamic> json) {
    List<Reward>? rewardsList;
    if (json['rewards'] != null) {
      rewardsList = List<Reward>.from(
          json['rewards'].map((x) => Reward.fromJson(x)));
    }

    return DriveSimulation(
      id: json['id'],
      userId: json['userId'],
      routeType: json['routeType'],
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      durationMinutes: json['durationMinutes']?.toDouble(),
      distanceKm: json['distanceKm']?.toDouble(),
      avgSpeedKmph: json['avgSpeedKmph']?.toDouble(),
      maxSpeedKmph: json['maxSpeedKmph']?.toDouble(),
      efficiencyScore: json['efficiencyScore'],
      dataPointsCount: json['dataPointsCount'],
      rawData: json['rawData'],
      diagnosticIssues: json['diagnosticIssues'],
      status: SimulationStatus.values.firstWhere(
              (e) => e.toString() == 'SimulationStatus.${json['status']}'),
      rewards: rewardsList,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      walletAddress: json['walletAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'routeType': routeType,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'distanceKm': distanceKm,
      'avgSpeedKmph': avgSpeedKmph,
      'maxSpeedKmph': maxSpeedKmph,
      'efficiencyScore': efficiencyScore,
      'dataPointsCount': dataPointsCount,
      'rawData': rawData,
      'diagnosticIssues': diagnosticIssues,
      'status': status.toString().split('.').last,
      'rewards': rewards?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'walletAddress': walletAddress,
    };
  }
}

// lib/models/simulation_status_model.dart
class SimulationStatusModel {
  final bool isActive;
  final String? route;
  final double? elapsedTime;
  final double? elapsedMinutes;
  final int? dataPoints;
  final double? progress;  // Cambiado de int? a double?
  final double? distanceCovered;
  final double? averageSpeed;
  final Map<String, dynamic>? currentData;
  final String? simulationId;
  final String message;

  SimulationStatusModel({
    required this.isActive,
    this.route,
    this.elapsedTime,
    this.elapsedMinutes,
    this.dataPoints,
    this.progress,
    this.distanceCovered,
    this.averageSpeed,
    this.currentData,
    this.simulationId,
    required this.message,
  });

  factory SimulationStatusModel.fromJson(Map<String, dynamic> json) {
    return SimulationStatusModel(
      isActive: json['isActive'] ?? false,  // Valor por defecto para evitar null
      route: json['route'],
      elapsedTime: _toDouble(json['elapsedTime']),
      elapsedMinutes: _toDouble(json['elapsedMinutes']),
      dataPoints: json['dataPoints'],
      progress: _toDouble(json['progress']),  // Usar _toDouble para progress
      distanceCovered: _toDouble(json['distanceCovered']),
      averageSpeed: _toDouble(json['averageSpeed']),
      currentData: json['currentData'],
      simulationId: json['simulationId'],
      message: json['message'] ?? '',  // Valor por defecto para evitar null
    );
  }

  // Método auxiliar para convertir diversos tipos numéricos a double
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'route': route,
      'elapsedTime': elapsedTime,
      'elapsedMinutes': elapsedMinutes,
      'dataPoints': dataPoints,
      'progress': progress,
      'distanceCovered': distanceCovered,
      'averageSpeed': averageSpeed,
      'currentData': currentData,
      'simulationId': simulationId,
      'message': message,
    };
  }
}

// lib/models/reward_model.dart
enum RewardStatus { PENDING, PROCESSING, COMPLETED, FAILED }

class Reward {
  final String id;
  final String userId;
  final String? simulationId;
  final double amount;
  final String? transactionHash;
  final String? encodedTransaction;
  final RewardStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reward({
    required this.id,
    required this.userId,
    this.simulationId,
    required this.amount,
    this.transactionHash,
    this.encodedTransaction,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      userId: json['userId'],
      simulationId: json['simulationId'],
      amount: json['amount'].toDouble(),
      transactionHash: json['transactionHash'],
      encodedTransaction: json['encodedTransaction'],
      status: RewardStatus.values.firstWhere(
              (e) => e.toString() == 'RewardStatus.${json['status']}'),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'simulationId': simulationId,
      'amount': amount,
      'transactionHash': transactionHash,
      'encodedTransaction': encodedTransaction,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// lib/models/token_balance_model.dart
class TokenBalance {
  final String address;
  final double balance;
  final String? token;
  final String? tokenSymbol;
  final int? decimals;
  final DateTime? lastUpdated;
  final bool success;

  TokenBalance({
    required this.address,
    required this.balance,
    this.token,
    this.tokenSymbol,
    this.decimals,
    this.lastUpdated,
    required this.success,
  });

  factory TokenBalance.fromJson(Map<String, dynamic> json) {
    return TokenBalance(
      address: json['address'],
      balance: json['balance'].toDouble(),
      token: json['token'],
      tokenSymbol: json['tokenSymbol'],
      decimals: json['decimals'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'balance': balance,
      'token': token,
      'tokenSymbol': tokenSymbol,
      'decimals': decimals,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'success': success,
    };
  }
}

// lib/models/data_type_model.dart
class DataType {
  final String id;
  final String name;
  final String description;
  final String privacyImpact;
  final double baseValue;

  DataType({
    required this.id,
    required this.name,
    required this.description,
    required this.privacyImpact,
    required this.baseValue,
  });

  factory DataType.fromJson(Map<String, dynamic> json) {
    return DataType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      privacyImpact: json['privacyImpact'],
      baseValue: json['baseValue'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'privacyImpact': privacyImpact,
      'baseValue': baseValue,
    };
  }
}

// lib/models/listing_model.dart
class Listing {
  final String id;
  final String seller;
  final String dataType;
  final String typeName;
  final String? typeDescription;
  final String privacyImpact;
  final double pricePerPoint;
  final String? description;
  final List<dynamic>? samples;
  final bool active;
  final int purchaseCount;
  final double? avgRating;
  final int ratingCount;
  final int? subscriptionCount;
  final List<dynamic>? recentSubscriptions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Listing({
    required this.id,
    required this.seller,
    required this.dataType,
    required this.typeName,
    this.typeDescription,
    required this.privacyImpact,
    required this.pricePerPoint,
    this.description,
    this.samples,
    required this.active,
    required this.purchaseCount,
    this.avgRating,
    required this.ratingCount,
    this.subscriptionCount,
    this.recentSubscriptions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    // Ensure non-nullable fields have default values if missing
    return Listing(
      id: json['id'] ?? '',
      seller: json['seller'] ?? '',
      dataType: json['dataType'] ?? '',
      typeName: json['typeName'] ?? '',
      typeDescription: json['typeDescription'],
      privacyImpact: json['privacyImpact'] ?? 'medium',
      pricePerPoint: (json['pricePerPoint'] ?? 0.0).toDouble(),
      description: json['description'],
      samples: json['samples'],
      active: json['active'] ?? false,
      purchaseCount: json['purchaseCount'] ?? 0,
      avgRating: json['avgRating']?.toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      subscriptionCount: json['subscriptionCount'],
      recentSubscriptions: json['recentSubscriptions'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller': seller,
      'dataType': dataType,
      'typeName': typeName,
      'typeDescription': typeDescription,
      'privacyImpact': privacyImpact,
      'pricePerPoint': pricePerPoint,
      'description': description,
      'samples': samples,
      'active': active,
      'purchaseCount': purchaseCount,
      'avgRating': avgRating,
      'ratingCount': ratingCount,
      'subscriptionCount': subscriptionCount,
      'recentSubscriptions': recentSubscriptions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
// lib/models/subscription_model.dart
enum SubscriptionStatus { PENDING, ACTIVE, EXPIRED, CANCELLED }

class Subscription {
  final String id;
  final String buyer;
  final String seller;
  final String listingId;
  final String? transactionId;
  final int pointsPerDay;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final SubscriptionStatus status;
  final List<Rating>? ratings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? isSubscriber;
  final bool? isProvider;

  Subscription({
    required this.id,
    required this.buyer,
    required this.seller,
    required this.listingId,
    this.transactionId,
    required this.pointsPerDay,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.ratings,
    required this.createdAt,
    required this.updatedAt,
    this.isSubscriber,
    this.isProvider,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    List<Rating>? ratingsList;
    if (json['ratings'] != null) {
      ratingsList = List<Rating>.from(json['ratings'].map((x) => Rating.fromJson(x)));
    }

    return Subscription(
      id: json['id'],
      buyer: json['buyerId'] ?? json['buyer'] ?? '', // Handle both potential field names
      seller: json['sellerId'] ?? json['seller'] ?? '', // Handle both potential field names
      listingId: json['listingId'],
      transactionId: json['transactionId'],
      pointsPerDay: json['pointsPerDay'],
      durationDays: json['durationDays'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalPrice: json['totalPrice'].toDouble(),
      status: SubscriptionStatus.values.firstWhere(
              (e) => e.toString() == 'SubscriptionStatus.${json['status']}'),
      ratings: ratingsList,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSubscriber: json['isSubscriber'],
      isProvider: json['isProvider'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer': buyer,
      'seller': seller,
      'listingId': listingId,
      'transactionId': transactionId,
      'pointsPerDay': pointsPerDay,
      'durationDays': durationDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'ratings': ratings?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSubscriber': isSubscriber,
      'isProvider': isProvider,
    };
  }
}

// lib/models/transaction_model.dart
enum TransactionType { SUBSCRIPTION, REWARD, TRANSFER, AIRDROP }
enum TransactionStatus { PENDING, PROCESSING, COMPLETED, FAILED }

class Transaction {
  final String id;
  final TransactionType type;
  final String sender;
  final String receiver;
  final String? listingId;
  final double amount;
  final int? pointsCount;
  final TransactionStatus status;
  final String? blockchainTxHash;
  final String? encodedTransaction;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime updatedAt;
  final bool? isSender;
  final bool? isReceiver;

  Transaction({
    required this.id,
    required this.type,
    required this.sender,
    required this.receiver,
    this.listingId,
    required this.amount,
    this.pointsCount,
    required this.status,
    this.blockchainTxHash,
    this.encodedTransaction,
    required this.createdAt,
    this.completedAt,
    required this.updatedAt,
    this.isSender,
    this.isReceiver,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: TransactionType.values.firstWhere(
              (e) => e.toString() == 'TransactionType.${json['type']}'),
      sender: json['sender'],
      receiver: json['receiver'],
      listingId: json['listingId'],
      amount: json['amount'].toDouble(),
      pointsCount: json['pointsCount'],
      status: TransactionStatus.values.firstWhere(
              (e) => e.toString() == 'TransactionStatus.${json['status']}'),
      blockchainTxHash: json['blockchainTxHash'],
      encodedTransaction: json['encodedTransaction'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt:
      json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      updatedAt: DateTime.parse(json['updatedAt']),
      isSender: json['isSender'],
      isReceiver: json['isReceiver'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'sender': sender,
      'receiver': receiver,
      'listingId': listingId,
      'amount': amount,
      'pointsCount': pointsCount,
      'status': status.toString().split('.').last,
      'blockchainTxHash': blockchainTxHash,
      'encodedTransaction': encodedTransaction,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSender': isSender,
      'isReceiver': isReceiver,
    };
  }
}

// lib/models/rating_model.dart
class Rating {
  final String id;
  final double value;
  final String? comment;
  final String subscriptionId;
  final String giverId;
  final String receiverId;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.value,
    this.comment,
    required this.subscriptionId,
    required this.giverId,
    required this.receiverId,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      value: json['value'].toDouble(),
      comment: json['comment'],
      subscriptionId: json['subscriptionId'],
      giverId: json['giverId'],
      receiverId: json['receiverId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'comment': comment,
      'subscriptionId': subscriptionId,
      'giverId': giverId,
      'receiverId': receiverId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// lib/models/diagnostic_code_model.dart
class DiagnosticCode {
  final String id;
  final String code;
  final String description;
  final String severity;
  final String impact;
  final double rewardImpact;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiagnosticCode({
    required this.id,
    required this.code,
    required this.description,
    required this.severity,
    required this.impact,
    required this.rewardImpact,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiagnosticCode.fromJson(Map<String, dynamic> json) {
    return DiagnosticCode(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      severity: json['severity'],
      impact: json['impact'],
      rewardImpact: json['rewardImpact'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'severity': severity,
      'impact': impact,
      'rewardImpact': rewardImpact,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// lib/models/market_statistics_model.dart
class MarketStatistics {
  final int totalUsers;
  final int totalListings;
  final int activeListings;
  final int totalSubscriptions;
  final int totalTransactions;
  final int completedTransactions;
  final double totalValueTraded;
  final double? averageRating;
  final int totalRatings;
  final Map<String, dynamic> typeDistribution;
  final DateTime lastUpdated;

  MarketStatistics({
    required this.totalUsers,
    required this.totalListings,
    required this.activeListings,
    required this.totalSubscriptions,
    required this.totalTransactions,
    required this.completedTransactions,
    required this.totalValueTraded,
    this.averageRating,
    required this.totalRatings,
    required this.typeDistribution,
    required this.lastUpdated,
  });

  factory MarketStatistics.fromJson(Map<String, dynamic> json) {
    return MarketStatistics(
      totalUsers: json['totalUsers'],
      totalListings: json['totalListings'],
      activeListings: json['activeListings'],
      totalSubscriptions: json['totalSubscriptions'],
      totalTransactions: json['totalTransactions'],
      completedTransactions: json['completedTransactions'],
      totalValueTraded: json['totalValueTraded'].toDouble(),
      averageRating: json['averageRating']?.toDouble(),
      totalRatings: json['totalRatings'],
      typeDistribution: json['typeDistribution'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalListings': totalListings,
      'activeListings': activeListings,
      'totalSubscriptions': totalSubscriptions,
      'totalTransactions': totalTransactions,
      'completedTransactions': completedTransactions,
      'totalValueTraded': totalValueTraded,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'typeDistribution': typeDistribution,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

// lib/models/data_value_estimate_model.dart
class DataValueEstimate {
  final double estimatedValue;
  final String dataType;
  final int dataPointsCount;

  DataValueEstimate({
    required this.estimatedValue,
    required this.dataType,
    required this.dataPointsCount,
  });

  factory DataValueEstimate.fromJson(Map<String, dynamic> json) {
    return DataValueEstimate(
      estimatedValue: json['estimatedValue'].toDouble(),
      dataType: json['dataType'],
      dataPointsCount: json['dataPointsCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimatedValue': estimatedValue,
      'dataType': dataType,
      'dataPointsCount': dataPointsCount,
    };
  }
}

// lib/models/api_response_model.dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? status;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.status,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      success: json['success'],
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T?) toJson) {
    return {
      'success': success,
      'data': data != null ? toJson(data) : null,
      'message': message,
      'status': status,
    };
  }
}