# Data Model — Acceso con Google y Apple

**Fase 1** · Feature `001-acceso-google-apple`

Esta feature **no crea colecciones en Firestore ni almacenamiento propio**. Todo lo que sigue es
modelo de dominio en memoria, más la sesión que custodia Firebase Authentication.

---

## Entidades de dominio

### `SesionUsuario`

Representa a quien ha entrado. Se deriva del usuario de Firebase Auth; no se persiste aparte.

| Campo | Tipo | Notas |
|---|---|---|
| `uid` | `String` | Identificador estable de la cuenta. Único obligatorio. |
| `proveedor` | `ProveedorAcceso` | Con cuál entró. |
| `nombreVisible` | `String?` | Puede faltar. **Nunca** requisito funcional (FR-003). |
| `correo` | `String?` | Puede faltar u ocultarse (Apple). **Nunca** requisito funcional. |

**Reglas**:

- `uid` es la única clave de identidad. Dos proveedores distintos producen dos `uid` distintos:
  no hay enlazado automático por correo (FR-004).
- La app **no** guarda una copia propia de esta entidad. La fuente es el flujo de estado de
  autenticación; si Firebase dice que no hay sesión, no hay sesión.

### `ProveedorAcceso`

Enumeración cerrada: `google`, `apple`. No se admite ningún otro valor (FR-002).

### `EstadoAcceso`

Estado de la pantalla. Unión cerrada con exactamente estas variantes, que cubren los cuatro
estados que exige el principio III:

| Variante | Significado | Qué muestra |
|---|---|---|
| `Inicial` | Nadie ha pulsado nada | Los dos botones activos |
| `Autenticando(proveedor)` | Intento en curso | Progreso; botones bloqueados (FR-013) |
| `Fallido(ErrorAcceso)` | El intento terminó mal | Mensaje concreto y salida (FR-015) |
| `Autenticado(SesionUsuario)` | Hay sesión | Se abandona la pantalla |

**Transiciones válidas**:

```
Inicial        → Autenticando
Autenticando   → Autenticado | Fallido | Inicial (cancelación)
Fallido        → Autenticando (reintento) | Inicial
Autenticado    → (sale de la pantalla)
```

Desde `Autenticando` **no** se admite iniciar otro intento: esa es la regla que implementa el
bloqueo de pulsaciones repetidas.

### `ErrorAcceso`

Enumeración cerrada, una variante por cada condición nombrada en FR-014. El mapeo desde los
errores de los paquetes está fijado, no inferido:

| Variante | Origen Google | Origen Apple |
|---|---|---|
| `cancelado` | `GoogleSignInExceptionCode.canceled` | `AuthorizationErrorCode.canceled` |
| `sinRed` | `interrupted`, o `FirebaseAuthException('network-request-failed')` | `failed` con causa de red |
| `credencialInvalida` | `FirebaseAuthException('invalid-credential')` | ídem |
| `proveedorNoDisponible` | `providerConfigurationError`, `uiUnavailable` | `notHandled`, `invalidResponse` |
| `appleNoDisponible` | — | `SignInWithApple.isAvailable()` devuelve `false` |
| `sesionCaducada` | `FirebaseAuthException('user-token-expired')`, `'user-disabled'` | ídem |
| `desconocido` | `unknownError`, `clientConfigurationError`, `userMismatch` | `unknown` |

**Regla de presentación**: `cancelado` **no** se pinta como error (FR-014, US4 escenario 2). Se
vuelve a `Inicial` en silencio.

---

## Estado que esta feature NO gestiona

- **Borrador de cartel**: esta pantalla debe conservarlo, pero no lo posee. Llegará con la
  feature de Enviar cartel. Aquí se garantiza por construcción: la pantalla de acceso no
  destruye el estado de quien la invocó.
- **Favoritos de invitado**: la fusión al entrar pertenece a Guardadas (ver Assumptions del spec).
- **Preferencia de tema**: no se persiste; se sigue la del sistema (FR-017).

---

## Contrato con el exterior

El único punto de contacto con Firebase es el servicio de autenticación. Ni widgets ni ViewModel
lo tocan (principio III). La interfaz está en
[`contracts/autenticacion-repository.md`](contracts/autenticacion-repository.md).
