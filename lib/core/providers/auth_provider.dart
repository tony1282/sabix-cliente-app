// lib/core/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../network/connectivity_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final LocalStorageService _storage = LocalStorageService();
  final ConnectivityService _connectivity = ConnectivityService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _apiClient.init();
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final userData = await _storage.getUser();
      if (userData != null) {
        _currentUser = UserModel.fromJson(userData);
        _isAuthenticated = true;
        notifyListeners();
        // Si no tiene nombre guardado, refrescar desde la API
        if (_currentUser?.firstName == null || _currentUser!.firstName!.isEmpty) {
          await _refreshProfileFromApi();
        }
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> _refreshProfileFromApi() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      if (response.statusCode == 200) {
        final token = _currentUser?.token;
        final refresh = _currentUser?.refreshToken;
        final data = Map<String, dynamic>.from(response.data as Map);
        if (token != null) data['access'] = token;
        if (refresh != null) data['refresh'] = refresh;
        _currentUser = UserModel.fromJson(data);
        await _storage.saveUser(_currentUser!.toJson());
        notifyListeners();
      }
    } catch (_) {}
  }

  // ============================================
  // REGISTRO - SIEMPRE CLIENTE
  // ============================================
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    String? address,
    String? preferredPaymentMethod,
  }) async {
    _setLoading(true);
    _clearError();

    if (!await _connectivity.checkConnection()) {
      _setError('Se requiere conexión a internet');
      _setLoading(false);
      return false;
    }

    try {
      final user = UserModel(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        userType: 'client',
        address: address,
        preferredPaymentMethod: preferredPaymentMethod,
      );

      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: user.toRegisterJson(password),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newUser = UserModel.fromJson(response.data);
        _currentUser = newUser;
        _isAuthenticated = true;
        
        if (newUser.token != null) {
          await _storage.saveToken(newUser.token!);
        }
        if (newUser.refreshToken != null) {
          await _storage.saveRefreshToken(newUser.refreshToken!);
        }
        await _storage.saveUser(newUser.toJson());
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.data['message'] ?? 'Error al registrarse');
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMessage = 'Error al registrarse';
      
      if (errorData != null && errorData is Map) {
        if (errorData['password'] != null && errorData['password'] is List) {
          errorMessage = 'Contraseña: ${errorData['password'][0]}';
        } else if (errorData['password2'] != null && errorData['password2'] is List) {
          errorMessage = 'Confirmación: ${errorData['password2'][0]}';
        } else if (errorData['username'] != null && errorData['username'] is List) {
          errorMessage = 'Usuario: ${errorData['username'][0]}';
        } else if (errorData['email'] != null && errorData['email'] is List) {
          errorMessage = 'Correo: ${errorData['email'][0]}';
        } else if (errorData['address'] != null && errorData['address'] is List) {
          errorMessage = 'Dirección: ${errorData['address'][0]}';
        } else if (errorData['non_field_errors'] != null) {
          final errors = errorData['non_field_errors'];
          errorMessage = errors is List ? errors[0] : errors.toString();
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  // ============================================
  // LOGIN - ESPECÍFICO PARA CLIENTE
  // ============================================
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    if (!await _connectivity.checkConnection()) {
      _setError('Se requiere conexión a internet');
      _setLoading(false);
      return false;
    }

    try {
      // ✅ USAR ENDPOINT ESPECÍFICO DE CLIENTE
      final response = await _apiClient.post(
        ApiEndpoints.loginClient,  // 👈 CAMBIADO
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        _currentUser = user;
        _isAuthenticated = true;
        
        if (user.token != null) {
          await _storage.saveToken(user.token!);
        }
        if (user.refreshToken != null) {
          await _storage.saveRefreshToken(user.refreshToken!);
        }
        await _storage.saveUser(user.toJson());
        
        _setLoading(false);
        return true;
      } else {
        _setError('Credenciales incorrectas');
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 
                     e.response?.data['error'] ?? 
                     'Credenciales incorrectas';
      _setError(message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  // ============================================
  // LOGOUT
  // ============================================
  Future<void> logout() async {
    _setLoading(true);
    try {
      final refreshToken = await _storage.getRefreshToken();
      await _apiClient.post(
        ApiEndpoints.logout,
        data: refreshToken != null ? {'refresh': refreshToken} : {},
      );
    } catch (_) {
      // Si falla el logout en el servidor, igual limpiamos local
    } finally {
      await _storage.clearAll();
      _currentUser = null;
      _isAuthenticated = false;
      _setLoading(false);
      notifyListeners();
    }
  }

  // ============================================
  // CHECK AUTH STATUS
  // ============================================
  Future<bool> checkAuthStatus() async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await _apiClient.get(ApiEndpoints.profile);
        if (response.statusCode == 200) {
          final user = UserModel.fromJson(response.data);
          _currentUser = user;
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      } catch (e) {
        print('Error checking auth: $e');
      }
    }
    
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
  }
}