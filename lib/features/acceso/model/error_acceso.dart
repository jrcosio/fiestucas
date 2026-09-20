/// Motivos por los que un intento de acceso puede no terminar en sesión.
///
/// Lista cerrada: el repositorio traduce a una de estas variantes cualquier
/// fallo de Firebase o de los plugins de proveedor, de modo que ninguna
/// excepción de terceros llega a la interfaz.
enum ErrorAcceso {
  /// La persona cerró el diálogo del proveedor. No es un error.
  cancelado,

  /// No hay conexión o se perdió a mitad del intercambio.
  sinRed,

  /// El proveedor devolvió una credencial que el servicio de identidad
  /// rechaza.
  credencialInvalida,

  /// El proveedor no está disponible ahora mismo, o no puede mostrar su
  /// diálogo.
  proveedorNoDisponible,

  /// Este dispositivo no ofrece Sign in with Apple.
  appleNoDisponible,

  /// La sesión caducó o la cuenta fue eliminada o deshabilitada.
  sesionCaducada,

  /// Cualquier otra cosa. Se registra con detalle, se muestra genérico.
  desconocido;

  /// Si este motivo debe presentarse como un error.
  ///
  /// La cancelación es una decisión legítima de la persona: se vuelve al
  /// estado inicial en silencio, sin tono de alarma.
  bool get esFallo => this != ErrorAcceso.cancelado;

  /// Si ofrecer un botón de reintento tiene sentido.
  bool get permiteReintento => switch (this) {
    ErrorAcceso.cancelado || ErrorAcceso.appleNoDisponible => false,
    _ => true,
  };
}
