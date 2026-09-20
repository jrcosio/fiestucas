import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/fiestucas_spacing.dart';
import '../../acceso/model/sesion_usuario.dart';
import '../../acceso/view_model/acceso_view_model.dart';

/// PANTALLA PROVISIONAL.
///
/// Existe solo para poder comprobar en dispositivo que el acceso funciona de
/// extremo a extremo: confirma quién ha entrado y permite cerrar sesión para
/// repetir la prueba.
///
/// Desaparece en cuanto exista la pantalla de Inicio. Cuando eso ocurra, basta
/// con cambiar el destino en `main.dart`: la pantalla de acceso no se toca.
class SesionScreen extends ConsumerWidget {
  const SesionScreen({super.key, required this.sesion});

  /// Quién ha entrado.
  final SesionUsuario sesion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData tema = Theme.of(context);
    final String nombre = sesion.nombreVisible ?? 'sin nombre';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(FiestucasSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'assets/images/decor/corazon-01.webp',
                  width: 64,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: FiestucasSpacing.lg),
                Text(
                  '¡Ya estás dentro!',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.headlineMedium,
                ),
                const SizedBox(height: FiestucasSpacing.md),
                Text(
                  'Has entrado con ${sesion.proveedor.nombre} como $nombre.',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodyLarge,
                ),
                const SizedBox(height: FiestucasSpacing.sm),
                Text(
                  'Esta pantalla es provisional: la sustituirá Inicio.',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodySmall,
                ),
                const SizedBox(height: FiestucasSpacing.xxl),
                FilledButton(
                  onPressed: () =>
                      ref.read(autenticacionRepositoryProvider).salir(),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// PANTALLA PROVISIONAL para quien elige **Ahora no**.
///
/// El descubrimiento público es una promesa del producto, pero las pantallas
/// que lo hacen posible —Inicio, Mapa, Calendario— todavía no existen. Esto
/// deja constancia de que salir del acceso lleva a algún sitio, y permite
/// volver a intentarlo.
class InvitadoScreen extends StatelessWidget {
  const InvitadoScreen({super.key, required this.onVolverAlAcceso});

  /// Vuelve a la pantalla de acceso.
  final VoidCallback onVolverAlAcceso;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(FiestucasSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'assets/images/rotulos/rotulo-vive-nuestras-fiestas.webp',
                  width: 220,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: FiestucasSpacing.xl),
                Text(
                  'Estás explorando sin cuenta',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.headlineMedium,
                ),
                const SizedBox(height: FiestucasSpacing.md),
                Text(
                  'Descubrir fiestas no necesita cuenta. Inicio, Mapa y '
                  'Calendario llegarán en las próximas pantallas.',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodyLarge,
                ),
                const SizedBox(height: FiestucasSpacing.xxl),
                FilledButton(
                  onPressed: onVolverAlAcceso,
                  child: const Text('Identificarme'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
