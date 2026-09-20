import 'package:flutter/material.dart';

import '../../../../core/theme/fiestucas_spacing.dart';

/// Botón «Continuar con Google».
///
/// Sigue las directrices de marca de Google: la «G» es el archivo oficial, sin
/// recolorear ni redibujar, sobre fondo claro y con el texto a su lado. El
/// resto —radio, altura y tipografía— lo pone el sistema de diseño de
/// Fiestucas.
class BotonGoogle extends StatelessWidget {
  const BotonGoogle({
    super.key,
    required this.onPressed,
    this.cargando = false,
  });

  /// Qué hacer al pulsar. `null` deja el botón inactivo.
  final VoidCallback? onPressed;

  /// Si este botón es el que tiene un intento en curso.
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: 'Continuar con Google',
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: onPressed,
        child: cargando
            ? const _Progreso()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/brand/google-g.webp',
                    height: 22,
                    width: 22,
                  ),
                  const SizedBox(width: FiestucasSpacing.md),
                  Flexible(
                    child: Text(
                      'Continuar con Google',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Indicador de progreso del tamaño de una línea de texto.
class _Progreso extends StatelessWidget {
  const _Progreso();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.4,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
