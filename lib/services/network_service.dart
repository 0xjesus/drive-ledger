// lib/services/network_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class NetworkService {
  // Singleton Instance
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  // Logger
  final Logger _logger = Logger('NetworkService');

  // Dio instance
  late final Dio _dio;

  // Secure Storage instance
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Getter para la URL base
  String get baseUrl => _dio.options.baseUrl;

  final List<String> _publicRoutes = [
    '/users/google/authenticate',
    '/api/initialize', // Añadir otras rutas públicas si es necesario
  ];

  // Private constructor
  NetworkService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _addInterceptors();
  }

  String _getBaseUrl() {
    final url = dotenv.env['API_URL'] ?? 'http://localhost:1337';
    _logger.info('🌐 Using base URL: $url');

    // Imprime el bearer token si existe
    _secureStorage.read(key: 'authToken').then((token) {
      _logger.info('🔑 Auth token: $token'); // Token is available here
    }).catchError((e) {
      _logger.error('Error reading auth token: $e');
    });

    return url;
  }

  bool _isPublicRoute(String path) {
    return _publicRoutes.any((route) => path.contains(route));
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _logger.info('🚀 Making request to: ${options.baseUrl}${options.path}');

          // Solo añadir el token si NO es una ruta pública
          if (!_isPublicRoute(options.path)) {
            final token = await _secureStorage.read(key: 'authToken');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              _logger.debug('🔑 Added auth token to request');
            } else {
              _logger.warning('⚠️ No auth token available for protected route');
            }
          } else {
            _logger.debug('🌐 Public route detected, skipping auth token');
          }

          // Sanitizar datos antes de enviar la solicitud
          if (options.data != null) {
            options.data = _sanitizeRequestData(options.data);
          }

          _logger.debug('📝 Request headers: ${options.headers}');
          _logger.debug('📦 Request data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.info('✅ Response received from: ${response.requestOptions.uri}');
          _logger.info('📊 Status code: ${response.statusCode}');

          // Log response data in debug mode only to avoid leaking sensitive info
          _logger.debug('📄 Response data: ${_formatResponseData(response.data)}');

          handler.next(response);
        },
        onError: (DioError e, handler) async {
          _logger.error('❌ Error in request to: ${e.requestOptions.uri}');

          if (e.response?.statusCode == 401 && !_isPublicRoute(e.requestOptions.path)) {
            // Solo manejar 401 en rutas protegidas
            _logger.warning('🔒 Auth token invalid or expired');
            await _secureStorage.delete(key: 'authToken');
            // Aquí podrías emitir un evento para notificar que el usuario debe volver a loguearse
          }

          _logDioError(e);
          handler.next(e);
        },
      ),
    );
  }

  // Sanitiza los datos antes de enviarlos
  dynamic _sanitizeRequestData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final sanitizedData = <String, dynamic>{};

      data.forEach((key, value) {
        // Si el valor es null y el key es 'description', usar string vacío
        if (value == null && (key == 'description' || key.toString().contains('description'))) {
          sanitizedData[key] = '';
        }
        // Omitir valores null para campos que no sean esenciales
        else if (value != null) {
          sanitizedData[key] = value;
        }
      });

      return sanitizedData;
    }

    return data;
  }

  // Formatea datos de respuesta grandes para logging
  String _formatResponseData(dynamic data) {
    if (data == null) return 'null';

    if (data is Map) {
      if (data.length > 20) {
        return '{Map with ${data.length} entries}';
      }

      final prettifiedData = Map.from(data);
      prettifiedData.forEach((key, value) {
        if (value is String && value.length > 200) {
          prettifiedData[key] = '${value.substring(0, 100)}... (${value.length} chars)';
        } else if (value is List && value.length > 10) {
          prettifiedData[key] = '[List with ${value.length} items]';
        }
      });

      return prettifiedData.toString();
    }

    if (data is List) {
      if (data.length > 10) {
        return '[List with ${data.length} items]';
      }
    }

    if (data is String && data.length > 500) {
      return '${data.substring(0, 200)}... (${data.length} chars)';
    }

    return data.toString();
  }

  // Logs detallados para errores Dio
  void _logDioError(DioError e) {
    _logger.error('🔴 DioError Details:');
    _logger.error('  • URL: ${e.requestOptions.uri}');
    _logger.error('  • Method: ${e.requestOptions.method}');
    _logger.error('  • Headers: ${e.requestOptions.headers}');
    _logger.error('  • Error Type: ${e.type}');
    _logger.error('  • Error Message: ${e.message}');

    if (e.response != null) {
      _logger.error('  • Status Code: ${e.response?.statusCode}');

      if (e.response?.data is Map) {
        final errorMsg = e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Unknown error';
        _logger.error('  • Error Details: $errorMsg');
      } else if (e.response?.data != null) {
        _logger.error('  • Response Data: ${_formatResponseData(e.response?.data)}');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------
  Future<Response<dynamic>> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) async {
    _logger.info('📡 GET Request to: ${_dio.options.baseUrl}$path');
    if (queryParameters != null) {
      _logger.info('🔍 Query parameters: $queryParameters');
    }

    return _request(
          () => _dio.get(
        path,
        queryParameters: _sanitizeQueryParameters(queryParameters),
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // POST
  // ---------------------------------------------------------------------------
  Future<Response<dynamic>> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    _logger.info('📡 POST Request to: ${_dio.options.baseUrl}$path');

    // El sanitizado de datos se realiza en el interceptor
    return _request(
          () => _dio.post(
        path,
        data: data,
        queryParameters: _sanitizeQueryParameters(queryParameters),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PUT
  // ---------------------------------------------------------------------------
  Future<Response<dynamic>> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    _logger.info('📡 PUT Request to: ${_dio.options.baseUrl}$path');

    // El sanitizado de datos se realiza en el interceptor
    return _request(
          () => _dio.put(
        path,
        data: data,
        queryParameters: _sanitizeQueryParameters(queryParameters),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------
  Future<Response<dynamic>> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    _logger.info('📡 DELETE Request to: ${_dio.options.baseUrl}$path');

    // El sanitizado de datos se realiza en el interceptor
    return _request(
          () => _dio.delete(
        path,
        data: data,
        queryParameters: _sanitizeQueryParameters(queryParameters),
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  // Sanitizar parámetros de consulta
  Map<String, dynamic>? _sanitizeQueryParameters(Map<String, dynamic>? params) {
    if (params == null) return null;

    final sanitizedParams = <String, dynamic>{};

    params.forEach((key, value) {
      if (value != null) {
        // Asegurar que todos los valores sean strings para parámetros de consulta
        sanitizedParams[key] = value.toString();
      }
    });

    return sanitizedParams;
  }

  // ---------------------------------------------------------------------------
  // _request
  // Maneja el try/catch para imprimir info detallada en caso de error
  // ---------------------------------------------------------------------------
  Future<Response<dynamic>> _request(
      Future<Response<dynamic>> Function() request,
      ) async {
    try {
      return await request();
    } on DioError catch (e) {
      _logDioError(e);
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('❌ Unexpected error: $e');
      _logger.error('Stack trace: $stackTrace');
      rethrow;
    }
  }

  void dispose() {
    _dio.close(force: true);
  }
}