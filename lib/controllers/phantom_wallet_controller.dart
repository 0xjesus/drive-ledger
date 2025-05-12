// lib/controllers/phantom_wallet_controller.dart

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drive_ledger/services/network_service.dart';
import 'package:pinenacl/x25519.dart' show Box, PrivateKey, PublicKey;
import 'package:pinenacl/api.dart'
    show
        ByteList,
        ByteListExtension,
        EncryptedMessage,
        IntListExtension,
        PineNaClUtils;
import 'package:bs58/bs58.dart' as bs58;
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:drive_ledger/database/models.dart';

class PhantomWalletController extends GetxController {
  // Connection states
  final RxBool isConnected = false.obs;
  final RxBool isLoading = false.obs;
  final RxString walletAddress = ''.obs;
  final RxDouble walletBalance = 0.0.obs;

  // Transaction states
  final RxString transactionSignature = ''.obs;
  final RxString statusMessage = ''.obs;
  final RxList<String> logs = <String>[].obs;

  // Phantom connection objects
  PrivateKey? dappPrivateKey;
  PublicKey? dappPublicKey;
  Box? box;
  String? session;
  String? phantomPublicKey;
  AppLinks? _appLinks;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final NetworkService _networkService = NetworkService();

  // App scheme for deep linking
  static const String appScheme = 'driveledger';

  @override
  void onInit() {
    super.onInit();
    _initializeWallet();
    _initDeepLinks();
    _checkPersistedConnection();
  }

  Future<void> _initializeWallet() async {
    // Generate key pair for encryption
    dappPrivateKey = PrivateKey.generate();
    dappPublicKey = dappPrivateKey!.publicKey;
    addLog('Wallet controller initialized with new keys');
  }

  Future<void> _checkPersistedConnection() async {
    final savedAddress = await _secureStorage.read(key: 'wallet_address');
    final savedSession = await _secureStorage.read(key: 'wallet_session');
    final phantomPubKeyStr = await _secureStorage.read(key: 'phantom_public_key');

    if (savedAddress != null && savedSession != null && phantomPubKeyStr != null) {
      try {
        walletAddress.value = savedAddress;
        session = savedSession;

        // Recuperar clave pública y reinicializar box
        Uint8List phantomPublicKeyBytes = bs58.base58.decode(phantomPubKeyStr);
        PublicKey phantomPubKey = PublicKey(phantomPublicKeyBytes);
        box = Box(myPrivateKey: dappPrivateKey!, theirPublicKey: phantomPubKey);

        isConnected.value = true;
        addLog('Restored previous wallet connection: $savedAddress');

        // Also fetch the balance
        await getWalletBalance();
      } catch (e) {
        addLog('Error restoring connection: $e');
        // Limpiar datos incorrectos
        await disconnectWallet();
      }
    }
  }
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle initial link
    final uri = await _appLinks!.getInitialAppLink();
    if (uri != null) {
      _handleDeepLink(uri);
    }

