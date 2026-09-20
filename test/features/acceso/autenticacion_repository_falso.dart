import 'dart:async';

import 'package:fiestucas/features/acceso/model/error_acceso.dart';
import 'package:fiestucas/features/acceso/model/sesion_usuario.dart';
import 'package:fiestucas/features/acceso/repository/autenticacion_repository.dart';

/// Doble programable de [AutenticacionRepository] para las pruebas.
///
/// No habla con Firebase ni con ningún proveedor: permite comprobar la
/// pantalla y el ViewModel enteros sin tener las consolas configuradas.
class AutenticacionRepositoryFalso implements AutenticacionRepository {
  AutenticacionRepositoryFalso({
    this.errorAlEntrar,
    this.retardo = Duration.zero,
    this.appleEstaDisponible = true,
    SesionUsuario? sesionInicial,
  }) : _sesionActual = sesionInicial;

  /// Si no es nulo, `entrarCon` falla con este motivo en vez de crear sesión.
  ErrorAcceso? errorAlEntrar;

  /// Retardo artificial de `entrarCon`, para comprobar el estado de carga.
  Duration retardo;

  /// Lo que devuelve [appleDisponible]. Se puede cambiar entre pruebas.
  bool appleEstaDisponible;

  SesionUsuario? _sesionActual;

  final StreamController<SesionUsuario?> _controlador =
      StreamController<SesionUsuario?>.broadcast();

  /// Cuántas veces se ha llamado a `entrarCon`. Sirve para comprobar que una
  /// pulsación durante la carga no inicia un segundo intento.
  int intentos = 0;

  /// Proveedores con los que se ha intentado entrar, en orden.
  final List<ProveedorAcceso> proveedoresUsados = <ProveedorAcceso>[];

  /// Cuántas veces se ha cerrado sesión.
  int salidas = 0;

  @override
  Stream<SesionUsuario?> get sesion async* {
    yield _sesionActual;
    yield* _controlador.stream;
  }

  @override
  SesionUsuario? get sesionActual => _sesionActual;

  @override
  Future<SesionUsuario> entrarCon(ProveedorAcceso proveedor) async {
    intentos++;
    proveedoresUsados.add(proveedor);

    if (retardo > Duration.zero) {
      await Future<void>.delayed(retardo);
    }

    final ErrorAcceso? motivo = errorAlEntrar;
    if (motivo != null) {
      throw AccesoException(motivo, detalle: 'doble de pruebas');
    }

    final SesionUsuario nueva = SesionUsuario(
      uid: 'uid-${proveedor.name}',
      proveedor: proveedor,
      nombreVisible: 'Persona de prueba',
      correo: proveedor == ProveedorAcceso.apple ? null : 'prueba@ejemplo.es',
    );
    _sesionActual = nueva;
    _controlador.add(nueva);
    return nueva;
  }

  @override
  Future<bool> appleDisponible() async => appleEstaDisponible;

  @override
  Future<void> salir() async {
    salidas++;
    _sesionActual = null;
    _controlador.add(null);
  }

  /// Libera el stream al terminar la prueba.
  Future<void> cerrar() => _controlador.close();
}
