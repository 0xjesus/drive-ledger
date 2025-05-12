// lib/controllers/controller_bindings.dart

import 'package:get/get.dart';
import 'drive_ledger_controller.dart';
import 'phantom_wallet_controller.dart';

class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize controllers with Get.put
    Get.put(PhantomWalletController(), permanent: true);
    Get.put(DriveLedgerController(), permanent: true);
  }
}