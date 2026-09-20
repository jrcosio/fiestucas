import 'package:flutter/foundation.dart';

/// Proveedores de identidad admitidos. Cerrado a propósito: el producto no
/// ofrece contraseña, correo manual ni ninguna otra red.
enum ProveedorAcceso {
  google('Google'),
  apple('Apple');

  const ProveedorAcceso(this.nombre);

  /// Nombre tal y como se muestra a la persona.
  final String nombre;
}

/// Quien ha entrado en Fiestucas.
///
/// Se deriva de la sesión que custodia el servicio de identidad; la app no
/// guarda una copia propia. El [uid] es la única clave: ni el correo, ni el
/// nombre, ni la foto son requisito funcional, porque pueden faltar —Apple
/// permite ocultar el correo—.
@immutable
class SesionUsuario {
  const SesionUsuario({
    required this.uid,
    required this.proveedor,
    this.nombreVisible,
    this.correo,
  });

  /// Identificador estable de la cuenta.
  final String uid;

  /// Con qué proveedor se creó o recuperó esta sesión.
  final ProveedorAcceso proveedor;

  /// Nombre para saludar. Puede faltar.
  final String? nombreVisible;

  /// Correo. Puede faltar u ocultarse.
  final String? correo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SesionUsuario &&
          other.uid == uid &&
          other.proveedor == proveedor &&
          other.nombreVisible == nombreVisible &&
          other.correo == correo;

  @override
  int get hashCode => Object.hash(uid, proveedor, nombreVisible, correo);

  @override
  String toString() => 'SesionUsuario($uid, ${proveedor.name})';
}
