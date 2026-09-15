// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'connectivity_service.dart';
import '../services/local_storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  final ConnectivityService _connectivity = ConnectivityService();

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: '',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  // ============================================
  // INTERCEPTOR DE AUTENTICACIÓN
  // ============================================
  Interceptor _authInterceptor() => InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await LocalStorageService().getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        // Token expirado - intentar refresh
        final refreshToken = await LocalStorageService().getRefreshToken();
        if (refreshToken != null) {
          try {
            final response = await _dio.post(
              ApiEndpoints.refreshToken,
              data: {'refresh': refreshToken},
            );
            if (response.statusCode == 200) {
              final newToken = response.data['access'];
              await LocalStorageService().saveToken(newToken);
              // Reintentar la petición original
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final retryResponse = await _dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          } catch (e) {
            // Si falla el refresh, logout
            await LocalStorageService().clearAll();
          }
        }
      }
      return handler.next(error);
    },
  );

  // ============================================
  // INTERCEPTOR DE LOGGING
  // ============================================
  Interceptor _loggingInterceptor() => InterceptorsWrapper(
    onRequest: (options, handler) {
      print('📤 REQUEST: ${options.method} ${options.path}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Data: ${options.data}');
      }
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('📥 RESPONSE: ${response.statusCode} ${response.realUri.path}');
      print('Data: ${response.data}');
      return handler.next(response);
    },
    onError: (error, handler) {
      print('❌ ERROR: ${error.message}');
      if (error.response != null) {
        print('Status: ${error.response?.statusCode}');
        print('Data: ${error.response?.data}');
      }
      return handler.next(error);
    },
  );

  // ============================================
  // INTERCEPTOR DE ERRORES
  // ============================================
  Interceptor _errorInterceptor() => InterceptorsWrapper(
    onError: (error, handler) {
      // Dejar que DioException se propague tal cual para que cada
      // llamada pueda manejar el statusCode correctamente
      return handler.next(error);
    },
  );

  // ============================================
  // MÉTODOS PÚBLICOS
  // ============================================
  
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    if (!await _connectivity.checkConnection()) {
      throw Exception('Se requiere conexión a internet');
    }
    return _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) async {
    if (!await _connectivity.checkConnection()) {
      throw Exception('Se requiere conexión a internet');
    }
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    if (!await _connectivity.checkConnection()) {
      throw Exception('Se requiere conexión a internet');
    }
    return _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    if (!await _connectivity.checkConnection()) {
      throw Exception('Se requiere conexión a internet');
    }
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    if (!await _connectivity.checkConnection()) {
      throw Exception('Se requiere conexión a internet');
    }
    return _dio.delete(path);
  }

  Dio get dio => _dio;
}