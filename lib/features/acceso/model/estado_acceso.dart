import 'package:flutter/foundation.dart';

import 'error_acceso.dart';
import 'sesion_usuario.dart';

/// Estado de la pantalla de acceso.
///
/// Unión cerrada con las cuatro situaciones que el principio III obliga a
/// modelar de forma explícita: inicial (datos), autenticando (carga), fallido
/// (error) y autenticado. No existe un estado «vacío» distinto del inicial:
/// esta pantalla no lista nada.
@immutable
sealed class EstadoAcceso {
  const EstadoAcceso();

  /// Nadie ha iniciado nada todavía.
  const factory EstadoAcceso.inicial() = AccesoInicial;

  /// Hay un intento en curso con [proveedor].
  const factory EstadoAcceso.autenticando(ProveedorAcceso proveedor) =
      AccesoAutenticando;

  /// El último intento terminó mal.
  const factory EstadoAcceso.fallido(
    ErrorAcceso motivo, {
    ProveedorAcceso? proveedor,
  }) = AccesoFallido;

  /// Hay sesión.
  const factory EstadoAcceso.autenticado(SesionUsuario sesion) =
      AccesoAutenticado;

  /// Si hay un intento en curso. Mientras sea cierto, la pantalla ignora
  /// cualquier pulsación nueva.
  bool get enCurso => this is AccesoAutenticando;
}

/// Estado de partida.
final class AccesoInicial extends EstadoAcceso {
  const AccesoInicial();

  @override
  bool operator ==(Object other) => other is AccesoInicial;

  @override
  int get hashCode => (AccesoInicial).hashCode;
}

/// Intento en curso.
final class AccesoAutenticando extends EstadoAcceso {
  const AccesoAutenticando(this.proveedor);

  /// Proveedor con el que se está intentando entrar.
  final ProveedorAcceso proveedor;

  @override
  bool operator ==(Object other) =>
      other is AccesoAutenticando && other.proveedor == proveedor;

  @override
  int get hashCode => Object.hash(AccesoAutenticando, proveedor);
}

/// El intento terminó sin sesión.
final class AccesoFallido extends EstadoAcceso {
  const AccesoFallido(this.motivo, {this.proveedor});

  /// Por qué falló.
  final ErrorAcceso motivo;

  /// Con qué proveedor se intentaba, para poder reintentar el mismo.
  final ProveedorAcceso? proveedor;

  @override
  bool operator ==(Object other) =>
      other is AccesoFallido &&
      other.motivo == motivo &&
      other.proveedor == proveedor;

  @override
  int get hashCode => Object.hash(AccesoFallido, motivo, proveedor);
}

/// Hay sesión.
final class AccesoAutenticado extends EstadoAcceso {
  const AccesoAutenticado(this.sesion);

  /// Quién ha entrado.
  final SesionUsuario sesion;

  @override
  bool operator ==(Object other) =>
      other is AccesoAutenticado && other.sesion == sesion;

  @override
  int get hashCode => Object.hash(AccesoAutenticado, sesion);
}
