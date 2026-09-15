// lib/core/config/app_constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // ============================================
  // NOMBRES DE LA APP
  // ============================================
  static const String appName = 'Sabix Repartidor';
  static const String appNameShort = 'Sabix';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'com.sabix.repartidor';
  
  // ============================================
  // TEXTOS DE PANTALLAS
  // ============================================
  
  // Splash
  static const String splashLoading = 'Cargando...';
  
  // Login
  static const String loginTitle = 'Iniciar Sesión';
  static const String loginSubtitle = 'Bienvenido de vuelta';
  static const String loginWelcome = '¡Bienvenido de vuelta!';
  static const String loginButton = 'Iniciar Sesión';
  static const String loginForgotPassword = '¿Olvidaste tu contraseña?';
  static const String loginNoAccount = '¿No tienes cuenta?';
  static const String loginRegister = 'Regístrate';
  static const String loginSuccess = '¡Bienvenido!';
  static const String loginError = 'Credenciales incorrectas';
  
  // Register
  static const String registerTitle = 'Crear Cuenta';
  static const String registerSubtitle = 'Comienza tu viaje con nosotros';
  static const String registerButton = 'Registrarme';
  static const String registerSuccess = '¡Registro exitoso!';
  static const String registerError = 'Error al registrarse';
  static const String registerHaveAccount = '¿Ya tienes cuenta?';
  static const String registerLogin = 'Inicia sesión';
  
  // Home
  static const String homeTitle = 'Inicio';
  static const String homeDeliveries = 'Mis Entregas';
  static const String homePending = 'Pendientes';
  static const String homeActive = 'Activas';
  static const String homeCompleted = 'Completadas';
  static const String homeEarnings = 'Ganancias';
  static const String homeToday = 'Hoy';
  static const String homeWeek = 'Esta semana';
  static const String homeMonth = 'Este mes';
  
  // ============================================
  // CAMPOS DE FORMULARIOS
  // ============================================
  static const String fieldName = 'Nombre completo';
  static const String fieldNameHint = 'Ej: Juan Pérez';
  static const String fieldUsername = 'Usuario';
  static const String fieldUsernameHint = 'Ej: juan123';
  static const String fieldEmail = 'Correo electrónico';
  static const String fieldEmailHint = 'ejemplo@correo.com';
  static const String fieldPassword = 'Contraseña';
  static const String fieldPasswordHint = 'Mínimo 6 caracteres';
  static const String fieldConfirmPassword = 'Confirmar contraseña';
  static const String fieldPhone = 'Teléfono';
  static const String fieldPhoneHint = '10 dígitos';
  static const String fieldAddress = 'Dirección';
  static const String fieldAddressHint = 'Tu dirección';
  
  // ============================================
  // VALIDACIONES
  // ============================================
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 10;
  
  static const String errorRequired = 'Este campo es requerido';
  static const String errorNameMin = 'Mínimo 3 caracteres';
  static const String errorNameMax = 'Máximo 50 caracteres';
  static const String errorPasswordMin = 'Mínimo 6 caracteres';
  static const String errorPasswordMax = 'Máximo 50 caracteres';
  static const String errorPasswordMatch = 'Las contraseñas no coinciden';
  static const String errorEmailInvalid = 'Correo inválido';
  static const String errorPhoneInvalid = 'Teléfono inválido';
  static const String errorUsernameInvalid = 'Usuario inválido';
  
  // ============================================
  // TAMAÑOS Y ESPACIADOS
  // ============================================
  static const double spacingXXS = 2.0;
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;
  static const double spacingXXXXL = 40.0;
  
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 20.0;
  static const double radiusXXXL = 24.0;
  static const double radiusCircle = 9999.0;
  
  static const double buttonHeight = 50.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonHeightSmall = 40.0;
  
  static const double inputHeight = 50.0;
  static const double inputHeightLarge = 56.0;
  
  static const double iconSizeSM = 16.0;
  static const double iconSizeMD = 20.0;
  static const double iconSizeLG = 24.0;
  static const double iconSizeXL = 32.0;
  
  static const double avatarSizeSM = 32.0;
  static const double avatarSizeMD = 40.0;
  static const double avatarSizeLG = 48.0;
  static const double avatarSizeXL = 56.0;
  
  static const double cardElevation = 2.0;
  static const double cardElevationHigh = 4.0;
  
  // ============================================
  // DURACIONES DE ANIMACIÓN
  // ============================================
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);
  
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration splashDuration = Duration(seconds: 2);
  
  // ============================================
  // MENSAJES COMUNES
  // ============================================
  static const String msgError = 'Ha ocurrido un error';
  static const String msgSuccess = '¡Éxito!';
  static const String msgInfo = 'Información';
  static const String msgWarning = 'Advertencia';
  
  static const String msgInternetRequired = 'Se requiere conexión a internet';
  static const String msgInternetLost = 'Conexión perdida';
  static const String msgInternetRestored = 'Conexión restablecida';
  
  static const String msgLoading = 'Cargando...';
  static const String msgSaving = 'Guardando...';
  static const String msgDeleting = 'Eliminando...';
  static const String msgUpdating = 'Actualizando...';
  
  static const String msgRetry = 'Reintentar';
  static const String msgCancel = 'Cancelar';
  static const String msgConfirm = 'Confirmar';
  static const String msgAccept = 'Aceptar';
  static const String msgClose = 'Cerrar';
  static const String msgSave = 'Guardar';
  static const String msgDelete = 'Eliminar';
  static const String msgEdit = 'Editar';
  static const String msgView = 'Ver';
  static const String msgMore = 'Ver más';
  static const String msgLess = 'Ver menos';
  
  // ============================================
  // RUTAS
  // ============================================
  static const String routeSplash = '/splash';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeHome = '/home';
  static const String routeDeliveries = '/deliveries';
  static const String routeDeliveryDetail = '/delivery/:id';
  static const String routeProfile = '/profile';
  static const String routeSettings = '/settings';
  static const String routeNotifications = '/notifications';
  
  // ============================================
  // STORAGE KEYS
  // ============================================
  static const String storageToken = 'auth_token';
  static const String storageUser = 'user_data';
  static const String storageTheme = 'theme_mode';
  static const String storageLanguage = 'language';
  static const String storageRememberMe = 'remember_me';
  static const String storageLastSync = 'last_sync';
  static const String storageDeviceId = 'device_id';
}