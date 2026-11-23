import 'package:flutter/material.dart';

/// Semantic color tokens for the Valora design system.
///
/// Stitch Official Tokens (Brand Kit & Specification):
/// - Forest Green (#294D3A): Primary brand color, actions, prominent headings.
/// - Sage Green (#91A98B): Secondary brand color, icons, badges.
/// - Warm Cream (#F7F5ED): Base screen background canvas.
/// - Surface (#F7FAF4): App canvas surface.
/// - Soft White (#FFFEFA): Cards, dialogs, inputs, sheets.
/// - Muted Olive (#B5BD91): Tertiary accent.
/// - Charcoal (#292D29 / #191D19): High emphasis text.
/// - Soft Gray (#858A82): Secondary text and icons.
/// - Border (#E7E7DE / #E0E3DD): Crisp structural borders.
///
/// Semantic Expiration States:
/// - Em dia / Seguro: Bg #EBF2E9, Text #294D3A
/// - Atenção / Vence em breve: Bg #FDF4E5, Text #8C5B14, Dot #D97706
/// - Vencido / Consumo imediato: Bg #FCE8E6, Text #991B1B, Dot #DC2626
abstract class AppColors {
  // Stitch Brand Tokens
  static const Color forestGreen = Color(0xFF294D3A);
  static const Color sageGreen = Color(0xFF91A98B);
  static const Color warmCream = Color(0xFFF7F5ED);
  static const Color canvas = Color(0xFFF7FAF4);
  static const Color softWhite = Color(0xFFFFFEFA);
  static const Color mutedOlive = Color(0xFFB5BD91);
  static const Color charcoal = Color(0xFF292D29);
  static const Color softGray = Color(0xFF858A82);
  static const Color subHeader = Color(0xFF567061);
  static const Color border = Color(0xFFE7E7DE);

  // Surface Containers (Material 3 mapped from Stitch)
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F5EE);
  static const Color surfaceContainer = Color(0xFFECEFE8);
  static const Color surfaceContainerHigh = Color(0xFFE6E9E3);
  static const Color surfaceContainerHighest = Color(0xFFE0E3DD);

  // Backwards-compatible aliases for existing codebase
  static const Color lightBackground = warmCream;
  static const Color lightSurface = softWhite;
  static const Color lightSurfaceSecondary = surfaceContainerLow;
  static const Color lightBorder = border;

  static const Color primarySage = forestGreen;
  static const Color primarySageLight = Color(0xFFEBF2E9);
  static const Color primarySageDark = Color(0xFF1E392B);
  static const Color deepForest = forestGreen;

  static const Color textPrimaryLight = charcoal;
  static const Color textSecondaryLight = softGray;
  static const Color textTertiaryLight = Color(0xFFA5AAA2);

  // Semantic Status Colors (Stitch exact values)
  static const Color statusSafeBg = Color(0xFFEBF2E9);
  static const Color statusSafeText = Color(0xFF294D3A);
  static const Color statusFresh = statusSafeText;
  static const Color statusFreshBg = statusSafeBg;

  static const Color statusWarningBg = Color(0xFFFDF4E5);
  static const Color statusWarningText = Color(0xFF8C5B14);
  static const Color statusWarningDot = Color(0xFFD97706);
  static const Color statusExpiringSoon = statusWarningText;
  static const Color statusExpiringSoonBg = statusWarningBg;

  static const Color statusExpiringToday = Color(0xFFEA580C);
  static const Color statusExpiringTodayBg = Color(0xFFFFEDD5);

  static const Color statusCriticalBg = Color(0xFFFCE8E6);
  static const Color statusCriticalText = Color(0xFF991B1B);
  static const Color statusCriticalDot = Color(0xFFDC2626);
  static const Color statusExpired = statusCriticalText;
  static const Color statusExpiredBg = statusCriticalBg;

  static const Color statusUnknown = Color(0xFF6B7280);
  static const Color statusUnknownBg = Color(0xFFF3F4F6);

  // Dark Mode Tokens
  static const Color darkBackground = Color(0xFF111714);
  static const Color darkSurface = Color(0xFF1B231F);
  static const Color darkSurfaceSecondary = Color(0xFF232D28);
  static const Color darkBorder = Color(0xFF2E3B34);

  static const Color textPrimaryDark = Color(0xFFF0F4F1);
  static const Color textSecondaryDark = Color(0xFFA1B3A9);
  static const Color textTertiaryDark = Color(0xFF708378);

  static const Color statusFreshBgDark = Color(0xFF193324);
  static const Color statusExpiringSoonBgDark = Color(0xFF3B2B11);
  static const Color statusExpiringTodayBgDark = Color(0xFF422110);
  static const Color statusExpiredBgDark = Color(0xFF421515);
  static const Color statusUnknownBgDark = Color(0xFF24282D);
}
