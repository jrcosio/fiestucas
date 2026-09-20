import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/estado_acceso.dart';
import '../model/sesion_usuario.dart';
import '../repository/autenticacion_repository.dart';

/// Fuente de identidad de la app.
///
/// Se sobrescribe en `main` con la implementación de Firebase, y en las pruebas
/// con un doble. Sin sobrescribir falla a propósito: nadie debe usar un
/// repositorio por defecto sin decidirlo.
final Provider<AutenticacionRepository> autenticacionRepositoryProvider =
    Provider<AutenticacionRepository>((Ref ref) {
      throw UnimplementedError(
        'Sobrescribe autenticacionRepositoryProvider en ProviderScope',
      );
    });

/// Sesión actual, o `null`. Decide qué pantalla ve la persona al arrancar.
final StreamProvider<SesionUsuario?> sesionProvider =
    StreamProvider<SesionUsuario?>((Ref ref) {
      return ref.watch(autenticacionRepositoryProvider).sesion;
    });

/// Si este dispositivo puede ofrecer Sign in with Apple.
final FutureProvider<bool> appleDisponibleProvider = FutureProvider<bool>((
  Ref ref,
) {
  return ref.watch(autenticacionRepositoryProvider).appleDisponible();
});

/// Estado de la pantalla de acceso.
final NotifierProvider<AccesoViewModel, EstadoAcceso> accesoViewModelProvider =
    NotifierProvider<AccesoViewModel, EstadoAcceso>(AccesoViewModel.new);

/// Coordina el estado y las acciones de la pantalla de acceso.
///
/// No sabe nada de Firebase ni de los proveedores: habla con el repositorio.
class AccesoViewModel extends Notifier<EstadoAcceso> {
  @override
  EstadoAcceso build() => const EstadoAcceso.inicial();

  AutenticacionRepository get _repositorio =>
      ref.read(autenticacionRepositoryProvider);

  /// Inicia el acceso con [proveedor].
  ///
  /// Si ya hay un intento en curso no hace nada: así una doble pulsación no
  /// abre dos diálogos.
  Future<void> entrarCon(ProveedorAcceso proveedor) async {
    if (state.enCurso) {
      return;
    }

    state = EstadoAcceso.autenticando(proveedor);

    try {
      final SesionUsuario sesion = await _repositorio.entrarCon(proveedor);
      state = EstadoAcceso.autenticado(sesion);
    } on AccesoException catch (e) {
      // En depuración se deja constancia del motivo y del detalle técnico. Es
      // especialmente útil con «cancelado»: en Android, un error de
      // configuración hace que el SDK devuelva ese código, y el plugin no
      // puede distinguirlo de que la persona cierre el diálogo. Sin esta
      // traza, un SHA-1 sin registrar se ve exactamente igual que una
      // cancelación normal.
      assert(() {
        debugPrint(
          'Acceso con ${proveedor.nombre} no completado: ${e.motivo.name}'
          '${e.detalle == null ? '' : ' — ${e.detalle}'}',
        );
        return true;
      }());

      // Cancelar es una decisión legítima: se vuelve al principio en silencio.
      state = e.motivo.esFallo
          ? EstadoAcceso.fallido(e.motivo, proveedor: proveedor)
          : const EstadoAcceso.inicial();
    }
  }

  /// Repite el último intento fallido con el mismo proveedor.
  Future<void> reintentar() async {
    final EstadoAcceso actual = state;
    if (actual is! AccesoFallido) {
      return;
    }
    final ProveedorAcceso? proveedor = actual.proveedor;
    if (proveedor == null) {
      state = const EstadoAcceso.inicial();
      return;
    }
    state = const EstadoAcceso.inicial();
    await entrarCon(proveedor);
  }

  /// Descarta el error y vuelve al estado de partida.
  void descartarError() {
    if (state is AccesoFallido) {
      state = const EstadoAcceso.inicial();
    }
  }
}
