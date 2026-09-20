import 'package:flutter/material.dart';

/// Guirnaldas que cuelgan de las dos esquinas superiores.
///
/// Es puro ornamento: va excluido del árbol semántico para que quien use un
/// lector de pantalla no tenga que oír nada sobre ella.
class GuirnaldaSuperior extends StatelessWidget {
  const GuirnaldaSuperior({super.key, this.alto = 78});

  /// Alto de la banda decorativa.
  final double alto;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: alto,
        width: double.infinity,
        child: ClipRect(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double ancho = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  // Izquierda: la guirnalda entra desde fuera de la pantalla,
                  // de modo que el borde la corta como en un tendido real.
                  Positioned(
                    left: -ancho * 0.12,
                    top: -alto * 0.22,
                    width: ancho * 0.64,
                    child: Image.asset(
                      'assets/images/decor/guirnalda-03.webp',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  // Derecha: otra guirnalda, reflejada para que no se note que
                  // es el mismo dibujo.
                  Positioned(
                    right: -ancho * 0.10,
                    top: -alto * 0.30,
                    width: ancho * 0.58,
                    child: Transform.flip(
                      flipX: true,
                      child: Image.asset(
                        'assets/images/decor/guirnalda-02.webp',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
