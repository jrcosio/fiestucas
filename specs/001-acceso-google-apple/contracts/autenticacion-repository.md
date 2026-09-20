# Contrato — Repositorio de autenticación

**Fase 1** · Feature `001-acceso-google-apple`

Frontera entre la app y la fuente de identidad. El ViewModel depende **solo** de esta interfaz;
la implementación real habla con Firebase y con los plugins de proveedor, y la de pruebas no
habla con nadie. Esto es lo que hace verificable la pantalla sin consolas configuradas.

## Interfaz

```dart
abstract interface class AutenticacionRepository {
  /// Emite la sesión actual, o null cuando no hay ninguna.
  /// Emite un primer valor al suscribirse y en cada cambio posterior.
  Stream<SesionUsuario?> get sesion;

  /// Sesión actual sin esperar al stream. Null si no hay.
  SesionUsuario? get sesionActual;

  /// Abre el diálogo del proveedor y canjea la credencial por una sesión.
  /// Lanza [AccesoException] con un [ErrorAcceso] en cualquier fallo,
  /// incluida la cancelación de la persona.
  Future<SesionUsuario> entrarCon(ProveedorAcceso proveedor);

  /// True si el dispositivo puede ofrecer Sign in with Apple.
  Future<bool> appleDisponible();

  /// Cierra la sesión en Firebase y en el proveedor.
  Future<void> salir();
}
```

## Garantías que debe cumplir cualquier implementación

| # | Garantía | Requisito |
|---|---|---|
| C1 | `entrarCon` nunca devuelve normalmente sin sesión creada: o `SesionUsuario`, o excepción | FR-006 |
| C2 | La cancelación llega como `AccesoException(ErrorAcceso.cancelado)`, no como éxito ni como error genérico | FR-014 |
| C3 | Todo fallo se traduce a una variante de `ErrorAcceso`; **ninguna** excepción de Firebase o de los plugins escapa hacia el ViewModel | FR-014 |
| C4 | `sesion` emite un valor inicial al suscribirse, para poder decidir la pantalla de arranque sin parpadeo | FR-005 |
| C5 | `entrarCon` no realiza ninguna acción de producto: no publica, no envía, no escribe datos | FR-006 |
| C6 | `appleDisponible()` no lanza: ante la duda devuelve `false` | FR-014 |
| C7 | `salir()` es idempotente: sin sesión, no falla | FR-024 |

## Errores

```dart
class AccesoException implements Exception {
  const AccesoException(this.motivo, {this.detalle});
  final ErrorAcceso motivo;
  final String? detalle;   // Diagnóstico para registro; nunca se muestra crudo
}
```

El texto que ve la persona lo decide la capa de presentación a partir de `motivo`. El `detalle`
existe para el registro de fallos y **no** se pinta en pantalla.

## Implementaciones

| Implementación | Dónde | Para qué |
|---|---|---|
| `FirebaseAutenticacionRepository` | `lib/features/acceso/repository/` | Producción. Único punto que toca `firebase_auth`, `google_sign_in` y `sign_in_with_apple`. |
| `AutenticacionRepositoryFalso` | `test/` | Pruebas. Permite programar éxito, cada variante de `ErrorAcceso`, y retardo para comprobar el bloqueo durante la carga. |

## Contrato de la pantalla

| Acción de la persona | Efecto |
|---|---|
| Pulsar **Continuar con Google** | `entrarCon(google)`; estado → `Autenticando` |
| Pulsar **Continuar con Apple** | `entrarCon(apple)`; estado → `Autenticando` |
| Pulsar cualquier botón durante la carga | Ignorado |
| Pulsar **Ahora no** o retroceder | Cierra la pantalla sin tocar el repositorio |
| Pulsar **Privacidad** / **Condiciones** | Abre la pantalla legal correspondiente |
| Pulsar **Reintentar** tras un fallo | Repite `entrarCon` con el mismo proveedor |
