import 'package:flutter/material.dart';

import '../../../../core/theme/fiestucas_spacing.dart';

/// Logo de Fiestucas rodeado de trazos de confeti, con el lema debajo.
///
/// El logo es una imagen con significado y lleva descripción accesible; el
/// confeti es ornamento y queda fuera del árbol semántico.
///
/// El lema se compone como texto, no como imagen: el archivo del logo no lo
/// incluye, y así escala con el ajuste de texto del sistema y se puede leer en
/// voz alta.
class LogoConConfeti extends StatelessWidget {
  const LogoConConfeti({super.key, this.anchoLogo = 158});

  /// Ancho del logo en píxeles lógicos.
  final double anchoLogo;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final bool oscuro = tema.brightness == Brightness.dark;

    // El logo lleva tinta oscura: sobre fondo oscuro necesita una placa clara,
    // como exige la sección 6 del sistema de diseño. Nunca se invierte.
    final Widget logo = Semantics(
      label: 'Fiestucas',
      image: true,
      child: Image.asset(
        'assets/images/brand/logo.webp',
        width: anchoLogo,
        fit: BoxFit.contain,
      ),
    );

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: <Widget>[
        ExcludeSemantics(
          child: SizedBox(
            width: anchoLogo * 1.9,
            height: anchoLogo * 1.15,
            child: const Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(left: 0, top: 24, width: 46, child: _Confeti('01')),
                Positioned(right: 4, top: 12, width: 52, child: _Confeti('06')),
                Positioned(left: 10, bottom: 34, width: 40, child: _Confeti('04')),
                Positioned(right: 6, bottom: 28, width: 44, child: _Confeti('02')),
              ],
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (oscuro)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FiestucasSpacing.lg,
                  vertical: FiestucasSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF7),
                  borderRadius: BorderRadius.circular(FiestucasRadius.card),
                ),
                child: logo,
              )
            else
              logo,
            const SizedBox(height: FiestucasSpacing.sm),
            Text(
              'Fiestas y romerías de Cantabria',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: tema.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Un trazo de confeti de la lámina de recursos.
class _Confeti extends StatelessWidget {
  const _Confeti(this.numero);

  final String numero;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/decor/confeti-$numero.webp',
      fit: BoxFit.contain,
    );
  }
}
