import 'package:flutter/material.dart';

import '../../../core/theme/fiestucas_spacing.dart';

/// Los dos textos legales que enlaza la pantalla de acceso.
enum TextoLegal {
  privacidad('Privacidad'),
  condiciones('Condiciones');

  const TextoLegal(this.titulo);

  /// Título de la pantalla y del enlace.
  final String titulo;
}

/// Pantalla que muestra un texto legal.
///
/// El texto viaja dentro de la app: se puede leer sin conexión y no depende de
/// que haya una web publicada.
///
/// ATENCIÓN: el contenido de abajo es un **borrador de trabajo** que describe
/// lo que la app hace hoy. No es un texto legal revisado, y debe sustituirlo el
/// responsable del producto antes de publicar en las tiendas.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.texto});

  /// Cuál de los dos textos mostrar.
  final TextoLegal texto;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final List<_Apartado> apartados = _contenido[texto]!;

    return Scaffold(
      appBar: AppBar(title: Text(texto.titulo)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            FiestucasSpacing.screenMargin,
            FiestucasSpacing.lg,
            FiestucasSpacing.screenMargin,
            FiestucasSpacing.xxl,
          ),
          itemCount: apartados.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: FiestucasSpacing.xl),
          itemBuilder: (BuildContext context, int i) {
            final _Apartado a = apartados[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(a.titulo, style: tema.textTheme.titleMedium),
                const SizedBox(height: FiestucasSpacing.sm),
                Text(a.cuerpo, style: tema.textTheme.bodyLarge),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Apartado {
  const _Apartado(this.titulo, this.cuerpo);
  final String titulo;
  final String cuerpo;
}

const Map<TextoLegal, List<_Apartado>> _contenido =
    <TextoLegal, List<_Apartado>>{
      TextoLegal.privacidad: <_Apartado>[
        _Apartado(
          'Borrador pendiente de revisión',
          'Este texto describe lo que la aplicación hace hoy y sirve de punto '
              'de partida. Debe revisarlo el responsable del producto antes de '
              'publicar en las tiendas.',
        ),
        _Apartado(
          'Explorar no necesita cuenta',
          'Puedes ver qué fiestas hay, consultar su programa y guardar '
              'favoritos en este dispositivo sin identificarte.',
        ),
        _Apartado(
          'Qué guardamos si entras',
          'Al entrar con Google o con Apple se crea una cuenta identificada por '
              'un código interno. El correo y el nombre pueden faltar —Apple '
              'permite ocultar el correo— y la aplicación funciona igual sin '
              'ellos.',
        ),
        _Apartado(
          'Qué no hacemos',
          'No pedimos ni guardamos contraseñas, no mostramos tu identidad ni '
              'tus datos de contacto en las fichas públicas, y no unimos '
              'cuentas distintas porque compartan correo.',
        ),
        _Apartado(
          'Borrar tu cuenta',
          'Podrás eliminar tu cuenta desde los ajustes. Al hacerlo se borran o '
              'se anonimizan tus datos personales.',
        ),
      ],
      TextoLegal.condiciones: <_Apartado>[
        _Apartado(
          'Borrador pendiente de revisión',
          'Este texto describe lo que la aplicación hace hoy y sirve de punto '
              'de partida. Debe revisarlo el responsable del producto antes de '
              'publicar en las tiendas.',
        ),
        _Apartado(
          'Qué es Fiestucas',
          'Una guía de fiestas patronales, romerías, verbenas, ferias y '
              'celebraciones populares de Cantabria. No es una publicación '
              'oficial de ninguna administración.',
        ),
        _Apartado(
          'La información puede cambiar',
          'Los programas los publican quienes organizan cada fiesta y pueden '
              'cambiar o cancelarse. Cada ficha indica su fuente y cuándo se '
              'comprobó por última vez.',
        ),
        _Apartado(
          'Si aportas un cartel',
          'Tu propuesta pasa por revisión antes de hacerse pública. Al enviarla '
              'confirmas que puedes compartir esa imagen. Puedes pedir que se '
              'retire o se corrija.',
        ),
      ],
    };
