import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// lib/core/services/local_storage_service.dart

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ============================================
  // INICIALIZAR
  // ============================================
  static Future<LocalStorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _instance;
  }

  // ============================================
  // TOKEN (Guardado seguro)
  // ============================================

  /// Guardar token de acceso
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  /// Obtener token de acceso
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  /// Guardar refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  /// Obtener refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  /// Eliminar tokens
  Future<void> deleteTokens() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  // ============================================
  // USUARIO (Guardado seguro)
  // ============================================

  /// Guardar datos del usuario
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _secureStorage.write(key: 'user_data', value: jsonEncode(userData));
  }

  /// Obtener datos del usuario
  Future<Map<String, dynamic>?> getUser() async {
    final data = await _secureStorage.read(key: 'user_data');
    if (data != null && data.isNotEmpty) {
      try {
        return jsonDecode(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Eliminar datos del usuario
  Future<void> deleteUser() async {
    await _secureStorage.delete(key: 'user_data');
  }

  // ============================================
  // DATOS DE SESIÓN (SharedPreferences)
  // ============================================

  /// Guardar si el usuario está autenticado
  Future<void> saveIsAuthenticated(bool value) async {
    await _prefs?.setBool('is_authenticated', value);
  }

  /// Obtener estado de autenticación
  bool getIsAuthenticated() {
    return _prefs?.getBool('is_authenticated') ?? false;
  }

  /// Guardar si recordar sesión
  Future<void> saveRememberMe(bool value) async {
    await _prefs?.setBool('remember_me', value);
  }

  /// Obtener recordar sesión
  bool getRememberMe() {
    return _prefs?.getBool('remember_me') ?? false;
  }

  /// Guardar última sincronización
  Future<void> saveLastSync(DateTime date) async {
    await _prefs?.setString('last_sync', date.toIso8601String());
  }

  /// Obtener última sincronización
  DateTime? getLastSync() {
    final dateStr = _prefs?.getString('last_sync');
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  // ============================================
  // CONFIGURACIÓN DEL USUARIO
  // ============================================

  /// Guardar tema seleccionado
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs?.setString('theme_mode', themeMode);
  }

  /// Obtener tema seleccionado
  String getThemeMode() {
    return _prefs?.getString('theme_mode') ?? 'system';
  }

  /// Guardar idioma
  Future<void> saveLanguage(String language) async {
    await _prefs?.setString('language', language);
  }

  /// Obtener idioma
  String getLanguage() {
    return _prefs?.getString('language') ?? 'es';
  }

  // ============================================
  // DATOS DEL DISPOSITIVO
  // ============================================

  /// Guardar ID del dispositivo
  Future<void> saveDeviceId(String deviceId) async {
    await _prefs?.setString('device_id', deviceId);
  }

  /// Obtener ID del dispositivo
  String? getDeviceId() {
    return _prefs?.getString('device_id');
  }

  /// Guardar token de FCM (Firebase Cloud Messaging)
  Future<void> saveFcmToken(String token) async {
    await _prefs?.setString('fcm_token', token);
  }

  /// Obtener token de FCM
  String? getFcmToken() {
    return _prefs?.getString('fcm_token');
  }

  // ============================================
  // DATOS DE ENTREGAS (Cache)
  // ============================================

  /// Guardar lista de entregas en cache
  Future<void> cacheDeliveries(List<Map<String, dynamic>> deliveries) async {
    final json = jsonEncode(deliveries);
    await _prefs?.setString('cached_deliveries', json);
    await _prefs?.setInt(
      'deliveries_cache_time',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Obtener entregas en cache
  List<Map<String, dynamic>>? getCachedDeliveries() {
    final json = _prefs?.getString('cached_deliveries');
    if (json != null && json.isNotEmpty) {
      try {
        final List<dynamic> data = jsonDecode(json);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Verificar si el cache de entregas es válido (menos de 5 minutos)
  bool isDeliveriesCacheValid() {
    final cacheTime = _prefs?.getInt('deliveries_cache_time');
    if (cacheTime == null) return false;
    final diff = DateTime.now().millisecondsSinceEpoch - cacheTime;
    return diff < 5 * 60 * 1000; // 5 minutos
  }

  // ============================================
  // LIMPIAR TODOS LOS DATOS
  // ============================================

  /// Limpiar todos los datos del usuario (logout)
  Future<void> clearAll() async {
    await deleteTokens();
    await deleteUser();
    await _prefs?.remove('is_authenticated');
    await _prefs?.remove('cached_deliveries');
    await _prefs?.remove('deliveries_cache_time');
    // No eliminar configuración (tema, idioma, device_id)
  }

  /// Limpiar TODO (incluyendo configuración)
  Future<void> clearEverything() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Verificar si hay datos de sesión guardados
  Future<bool> hasSession() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && user != null;
  }

  /// Obtener todas las claves guardadas (debug)
  Future<Map<String, String>> getAllSecureKeys() async {
    try {
      // No hay método directo para obtener todas las claves en flutter_secure_storage
      // Solo se puede hacer con lectura individual
      final token = await getToken();
      final refresh = await getRefreshToken();
      final user = await getUser();
      return {
        'auth_token': token ?? 'null',
        'refresh_token': refresh ?? 'null',
        'user_data': user != null ? jsonEncode(user) : 'null',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Agregar al final de la clase LocalStorageService

  static const String _cartKey = 'cart_data';

  Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    final json = jsonEncode(cartItems);
    await _prefs?.setString(_cartKey, json);
  }

  Future<List<Map<String, dynamic>>?> getCart() async {
    final json = _prefs?.getString(_cartKey);
    if (json != null && json.isNotEmpty) {
      try {
        final List<dynamic> data = jsonDecode(json);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearCartLocal() async {
    await _prefs?.remove(_cartKey);
  }
}
