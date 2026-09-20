/// Escala espacial, radios y tamaños mínimos de Fiestucas.
///
/// Los valores vienen de la sección 4 de `docs/producto/12-sistema-diseno.md`.
/// No se usan medidas arbitrarias fuera de esta escala.
abstract final class FiestucasSpacing {
  /// Ritmo general. Evitar valores intermedios.
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Margen horizontal de contenido de pantalla.
  static const double screenMargin = 20;

  /// Margen horizontal en móviles estrechos.
  static const double screenMarginNarrow = 16;

  /// Ancho por debajo del cual se usa [screenMarginNarrow].
  static const double narrowBreakpoint = 360;

  /// Separación entre secciones.
  static const double sectionGap = 24;
  static const double sectionGapWide = 32;

  /// Devuelve el margen horizontal que corresponde a [width].
  static double marginFor(double width) =>
      width < narrowBreakpoint ? screenMarginNarrow : screenMargin;
}

/// Radios de esquina del sistema de diseño.
abstract final class FiestucasRadius {
  /// Chips y campos de formulario.
  static const double small = 12;

  /// Botones principales.
  static const double button = 16;

  /// Tarjetas de evento.
  static const double card = 20;

  /// Hojas inferiores (solo las esquinas superiores).
  static const double sheet = 24;
}

/// Tamaños mínimos que garantizan que la interfaz se puede usar.
abstract final class FiestucasSizes {
  /// Altura mínima de una acción principal.
  static const double buttonHeight = 52;

  /// Lado mínimo de cualquier área táctil.
  static const double touchTarget = 48;
}
