import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' show AppleLogoPainter;

import '../../../../core/theme/fiestucas_spacing.dart';

/// Botón «Continuar con Apple».
///
/// Dibuja el logotipo con `AppleLogoPainter`, el trazado oficial que publica el
/// propio plugin, sobre las combinaciones de color que Apple aprueba: negro con
/// contenido blanco en claro, y blanco con contenido negro en oscuro. No se
/// recolorea ni se sustituye por un icono genérico.
///
/// No se usa el widget de botón del plugin porque su texto va a una sola línea
/// y se desborda en pantallas estrechas o con el texto del sistema ampliado.
/// Aquí el texto fluye igual que en el botón de Google, y el botón crece en
/// alto en vez de cortar la etiqueta.
class BotonApple extends StatelessWidget {
  const BotonApple({super.key, required this.onPressed, this.cargando = false});

  /// Qué hacer al pulsar. `null` deja el botón inactivo.
  final VoidCallback? onPressed;

  /// Si este botón es el que tiene un intento en curso.
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final bool oscuro = tema.brightness == Brightness.dark;

    // Combinaciones aprobadas por Apple.
    final Color fondo = oscuro ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final Color contenido = oscuro
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: 'Continuar con Apple',
      excludeSemantics: true,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: fondo,
          foregroundColor: contenido,
          disabledBackgroundColor: fondo.withValues(alpha: 0.5),
          disabledForegroundColor: contenido.withValues(alpha: 0.7),
          minimumSize: const Size.fromHeight(FiestucasSizes.buttonHeight),
          textStyle: tema.textTheme.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(FiestucasRadius.button),
            ),
          ),
        ),
        child: cargando
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: contenido,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // El logo se alinea ópticamente con el texto: Apple lo dibuja
                  // ligeramente más alto que ancho.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: SizedBox(
                      width: 18,
                      height: 22,
                      child: CustomPaint(
                        painter: AppleLogoPainter(color: contenido),
                      ),
                    ),
                  ),
                  const SizedBox(width: FiestucasSpacing.md),
                  Flexible(
                    child: Text(
                      'Continuar con Apple',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.labelLarge?.copyWith(
                        color: contenido,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