    // Listen for links
    _appLinks!.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (error) {
      addLog('Deep link error: $error');
    });
  }

  void addLog(String message) {
    final timestamp = DateTime.now().toString().split('.')[0];
    logs.add('[$timestamp] $message');
    debugPrint('PhantomWallet: $message');
  }

  void _handleDeepLink(Uri uri) {
    addLog('Deep link received: $uri');

    Map<String, String> params = uri.queryParameters;
    if (params.containsKey('errorCode')) {
      String errorMessage = params['errorMessage'] ?? 'Unknown error';
      addLog('Error: $errorMessage');
      statusMessage.value = 'Error: $errorMessage';
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String host = uri.host.toLowerCase();

    if (host == 'onconnect') {
      _handleConnectResponse(params);
    } else if (host == 'onsignandsendtransaction') {
      _handleTransactionResponse(params);
    } else {
      addLog('Unrecognized deep link path: ${uri.host}');
    }
  }

  void _handleConnectResponse(Map<String, String> params) {
    var phantomEncryptionPublicKey = params['phantom_encryption_public_key'];
    var nonce = params['nonce'];
    var data = params['data'];

    if (phantomEncryptionPublicKey != null && nonce != null && data != null) {
      try {
        Uint8List phantomPublicKeyBytes = bs58.base58.decode(phantomEncryptionPublicKey);
        PublicKey phantomPubKey = PublicKey(phantomPublicKeyBytes);

        // Initialize box for encryption/decryption
        box = Box(myPrivateKey: dappPrivateKey!, theirPublicKey: phantomPubKey);

        // Decrypt the payload
        Map<String, dynamic> decryptedData = decryptPayload(data, nonce);

        session = decryptedData['session'];
        phantomPublicKey = decryptedData['public_key'];

        walletAddress.value = phantomPublicKey!;
        isConnected.value = true;

        // Save connection data
        _secureStorage.write(key: 'wallet_address', value: phantomPublicKey);
        _secureStorage.write(key: 'wallet_session', value: session);
        // Añadir esta línea para guardar la clave pública de encriptación
        _secureStorage.write(key: 'phantom_public_key', value: phantomEncryptionPublicKey);

        addLog('Connected to wallet: $phantomPublicKey');
        statusMessage.value = 'Wallet connected successfully';

        // Get balance
        getWalletBalance();

        Get.snackbar(
          'Connected',
          'Wallet connected successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        addLog('Error handling connect response: $e');
        statusMessage.value = 'Connection error: $e';
        Get.snackbar(
          'Error',
          'Failed to connect wallet: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      addLog('Missing required parameters in the connect response');
      statusMessage.value = 'Missing parameters in connect response';
    }
  }
  void _handleTransactionResponse(Map<String, String> params) {
    var nonce = params['nonce'];
    var data = params['data'];

    if (nonce != null && data != null) {
      try {
        Map<String, dynamic> decryptedData = decryptPayload(data, nonce);
        String? signature = decryptedData['signature'];

        if (signature != null) {
          transactionSignature.value = signature;
          statusMessage.value = 'Transaction sent successfully';
          addLog('Transaction sent. Signature: $signature');

          Get.back(); // Close any dialogs

          Get.snackbar(
            'Transaction Sent',
            'Transaction completed successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          statusMessage.value = 'No signature in transaction response';
          addLog('No signature received in transaction response');
        }
      } catch (e) {
        addLog('Error decrypting transaction response: $e');
        statusMessage.value = 'Error: $e';
        Get.snackbar(
          'Error',
          'Failed to process transaction: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      addLog('Missing required parameters in transaction response');
      statusMessage.value = 'Missing parameters in transaction response';
    }
  }

  Map<String, dynamic> decryptPayload(String data, String nonce) {
    if (box == null) throw Exception('Encryption box not initialized');

    Uint8List cipherText = bs58.base58.decode(data);
    Uint8List nonceBytes = bs58.base58.decode(nonce);

    EncryptedMessage encryptedMessage = EncryptedMessage(
      nonce: nonceBytes,
      cipherText: cipherText,
    );

    Uint8List decrypted = box!.decrypt(encryptedMessage).toUint8List();
    String jsonString = utf8.decode(decrypted);

    return json.decode(jsonString);
  }
  Map<String, Uint8List> encryptPayload(Map<String, dynamic> payload) {
    if (box == null) {
      addLog('Error: Encryption box not initialized');
      throw Exception('Encryption box not initialized');
    }

    try {
      Uint8List nonce = PineNaClUtils.randombytes(24);
      Uint8List message = Uint8List.fromList(utf8.encode(json.encode(payload)));

      final encryptedMessage = box!.encrypt(message, nonce: nonce);
      Uint8List encryptedPayload = encryptedMessage.cipherText.toUint8List();

      return {'nonce': nonce, 'payload': encryptedPayload};
    } catch (e) {
      addLog('Error en la encriptación: $e');
      throw Exception('Error encriptando payload: $e');
    }
  }
  Future<void> connectWallet() async {
    try {
      isLoading.value = true;
      statusMessage.value = 'Connecting to wallet...';
      addLog('Attempting to connect to wallet');

      String dappEncryptionPublicKey =
          bs58.base58.encode(dappPublicKey!.asTypedList);
      String cluster = 'testnet';
      String appUrl = 'https://drive-ledger.app';
      String redirectLink = '$appScheme://onConnect';

      Uri url = Uri.https('phantom.app', '/ul/v1/connect', {
        'dapp_encryption_public_key': dappEncryptionPublicKey,
        'cluster': cluster,
        'app_url': appUrl,
        'redirect_link': redirectLink,
      });

      String urlStr = url.toString();
      addLog('Opening Phantom connection URL: $urlStr');

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        statusMessage.value = 'Waiting for wallet connection...';
      } else {
        throw Exception('Could not launch URL: $urlStr');
      }
    } catch (e) {
      addLog('Error connecting to wallet: $e');
      statusMessage.value = 'Connection error: $e';
      Get.snackbar(
        'Error',
        'Failed to connect wallet: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> disconnectWallet() async {
    try {
      isLoading.value = true;

      // Clear saved connection data
      await _secureStorage.delete(key: 'wallet_address');
      await _secureStorage.delete(key: 'wallet_session');

      // Reset state
      isConnected.value = false;
      walletAddress.value = '';
      walletBalance.value = 0.0;
      session = null;
      phantomPublicKey = null;

      addLog('Wallet disconnected');
      statusMessage.value = 'Wallet disconnected';

      Get.snackbar(
        'Disconnected',
        'Wallet has been disconnected',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      addLog('Error disconnecting wallet: $e');
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

// Este método corregido debe reemplazar el método getWalletBalance() en PhantomWalletController

  Future<void> getWalletBalance() async {
    if (!isConnected.value || walletAddress.isEmpty) {
      walletBalance.value = 0.0;
      return;
    }

    try {
      addLog('Fetching wallet balance');

      final response = await _networkService.get(
        '/api/balances/${walletAddress.value}',
      );

      addLog('Balance response: ${response.data}');

      // Verificación segura de la respuesta
      if (response.data != null) {
        if (response.data['success'] == true) {
          // Verificar si data existe y tiene los campos necesarios
          if (response.data['data'] != null) {
            final balanceData = response.data['data'];

            // Verificar si 'balance' existe en los datos
            if (balanceData['balance'] != null) {
              // Convertir a double de manera segura
              final double balance =
                  double.tryParse(balanceData['balance'].toString()) ?? 0.0;
              walletBalance.value = balance;
              addLog('Balance fetched successfully: $balance');
            } else {
              walletBalance.value = 0.0;
              addLog('No balance data found in response');
            }
          } else {
            walletBalance.value = 0.0;
            addLog('Missing data field in response');
          }
        } else if (response.data['result'] == 'success') {
          // Formato alternativo de respuesta
          if (response.data['data'] != null) {
            final balanceData = response.data['data'];
            if (balanceData['balance'] != null) {
              final double balance =
                  double.tryParse(balanceData['balance'].toString()) ?? 0.0;
              walletBalance.value = balance;
              addLog('Balance fetched successfully: $balance');
            } else {
              walletBalance.value = 0.0;
              addLog('No balance data found in response');
            }
          } else {
            walletBalance.value = 0.0;
            addLog('Missing data field in response');
          }
        } else {
          // Manejo de respuesta no exitosa
          walletBalance.value = 0.0;
          String errorMsg = 'Error getting wallet balance';
          if (response.data['message'] != null) {
            errorMsg = response.data['message'];
          }
          addLog(errorMsg);
        }
      } else {
        walletBalance.value = 0.0;
        addLog('Null response data');
      }
    } catch (e) {
      walletBalance.value = 0.0;
      addLog('Error getting wallet balance: $e');
    }
  }

  Future<bool> signAndSendTransaction(String encodedTransaction) async {
    print('===== STARTING TRANSACTION SIGNING =====');
    print('encodedTransaction: $encodedTransaction');

    if (!isConnected.value || session == null) {
      print('ERROR: Wallet not connected. isConnected: ${isConnected.value}, session: ${session != null}');
      Get.snackbar(
        'Error',
        'Wallet not connected',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Añadir esta verificación
    if (box == null) {
      // Intenta reinicializar el box con los datos guardados
      try {
        // Recuperar la clave pública de Phantom guardada
        final phantomPubKeyStr = await _secureStorage.read(key: 'phantom_public_key');
        if (phantomPubKeyStr != null) {
          Uint8List phantomPublicKeyBytes = bs58.base58.decode(phantomPubKeyStr);
          PublicKey phantomPubKey = PublicKey(phantomPublicKeyBytes);

          // Reinicializar el box
          box = Box(myPrivateKey: dappPrivateKey!, theirPublicKey: phantomPubKey);
          addLog('Box reinicializado exitosamente');
        } else {
          Get.snackbar(
            'Error',
            'Información de conexión incompleta',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }
      } catch (e) {
        addLog('Error reinicializando el box: $e');
        Get.snackbar(
          'Error',
          'No se pudo inicializar la encriptación',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    }

    try {
      isLoading.value = true;
      statusMessage.value = 'Preparing transaction...';
      addLog('Preparing to sign and send transaction');
      print('Session: $session');

      // Create the payload
      Map<String, dynamic> payload = {
        'session': session,
        'transaction': encodedTransaction,
      };
      print('Created payload with transaction');
      print('PAYLOAD ANTES DE ENCRIPTAR: ${json.encode(payload)}');

      // Encrypt the payload
      print('Encrypting payload...');
      Map<String, Uint8List> encrypted = encryptPayload(payload);
      String dappEncryptionPublicKey = bs58.base58.encode(dappPublicKey!.asTypedList);
      String nonceBase58 = bs58.base58.encode(encrypted['nonce']!);
      String payloadBase58 = bs58.base58.encode(encrypted['payload']!);
      print('Encryption successful');
      print('dappEncryptionPublicKey (first 10 chars): ${dappEncryptionPublicKey.substring(0, min(10, dappEncryptionPublicKey.length))}...');
      print('nonce (first 10 chars): ${nonceBase58.substring(0, min(10, nonceBase58.length))}...');
      print('payloadBase58 length: ${payloadBase58.length}');

      // Create the URL
      Uri url = Uri.https('phantom.app', '/ul/v1/signAndSendTransaction', {
        'dapp_encryption_public_key': dappEncryptionPublicKey,
        'nonce': nonceBase58,
        'redirect_link': '$appScheme://onSignAndSendTransaction',
        'payload': payloadBase58,
      });

      String urlStr = url.toString();
      print('Transaction URL created: ${urlStr.substring(0, min(100, urlStr.length))}...');
      addLog('Opening transaction signing URL: $urlStr');

      if (await canLaunchUrl(url)) {
        print('Launching URL...');
        bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        print('URL launched successfully: $launched');
        statusMessage.value = 'Waiting for transaction approval...';
        return true;
      } else {
        print('ERROR: Could not launch URL');
        throw Exception('Could not launch URL: $urlStr');
      }
    } catch (e, stackTrace) {
      print('ERROR in signAndSendTransaction: $e');
      print('Stack trace: $stackTrace');
      addLog('Error signing transaction: $e');
      statusMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        'Failed to sign transaction: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
      print('===== TRANSACTION SIGNING PROCESS COMPLETE =====');
    }
  }
  String formatAddress(String address) {
    if (address.length <= 8) return address;
    return "${address.substring(0, 6)}...${address.substring(address.length - 4)}";
  }

  void openTransactionInSolscan() {
    if (transactionSignature.isEmpty) {
      Get.snackbar(
        'Error',
        'No transaction signature available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final url = Uri.parse(
        'https://solscan.io/tx/${transactionSignature.value}?cluster=testnet');
    addLog('Opening transaction in Solscan: $url');

    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  void onClose() {
    // _appLinks?.dispose();
    super.onClose();
  }
}
