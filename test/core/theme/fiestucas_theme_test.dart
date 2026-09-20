import 'dart:math' as math;

import 'package:fiestucas/core/theme/fiestucas_colors.dart';
import 'package:fiestucas/core/theme/fiestucas_spacing.dart';
import 'package:fiestucas/core/theme/fiestucas_theme.dart';
import 'package:fiestucas/core/theme/fiestucas_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Luminancia relativa según WCAG 2.2.
double _luminancia(Color c) {
  double canal(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * canal(c.r) + 0.7152 * canal(c.g) + 0.0722 * canal(c.b);
}

/// Relación de contraste entre dos colores opacos.
double _contraste(Color a, Color b) {
  final double la = _luminancia(a);
  final double lb = _luminancia(b);
  final double claro = math.max(la, lb);
  final double oscuro = math.min(la, lb);
  return (claro + 0.05) / (oscuro + 0.05);
}

void main() {
  group('Paleta', () {
    test('el tema claro expone los colores de marca del sistema de diseño', () {
      final FiestucasColors marca =
          FiestucasTheme.light.extension<FiestucasColors>()!;

      expect(marca.action, const Color(0xFFB71C34));
      expect(marca.onAction, const Color(0xFFFFFFFF));
      expect(marca.surfaceElevated, const Color(0xFFFFFFFF));
      expect(marca.accentGold, const Color(0xFF9A5900));
    });

    test('el tema oscuro expone su propia variante, no la clara', () {
      final FiestucasColors marca =
          FiestucasTheme.dark.extension<FiestucasColors>()!;

      expect(marca.action, const Color(0xFFF15B65));
      expect(marca.accentGold, const Color(0xFFF5C15B));
      expect(marca.action, isNot(FiestucasColors.light.action));
    });

    test('los tokens base coinciden en ambos temas', () {
      expect(FiestucasTheme.light.colorScheme.primary, const Color(0xFF16583E));
      expect(FiestucasTheme.light.colorScheme.onSurface, const Color(0xFF11231B));
      expect(FiestucasTheme.light.scaffoldBackgroundColor, const Color(0xFFFAF7ED));

      expect(FiestucasTheme.dark.colorScheme.primary, const Color(0xFF7AC89A));
      expect(FiestucasTheme.dark.colorScheme.onSurface, const Color(0xFFF5F1E6));
      expect(FiestucasTheme.dark.scaffoldBackgroundColor, const Color(0xFF101A16));
    });

    test('el brillo declarado corresponde con cada tema', () {
      expect(FiestucasTheme.light.brightness, Brightness.light);
      expect(FiestucasTheme.dark.brightness, Brightness.dark);
    });
  });

  group('Contraste (WCAG 2.2)', () {
    // Texto normal ≥ 4,5:1; texto grande e iconos funcionales ≥ 3:1.
    const double minimoTextoNormal = 4.5;

    test('texto principal sobre fondo, en claro y en oscuro', () {
      expect(
        _contraste(const Color(0xFF11231B), const Color(0xFFFAF7ED)),
        greaterThanOrEqualTo(minimoTextoNormal),
      );
      expect(
        _contraste(const Color(0xFFF5F1E6), const Color(0xFF101A16)),
        greaterThanOrEqualTo(minimoTextoNormal),
      );
    });

    test('texto secundario sobre fondo, en claro y en oscuro', () {
      expect(
        _contraste(const Color(0xFF526559), const Color(0xFFFAF7ED)),
        greaterThanOrEqualTo(minimoTextoNormal),
      );
      expect(
        _contraste(const Color(0xFFBACABD), const Color(0xFF101A16)),
        greaterThanOrEqualTo(minimoTextoNormal),
      );
    });

    test('contenido sobre el color de acción, en claro y en oscuro', () {
      expect(
        _contraste(FiestucasColors.light.onAction, FiestucasColors.light.action),
        greaterThanOrEqualTo(minimoTextoNormal),
      );
      expect(
        _contraste(FiestucasColors.dark.onAction, FiestucasColors.dark.action),
        greaterThanOrEqualTo(minimoTextoNormal),
      );
    });

    test('el color primario contrasta con el fondo en ambos temas', () {
      expect(
        _contraste(const Color(0xFF16583E), const Color(0xFFFAF7ED)),
        greaterThanOrEqualTo(minimoTextoNormal),
      );
      expect(
        _contraste(const Color(0xFF7AC89A), const Color(0xFF101A16)),
        greaterThanOrEqualTo(minimoTextoNormal),
      );
    });
  });

  group('Tipografía', () {
    test('los titulares usan Fraunces y el texto Nunito Sans', () {
      final TextTheme t = FiestucasTheme.light.textTheme;

      expect(t.displaySmall!.fontFamily, FiestucasTypography.display);
      expect(t.headlineMedium!.fontFamily, FiestucasTypography.display);
      expect(t.bodyLarge!.fontFamily, FiestucasTypography.body);
      expect(t.labelLarge!.fontFamily, FiestucasTypography.body);
    });

    test('los tamaños e interlineados son los de la tabla de diseño', () {
      final TextTheme t = FiestucasTheme.light.textTheme;

      expect(t.displaySmall!.fontSize, 30);
      expect(t.displaySmall!.height, 1.12);
      expect(t.headlineMedium!.fontSize, 24);
      expect(t.titleMedium!.fontSize, 18);
      expect(t.bodyLarge!.fontSize, 16);
      expect(t.bodyLarge!.height, 1.45);
      expect(t.bodyMedium!.fontSize, 14);
      expect(t.labelLarge!.fontWeight, FontWeight.w700);
    });
  });

  group('Formas y tamaños', () {
    test('los botones principales respetan la altura mínima', () {
      expect(FiestucasSizes.buttonHeight, 52);
      expect(FiestucasSizes.touchTarget, 48);
    });

    test('el margen horizontal se reduce en pantallas estrechas', () {
      expect(FiestucasSpacing.marginFor(430), FiestucasSpacing.screenMargin);
      expect(
        FiestucasSpacing.marginFor(320),
        FiestucasSpacing.screenMarginNarrow,
      );
    });
  });

  group('ThemeExtension', () {
    test('copyWith solo cambia lo indicado', () {
      const FiestucasColors base = FiestucasColors.light;
      final FiestucasColors copia = base.copyWith(action: const Color(0xFF000000));

      expect(copia.action, const Color(0xFF000000));
      expect(copia.accentGold, base.accentGold);
    });

    test('lerp interpola entre las dos paletas', () {
      final FiestucasColors medio = FiestucasColors.light.lerp(
        FiestucasColors.dark,
        1,
      );

      expect(medio.action, FiestucasColors.dark.action);
    });
  });
}
