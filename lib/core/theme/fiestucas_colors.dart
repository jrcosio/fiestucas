import 'package:flutter/material.dart';

/// Colores de marca de Fiestucas que no caben en [ColorScheme].
///
/// Los valores salen de la tabla de la sección 2 de
/// `docs/producto/12-sistema-diseno.md`. Este fichero y [FiestucasTheme] son
/// los dos únicos sitios del proyecto donde puede aparecer un hexadecimal:
/// los widgets leen siempre por token.
///
/// ```dart
/// final brand = Theme.of(context).extension<FiestucasColors>()!;
/// final fondo = brand.action;
/// ```
@immutable
class FiestucasColors extends ThemeExtension<FiestucasColors> {
  const FiestucasColors({
    required this.action,
    required this.onAction,
    required this.surfaceElevated,
    required this.accentGold,
    required this.onAccentGold,
    required this.verificado,
    required this.comunidad,
    required this.cancelado,
    required this.pendiente,
  });

  /// Llamada a la acción principal: «+ Subir fiestuca» y equivalentes.
  final Color action;

  /// Contenido sobre [action].
  final Color onAction;

  /// Diálogos, menús y estados elevados.
  final Color surfaceElevated;

  /// Detalles, indicadores y destacados puntuales.
  final Color accentGold;

  /// Texto sobre un fondo [accentGold] sólido.
  final Color onAccentGold;

  /// Nivel de verificación «Oficial» o «Verificada».
  final Color verificado;

  /// Nivel de verificación «Comunidad» o pendiente de verificar.
  final Color comunidad;

  /// Evento cancelado.
  final Color cancelado;

  /// Propuesta pendiente de moderación.
  final Color pendiente;

  /// Paleta de marca en modo claro.
  static const FiestucasColors light = FiestucasColors(
    action: Color(0xFFB71C34),
    onAction: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    accentGold: Color(0xFF9A5900),
    onAccentGold: Color(0xFFFFFDF7),
    verificado: Color(0xFF16583E),
    comunidad: Color(0xFF526559),
    cancelado: Color(0xFFA71D34),
    pendiente: Color(0xFF9A5900),
  );

  /// Paleta de marca en modo oscuro.
  static const FiestucasColors dark = FiestucasColors(
    action: Color(0xFFF15B65),
    onAction: Color(0xFF101A16),
    surfaceElevated: Color(0xFF23372D),
    accentGold: Color(0xFFF5C15B),
    onAccentGold: Color(0xFF11231B),
    verificado: Color(0xFF7AC89A),
    comunidad: Color(0xFFBACABD),
    cancelado: Color(0xFFFF7E8B),
    pendiente: Color(0xFFF5C15B),
  );

  @override
  FiestucasColors copyWith({
    Color? action,
    Color? onAction,
    Color? surfaceElevated,
    Color? accentGold,
    Color? onAccentGold,
    Color? verificado,
    Color? comunidad,
    Color? cancelado,
    Color? pendiente,
  }) {
    return FiestucasColors(
      action: action ?? this.action,
      onAction: onAction ?? this.onAction,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      accentGold: accentGold ?? this.accentGold,
      onAccentGold: onAccentGold ?? this.onAccentGold,
      verificado: verificado ?? this.verificado,
      comunidad: comunidad ?? this.comunidad,
      cancelado: cancelado ?? this.cancelado,
      pendiente: pendiente ?? this.pendiente,
    );
  }

  @override
  FiestucasColors lerp(ThemeExtension<FiestucasColors>? other, double t) {
    if (other is! FiestucasColors) {
      return this;
    }
    return FiestucasColors(
      action: Color.lerp(action, other.action, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      onAccentGold: Color.lerp(onAccentGold, other.onAccentGold, t)!,
      verificado: Color.lerp(verificado, other.verificado, t)!,
      comunidad: Color.lerp(comunidad, other.comunidad, t)!,
      cancelado: Color.lerp(cancelado, other.cancelado, t)!,
      pendiente: Color.lerp(pendiente, other.pendiente, t)!,
    );
  }
}

/// Acceso breve a la paleta de marca desde un [BuildContext].
extension FiestucasColorsContext on BuildContext {
  /// Colores de marca del tema activo.
  FiestucasColors get marca => Theme.of(this).extension<FiestucasColors>()!;
}
