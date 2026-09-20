import 'package:flutter/material.dart';

import 'fiestucas_colors.dart';
import 'fiestucas_spacing.dart';
import 'fiestucas_typography.dart';

/// Temas claro y oscuro de Fiestucas.
///
/// Todos los valores proceden de `docs/producto/12-sistema-diseno.md`. Este
/// fichero y [FiestucasColors] son los únicos que contienen hexadecimales:
/// cualquier widget que necesite un color lo pide por token.
abstract final class FiestucasTheme {
  // Modo claro.
  static const Color _bgLight = Color(0xFFFAF7ED);
  static const Color _surfaceLight = Color(0xFFFFFDF7);
  static const Color _primaryLight = Color(0xFF16583E);
  static const Color _onPrimaryLight = Color(0xFFFFFFFF);
  static const Color _textPrimaryLight = Color(0xFF11231B);
  static const Color _textSecondaryLight = Color(0xFF526559);
  static const Color _outlineLight = Color(0xFFAAB8A8);
  static const Color _errorLight = Color(0xFFA71D34);

  // Modo oscuro.
  static const Color _bgDark = Color(0xFF101A16);
  static const Color _surfaceDark = Color(0xFF17271F);
  static const Color _primaryDark = Color(0xFF7AC89A);
  static const Color _onPrimaryDark = Color(0xFF101A16);
  static const Color _textPrimaryDark = Color(0xFFF5F1E6);
  static const Color _textSecondaryDark = Color(0xFFBACABD);
  static const Color _outlineDark = Color(0xFF708878);
  static const Color _errorDark = Color(0xFFFF7E8B);

  /// Fondo detrás de diálogos, en claro.
  static const Color _scrimLight = Color(0x8C11231B); // #11231B al 55 %

  /// Fondo detrás de diálogos, en oscuro.
  static const Color _scrimDark = Color(0xA6000000); // negro al 65 %

  /// Tema claro.
  static ThemeData get light => _build(
    brightness: Brightness.light,
    marca: FiestucasColors.light,
    background: _bgLight,
    surface: _surfaceLight,
    primary: _primaryLight,
    onPrimary: _onPrimaryLight,
    textPrimary: _textPrimaryLight,
    textSecondary: _textSecondaryLight,
    outline: _outlineLight,
    error: _errorLight,
    scrim: _scrimLight,
  );

  /// Tema oscuro.
  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    marca: FiestucasColors.dark,
    background: _bgDark,
    surface: _surfaceDark,
    primary: _primaryDark,
    onPrimary: _onPrimaryDark,
    textPrimary: _textPrimaryDark,
    textSecondary: _textSecondaryDark,
    outline: _outlineDark,
    error: _errorDark,
    scrim: _scrimDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required FiestucasColors marca,
    required Color background,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color textPrimary,
    required Color textSecondary,
    required Color outline,
    required Color error,
    required Color scrim,
  }) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: marca.accentGold,
      onSecondary: marca.onAccentGold,
      error: error,
      onError: marca.onAction,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: outline,
      outlineVariant: outline,
      scrim: scrim,
      surfaceContainerHighest: marca.surfaceElevated,
      surfaceContainerLow: background,
    );

    final TextTheme textTheme = FiestucasTypography.textTheme(
      color: textPrimary,
      colorSecundario: textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      fontFamily: FiestucasTypography.body,
      extensions: <ThemeExtension<dynamic>>[marca],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(FiestucasSizes.buttonHeight),
          backgroundColor: marca.action,
          foregroundColor: marca.onAction,
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(FiestucasRadius.button),
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(FiestucasSizes.buttonHeight),
          backgroundColor: surface,
          foregroundColor: textPrimary,
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: outline),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(FiestucasRadius.button),
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(
            FiestucasSizes.touchTarget,
            FiestucasSizes.touchTarget,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(FiestucasRadius.card)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(FiestucasRadius.small),
          ),
          borderSide: BorderSide(color: outline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(FiestucasRadius.sheet),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, space: FiestucasSpacing.lg),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: marca.surfaceElevated,
        contentTextStyle: textTheme.bodyLarge,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
