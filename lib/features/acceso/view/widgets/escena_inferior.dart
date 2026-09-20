import 'package:flutter/material.dart';

import '../../../../core/theme/fiestucas_spacing.dart';

/// Ilustración panorámica que cierra la pantalla de acceso: el indicador de
/// madera, la costa de Cantabria y la albarca.
///
/// Es el motivo dominante de esta pantalla, y por eso no lleva ningún otro
/// adorno grande al lado. La imagen ya trae su propio borde superior irregular
/// en el canal alfa, así que no hace falta recortarla por arriba.
///
/// Debajo, sobre el color de fondo, van los enlaces legales. Entre una cosa y
/// otra hay una transición curva que muerde solo el borde inferior del dibujo:
/// la ilustración se ve entera.
class EscenaInferior extends StatelessWidget {
  const EscenaInferior({super.key, required this.pie});

  /// Contenido de la franja inferior: los enlaces a Privacidad y Condiciones.
  final Widget pie;

  /// Cuánto muerde la curva al borde inferior de la ilustración.
  static const double _altoCurva = 26;

  @override
  Widget build(BuildContext context) {
    final Color fondo = Theme.of(context).scaffoldBackgroundColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            // Alto acotado para que la pantalla entera quepa sin desplazar en
            // un móvil normal. Se recorta por arriba, que es cielo, y se
            // conserva lo que cuenta algo: el indicador, el pueblo y la
            // albarca.
            ExcludeSemantics(
              child: SizedBox(
                height: 132,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/escenas/inicio-abajo.webp',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, 0.35),
                ),
              ),
            ),
            ClipPath(
              clipper: _CurvaSuperior(),
              child: Container(
                width: double.infinity,
                height: _altoCurva,
                color: fondo,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + FiestucasSpacing.xs,
          ),
          child: pie,
        ),
      ],
    );
  }
}

/// Borde superior curvo, convexo hacia arriba, que separa la ilustración de la
/// franja de enlaces.
class _CurvaSuperior extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width / 2,
        -size.height * 0.5,
        size.width,
        size.height * 0.6,
      )
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
