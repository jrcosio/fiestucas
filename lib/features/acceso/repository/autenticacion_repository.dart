import '../model/error_acceso.dart';
import '../model/sesion_usuario.dart';

/// Frontera entre la app y la fuente de identidad.
///
/// El ViewModel depende solo de esta interfaz. La implementación de producción
/// es el único punto del proyecto que habla con Firebase y con los plugins de
/// proveedor; la de pruebas no habla con nadie, y por eso la pantalla se puede
/// verificar entera sin consolas configuradas.
///
/// Garantías que toda implementación debe cumplir (ver
/// `specs/001-acceso-google-apple/contracts/autenticacion-repository.md`):
///
/// - `entrarCon` nunca devuelve normalmente sin sesión: o [SesionUsuario], o
///   [AccesoException].
/// - La cancelación llega como [ErrorAcceso.cancelado], no como éxito.
/// - Ninguna excepción de Firebase o de los plugins escapa hacia arriba.
/// - [sesion] emite un valor en cuanto se escucha, para decidir la pantalla de
///   arranque sin parpadeo.
/// - `entrarCon` no ejecuta ninguna acción de producto: identificarse no
///   publica ni envía nada.
abstract interface class AutenticacionRepository {
  /// Sesión actual, o `null` si no hay. Emite al suscribirse y en cada cambio.
  Stream<SesionUsuario?> get sesion;

  /// Sesión actual sin esperar al stream.
  SesionUsuario? get sesionActual;

  /// Abre el diálogo de [proveedor] y canjea la credencial por una sesión.
  ///
  /// Lanza [AccesoException] ante cualquier desenlace que no sea una sesión,
  /// incluida la cancelación.
  Future<SesionUsuario> entrarCon(ProveedorAcceso proveedor);

  /// Si este dispositivo puede ofrecer Sign in with Apple.
  ///
  /// No lanza: ante la duda devuelve `false`.
  Future<bool> appleDisponible();

  /// Cierra la sesión. Idempotente: sin sesión, no falla.
  Future<void> salir();
}

/// Lo que puede salir mal al entrar, ya traducido al dominio.
class AccesoException implements Exception {
  const AccesoException(this.motivo, {this.detalle});

  /// Motivo, del que la interfaz deriva el texto que ve la persona.
  final ErrorAcceso motivo;

  /// Diagnóstico técnico para el registro. **Nunca** se muestra en pantalla.
  final String? detalle;

  @override
  String toString() =>
      'AccesoException(${motivo.name}${detalle == null ? '' : ': $detalle'})';
}
