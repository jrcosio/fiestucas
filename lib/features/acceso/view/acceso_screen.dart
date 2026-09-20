import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/fiestucas_colors.dart';
import '../../../core/theme/fiestucas_spacing.dart';
import '../../legal/view/legal_screen.dart';
import '../model/error_acceso.dart';
import '../model/estado_acceso.dart';
import '../model/sesion_usuario.dart';
import '../view_model/acceso_view_model.dart';
import 'widgets/boton_apple.dart';
import 'widgets/boton_google.dart';
import 'widgets/escena_inferior.dart';
import 'widgets/guirnalda_superior.dart';
import 'widgets/logo_con_confeti.dart';

/// Pantalla de acceso con Google y Apple.
///
/// Observa el ViewModel y le envía acciones; no sabe nada de Firebase ni de
/// los proveedores.
class AccesoScreen extends ConsumerWidget {
  const AccesoScreen({super.key, this.onAhoraNo, this.mensajeContexto});

  /// Qué hacer cuando la persona decide no identificarse ahora. Si es `null`,
  /// se cierra la pantalla devolviendo el control a quien la abrió.
  final VoidCallback? onAhoraNo;

  /// Mensaje de quien abre la pantalla, por ejemplo para aclarar que el cartel
  /// en curso no se pierde. Lo aportará la feature de Enviar cartel.
  final String? mensajeContexto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EstadoAcceso estado = ref.watch(accesoViewModelProvider);
    // Ante la duda se asume disponible y es el propio intento el que informa:
    // es preferible a esconder una opción válida mientras se comprueba.
    final bool appleDisponible = ref.watch(appleDisponibleProvider).value ?? true;

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double margen = FiestucasSpacing.marginFor(constraints.maxWidth);

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SafeArea(bottom: false, child: GuirnaldaSuperior()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: margen),
                    child: _Contenido(
                      estado: estado,
                      appleDisponible: appleDisponible,
                      mensajeContexto: mensajeContexto,
                      onProveedor: (ProveedorAcceso p) => ref
                          .read(accesoViewModelProvider.notifier)
                          .entrarCon(p),
                      onReintentar: () =>
                          ref.read(accesoViewModelProvider.notifier).reintentar(),
                      onAhoraNo: () {
                        final VoidCallback? salida = onAhoraNo;
                        if (salida != null) {
                          salida();
                        } else {
                          Navigator.maybePop(context);
                        }
                      },
                    ),
                  ),
                  EscenaInferior(pie: const _EnlacesLegales()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Bloque central: marca, invitación y acciones.
class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.estado,
    required this.appleDisponible,
    required this.onProveedor,
    required this.onReintentar,
    required this.onAhoraNo,
    this.mensajeContexto,
  });

  final EstadoAcceso estado;
  final bool appleDisponible;
  final String? mensajeContexto;
  final void Function(ProveedorAcceso) onProveedor;
  final VoidCallback onReintentar;
  final VoidCallback onAhoraNo;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final EstadoAcceso actual = estado;
    final bool enCurso = actual.enCurso;
    final ProveedorAcceso? enMarcha = actual is AccesoAutenticando
        ? actual.proveedor
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const LogoConConfeti(),
        const SizedBox(height: FiestucasSpacing.lg),
        Text(
          'Entra en Fiestucas',
          textAlign: TextAlign.center,
          style: tema.textTheme.displaySmall?.copyWith(
            color: tema.colorScheme.primary,
          ),
        ),
        const SizedBox(height: FiestucasSpacing.sm),
        Text(
          'Guarda tus fiestas y comparte las que faltan.',
          textAlign: TextAlign.center,
          style: tema.textTheme.bodyLarge,
        ),
        if (mensajeContexto != null) ...<Widget>[
          const SizedBox(height: FiestucasSpacing.md),
          Text(
            mensajeContexto!,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: FiestucasSpacing.xl),
        BotonGoogle(
          cargando: enMarcha == ProveedorAcceso.google,
          onPressed: enCurso ? null : () => onProveedor(ProveedorAcceso.google),
        ),
        const SizedBox(height: FiestucasSpacing.md),
        if (appleDisponible)
          BotonApple(
            cargando: enMarcha == ProveedorAcceso.apple,
            onPressed: enCurso
                ? null
                : () => onProveedor(ProveedorAcceso.apple),
          )
        else
          // Ni se oculta sin explicación ni se ofrece una tercera vía: se dice
          // lo que pasa y Google sigue ahí.
          Text(
            'Este dispositivo no ofrece Apple. Puedes entrar con Google.',
            textAlign: TextAlign.center,
            style: tema.textTheme.bodySmall,
          ),
        if (actual is AccesoFallido) ...<Widget>[
          const SizedBox(height: FiestucasSpacing.lg),
          _Aviso(fallido: actual, onReintentar: onReintentar),
        ],
        const SizedBox(height: FiestucasSpacing.xl),
        TextButton(
          onPressed: enCurso ? null : onAhoraNo,
          child: Text(
            'Ahora no',
            style: tema.textTheme.labelLarge?.copyWith(
              color: tema.colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: tema.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: FiestucasSpacing.xs),
        Text(
          'Puedes explorar las fiestas sin cuenta',
          textAlign: TextAlign.center,
          style: tema.textTheme.bodySmall,
        ),
        const SizedBox(height: FiestucasSpacing.lg),
      ],
    );
  }
}

