import 'package:flutter/material.dart';
// lib/core/config/app_colors.dart

class AppColors {
  // ============================================
  // COLORES PRINCIPALES - MARCA SABIX
  // ============================================
  // Paleta oficial de Sabix (tonos morados)
  static const Color primary = Color(0xFF7E097E); // Morado oscuro (#7E097E)
  static const Color primaryDark = Color(0xFF5A065A); // Morado más oscuro
  static const Color primaryLight = Color(0xFF9D2A9C); // Morado medio (#9D2A9C)
  static const Color primaryMedium = Color(
    0xFFBC4AB9,
  ); // Morado claro (#BC4AB9)
  static const Color primarySoft = Color(0xFFDB6BD7); // Morado suave (#DB6BD7)
  static const Color primaryLightest = Color(
    0xFFFA8BF5,
  ); // Morado muy claro (#FA8BF5)

  static const Color secondary = Color(0xFF10B981); // Verde éxito
  static const Color accent = Color(0xFFF59E0B); // Ámbar (alertas)

  // ============================================
  // COLORES DE FONDO
  // ============================================
  static const Color background = Color(0xFFF8FAFC); // Gris muy claro
  static const Color surface = Color(0xFFFFFFFF); // Blanco
  static const Color card = Color(0xFFFFFFFF); // Blanco para cards
  static const Color cardShadow = Color(0x1A000000); // Sombra para cards

  // ============================================
  // COLORES DE TEXTO
  // ============================================
  static const Color textPrimary = Color(
    0xFF1E293B,
  ); // Gris oscuro (casi negro)
  static const Color textSecondary = Color(0xFF64748B); // Gris medio
  static const Color textLight = Color(0xFF94A3B8); // Gris claro
  static const Color textWhite = Color(0xFFFFFFFF); // Blanco
  static const Color textHint = Color(0xFFCBD5E1); // Gris muy claro (hint)

  // ============================================
  // COLORES DE ESTADO
  // ============================================
  static const Color success = Color(0xFF22C55E); // Verde éxito
  static const Color error = Color(0xFFEF4444); // Rojo error
  static const Color warning = Color(0xFFF59E0B); // Ámbar advertencia
  static const Color info = Color(
    0xFF14B8A6,
  ); // Teal (antes azul), contrasta con el morado

  // ============================================
  // COLORES DE BORDE Y DIVISORES
  // ============================================
  static const Color border = Color(0xFFE2E8F0); // Gris borde
  static const Color borderLight = Color(0xFFF1F5F9); // Gris borde claro
  static const Color borderFocus = Color(0xFF7E097E); // Morado foco (marca)
  static const Color divider = Color(0xFFE2E8F0); // Divisor

  // ============================================
  // COLORES DE INPUTS
  // ============================================
  static const Color inputBg = Color(0xFFFFFFFF); // Fondo input (blanco)
  static const Color inputBorder = Color(0xFFE2E8F0); // Borde input
  static const Color inputFocus = Color(0xFF7E097E); // Morado focus (marca)
  static const Color inputError = Color(0xFFEF4444); // Borde error

  // ============================================
  // COLORES DE BOTONES
  // ============================================
  static const Color buttonPrimary = Color(0xFF7E097E); // Morado principal
  static const Color buttonPrimaryHover = Color(0xFF5A065A); // Morado oscuro
  static const Color buttonPrimaryDisabled = Color(0xFFBC4AB9); // Morado claro

  static const Color buttonSecondary = Color(0xFFF1F5F9);
  static const Color buttonSecondaryText = Color(0xFF1E293B);

  static const Color buttonDanger = Color(0xFFEF4444);
  static const Color buttonDangerHover = Color(0xFFDC2626);

  // ============================================
  // COLORES DE ICONOS
  // ============================================
  static const Color iconPrimary = Color(0xFF7E097E); // Morado
  static const Color iconSecondary = Color(0xFF64748B);
  static const Color iconLight = Color(0xFF94A3B8);
  static const Color iconWhite = Color(0xFFFFFFFF);

  // ============================================
  // COLORES DE SHADOWS
  // ============================================
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color.fromARGB(51, 245, 245, 245);
  static const Color shadowDark = Color(0x4D000000);

  // ============================================
  // COLORES DE BADGES / CHIPS
  // ============================================
  static const Color badgeBg = Color(0xFFEF4444);
  static const Color badgeText = Color(0xFFFFFFFF);

  // ============================================
  // GRADIENTES (con colores de marca)
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7E097E), Color(0xFFBC4AB9)],
  );

  static const LinearGradient primaryDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5A065A), Color(0xFF7E097E)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF059669)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFDC2626)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFD97706)],
  );
}
