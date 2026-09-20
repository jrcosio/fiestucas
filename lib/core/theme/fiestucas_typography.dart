import 'package:flutter/material.dart';

/// Tipografía de Fiestucas.
///
/// Fraunces para titulares con carácter, Nunito Sans para todo lo que hay que
/// leer con prisa. Tamaños e interlineados de la tabla de la sección 3 de
/// `docs/producto/12-sistema-diseno.md`.
///
/// Los tamaños son lógicos: Flutter aplica encima el escalado de texto del
/// sistema, que esta app respeta sin limitar a una sola línea.
abstract final class FiestucasTypography {
  /// Familia de titulares.
  static const String display = 'Fraunces';

  /// Familia de texto, etiquetas y botones.
  static const String body = 'Nunito Sans';

  /// Construye el [TextTheme] con [color] como tinta principal y
  /// [colorSecundario] para metadatos y apoyo.
  static TextTheme textTheme({
    required Color color,
    required Color colorSecundario,
  }) {
    return TextTheme(
      // Título de pantalla.
      displaySmall: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w600,
        fontSize: 30,
        height: 1.12,
        color: color,
      ),
      // Título de sección.
      headlineMedium: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        height: 1.18,
        color: color,
      ),
      // Título de tarjeta.
      titleMedium: TextStyle(
        fontFamily: body,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        height: 1.25,
        color: color,
      ),
      // Texto normal.
      bodyLarge: TextStyle(
        fontFamily: body,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.45,
        color: color,
      ),
      // Metadatos: fecha, municipio.
      bodyMedium: TextStyle(
        fontFamily: body,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.35,
        color: colorSecundario,
      ),
      // Pie y anotación breve.
      bodySmall: TextStyle(
        fontFamily: body,
        fontWeight: FontWeight.w400,
        fontSize: 13,
        height: 1.35,
        color: colorSecundario,
      ),
      // Botón y etiqueta.
      labelLarge: TextStyle(
        fontFamily: body,
        fontWeight: FontWeight.w700,
        fontSize: 16,
        height: 1.20,
        color: color,
      ),
    );
  }
}