/// Explica qué ha fallado y ofrece salida.
///
/// El color nunca es la única señal: siempre hay icono y texto.
class _Aviso extends StatelessWidget {
  const _Aviso({required this.fallido, required this.onReintentar});

  final AccesoFallido fallido;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final FiestucasColors marca = context.marca;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(FiestucasSpacing.lg),
        decoration: BoxDecoration(
          color: marca.surfaceElevated,
          borderRadius: BorderRadius.circular(FiestucasRadius.small),
          border: Border.all(color: tema.colorScheme.error),
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  color: tema.colorScheme.error,
                  size: 22,
                  semanticLabel: 'Error',
                ),
                const SizedBox(width: FiestucasSpacing.md),
                Expanded(
                  child: Text(
                    _mensaje(fallido),
                    style: tema.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            if (fallido.motivo.permiteReintento) ...<Widget>[
              const SizedBox(height: FiestucasSpacing.md),
              TextButton(
                onPressed: onReintentar,
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _mensaje(AccesoFallido fallido) {
    final String proveedor = fallido.proveedor?.nombre ?? 'El proveedor';
    return switch (fallido.motivo) {
      ErrorAcceso.sinRed =>
        'No hay conexión. Comprueba la red y vuelve a intentarlo; tu cartel '
            'sigue aquí.',
      ErrorAcceso.credencialInvalida =>
        'No hemos podido validar tu identidad. Vuelve a intentarlo.',
      ErrorAcceso.proveedorNoDisponible =>
        '$proveedor no está disponible ahora mismo. Prueba con el otro o '
            'inténtalo más tarde.',
      ErrorAcceso.appleNoDisponible =>
        'Este dispositivo no ofrece Apple. Puedes entrar con Google.',
      ErrorAcceso.sesionCaducada =>
        'Tu sesión ha caducado. Vuelve a identificarte para continuar.',
      ErrorAcceso.desconocido =>
        'Algo ha fallado al entrar. Vuelve a intentarlo.',
      // La cancelación no llega hasta aquí: se vuelve al estado inicial.
      ErrorAcceso.cancelado => 'No se ha completado el acceso.',
    };
  }
}

/// Enlaces a Privacidad y Condiciones, al pie de la pantalla.
class _EnlacesLegales extends StatelessWidget {
  const _EnlacesLegales();

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    // Wrap y no Row: con el texto del sistema muy ampliado, o en pantallas
    // estrechas, los dos enlaces pasan a líneas distintas en vez de salirse.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        const _Enlace(texto: TextoLegal.privacidad),
        Text('·', style: tema.textTheme.bodySmall),
        const _Enlace(texto: TextoLegal.condiciones),
      ],
    );
  }
}

class _Enlace extends StatelessWidget {
  const _Enlace({required this.texto});

  final TextoLegal texto;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LegalScreen(texto: texto),
        ),
      ),
      child: ConstrainedBox(
        // Área táctil mínima: un enlace de pie sigue teniendo que poder
        // pulsarse con el dedo.
        constraints: const BoxConstraints(
          minHeight: FiestucasSizes.touchTarget,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FiestucasSpacing.md,
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              texto.titulo,
              style: tema.textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
