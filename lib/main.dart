// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/app_theme.dart';
import 'routes/routes.dart';
import 'controllers/drive_ledger_controller.dart';
import 'controllers/phantom_wallet_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Load environment variables
  await dotenv.load(fileName: ".env").catchError((e) {
    debugPrint("Error loading .env file: $e");
    // Continue even if .env file is missing
  });

  // Initialize GetX controllers
  Get.put(PhantomWalletController(), permanent: true);
  Get.put(DriveLedgerController(), permanent: true);

  // Run the app
  runApp(const DriveLedgerApp());
}

class DriveLedgerApp extends StatelessWidget {
  const DriveLedgerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Drive-Ledger',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.darkTheme(),
      darkTheme: AppTheme.darkTheme(),
      initialRoute: Routes.SPLASH,
      getPages: Routes.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}