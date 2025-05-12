// lib/routes/routes.dart

import 'package:drive_ledger/screens/market_place_screen.dart';
import 'package:drive_ledger/screens/wallet_screen.dart';
import 'package:drive_ledger/screens/welcome_screen.dart';
import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/simulations_screen.dart';
import '../screens/settings_screen.dart';

class Routes {
  // Define route names
  static const String SPLASH = '/splash';
  static const String WELCOME = '/welcome';
  static const String HOME = '/home';
  static const String SIMULATIONS = '/simulations';
  static const String WALLET = '/wallet';
  static const String MARKETPLACE = '/marketplace';
  static const String SETTINGS = '/settings';
  static const String STATS = '/stats';

  // Define routes
  static final List<GetPage> pages = [
    GetPage(
      name: SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: WELCOME,
      page: () => const WelcomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: HOME,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: SIMULATIONS,
      page: () => const SimulationsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: WALLET,
      page: () => const WalletScreen(), // Placeholder - replace with actual screen
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: MARKETPLACE,
      page: () => const MarketplaceScreen(), // Placeholder - replace with actual screen
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: SETTINGS,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: STATS,
      page: () => const HomeScreen(), // Placeholder - replace with actual screen
      transition: Transition.rightToLeft,
    ),
  ];
}