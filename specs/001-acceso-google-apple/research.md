# Research — Acceso con Google y Apple

**Fase 0** · 2026-09-20 · Feature `001-acceso-google-apple`

Todas las versiones se han resuelto contra pub.dev con `flutter pub add --dry-run` y las APIs se
han verificado leyendo el código de los paquetes en `~/.pub-cache`, no de memoria.

---

## D1 — Gestión de estado

**Decisión**: `flutter_riverpod` **3.4.3**, sin generación de código.

**Rationale**: La constitución fija Riverpod 3.x (principio III). Se usan `Notifier` y
`AsyncNotifier`, que son la API principal de la 3.x; `StateNotifier` está retirado. Evitamos
`riverpod_generator` y `build_runner`: para cuatro proveedores añaden un paso de compilación y
una dependencia de desarrollo sin aportar nada.

**Alternativas**: `riverpod_generator` (descartado por coste/beneficio en esta escala);
`provider` o `bloc` (descartados, los prohíbe el principio III).

---

## D2 — Identidad: intercambio de credenciales

**Decisión**: `firebase_auth` **6.7.0** como fuente de sesión; `google_sign_in` **7.2.0** y
`sign_in_with_apple` **8.2.0** solo para obtener la credencial del proveedor, que se canjea por
una sesión de Firebase.

**Rationale**: Firebase Auth gestiona emisión, renovación y persistencia de la sesión
(`authStateChanges`), que es justo lo que pide FR-005. Los plugins de proveedor no guardan
sesión: entregan un token y se apartan.

Flujo con Google:

```
GoogleSignIn.instance.authenticate()
  → GoogleSignInAccount.authentication.idToken
  → GoogleAuthProvider.credential(idToken: ...)
  → FirebaseAuth.instance.signInWithCredential(...)
```

Flujo con Apple: idéntico, con `OAuthProvider('apple.com').credential(idToken:, rawNonce:)`.

---

## D3 — API de `google_sign_in` 7.x (cambio incompatible respecto a 6.x)

**Decisión**: usar la API de instancia única, no la antigua `GoogleSignIn().signIn()`.

**Verificado en el paquete**:

- `GoogleSignIn.instance` es un singleton.
- `await GoogleSignIn.instance.initialize({clientId, serverClientId})` **debe llamarse una vez
  antes de cualquier otra operación**.
- `GoogleSignIn.instance.supportsAuthenticate()` indica si la plataforma permite iniciar el flujo
  desde la app; en iOS y Android devuelve `true`.
- `await GoogleSignIn.instance.authenticate()` abre el diálogo y devuelve `GoogleSignInAccount`.
- `account.authentication` → `GoogleSignInAuthentication`, cuyo único campo es
  `String? idToken` (`google_sign_in.dart:62`). El `accessToken` ya no vive aquí; se pide por
  `authorizationClient` y **no hace falta** para Firebase.
- Los errores llegan como `GoogleSignInException` con un `GoogleSignInExceptionCode`:
  `canceled`, `interrupted`, `clientConfigurationError`, `providerConfigurationError`,
  `uiUnavailable`, `userMismatch`, `unknownError`
  (`google_sign_in_platform_interface-3.1.0/lib/src/types.dart:38`).

**Consecuencia para FR-014**: el mapeo de errores sale directo de ese enum, sin adivinar cadenas.

**Trampa conocida**: en **Android**, `initialize()` necesita `serverClientId` con el **client ID
de tipo web** del proyecto Firebase (el `client_type: 3` de `google-services.json`). Sin él el
`idToken` se emite para otra audiencia y Firebase rechaza la credencial. En **iOS** el
`clientId` se toma del `GoogleService-Info.plist`, y hace falta registrar el esquema de URL
inverso (`REVERSED_CLIENT_ID`) en `Info.plist`.

---

## D4 — API de `sign_in_with_apple` 8.2.0

**Decisión**: `SignInWithApple.getAppleIDCredential(scopes: [email, fullName], nonce:, ...)`.

**Verificado en el paquete**:

- `SignInWithApple.isAvailable()` existe (`lib/src/sign_in_with_apple.dart:28`) y resuelve
  directamente el requisito de FR-014 «Apple no disponible en el dispositivo».
- Errores: `SignInWithAppleAuthorizationException` con `AuthorizationErrorCode`: `canceled`,
  `failed`, `invalidResponse`, `notHandled`, `unknown`
  (`sign_in_with_apple_platform_interface-2.0.0/lib/exceptions.dart:114`).
- La credencial devuelve `identityToken`, `authorizationCode`, `userIdentifier`, y nombre y
  correo **solo la primera vez**.

**Nonce**: Firebase exige que el `idToken` de Apple venga con un nonce. El patrón correcto es
generar un nonce aleatorio, enviar a Apple su **SHA-256** y pasar a Firebase el **nonce en
claro** como `rawNonce`. Se usa `crypto`, que ya entra como dependencia transitiva de Riverpod.

**Apple en Android**: `sign_in_with_apple` lo resuelve con un flujo web que exige
`WebAuthenticationOptions(clientId: <Service ID>, redirectUri: <handler de Firebase>)`. Es
configuración de consola, no de código, y está recogida en las tareas de plataforma.

---

## D5 — Nombre y correo: qué guardamos

**Decisión**: no persistir nada propio en esta feature. La cuenta es el usuario de Firebase Auth.

**Rationale**: FR-003 prohíbe depender del correo, el nombre o la foto; `11-acceso.md` recuerda
que Apple puede ocultar el correo. Crear un documento de perfil en Firestore sería adelantar
Firestore sin una funcionalidad que lo use, contra el principio IV. El `uid` de Firebase ya
cumple lo que FR-004 pide: proveedores distintos producen cuentas distintas, porque no
activamos el enlazado automático por correo.

---

## D6 — Botones de proveedor

**Decisión**: botón de Apple con el widget oficial del paquete (`SignInWithAppleButton`,
estilo negro, texto «Continuar con Apple», altura 52, radio 16). Botón de Google propio, con la
marca «G» oficial descargada como asset.

**Rationale**: FR-001 obliga a respetar las marcas de cada proveedor. Apple es estricta con su
botón y el paquete ya entrega una variante conforme y parametrizable, que además encaja con el
mockup. Google permite un botón propio siempre que la «G» no se recoloree ni se redibuje, lo que
nos deja ajustar tipografía y radio al sistema de diseño.

**Alternativa descartada**: dibujar ambos logotipos como iconos genéricos — lo prohíbe
explícitamente la tabla de componentes del sistema de diseño.

---

## D7 — Conversión de recursos gráficos

**Decisión**: `cwebp` **1.6.0** (Homebrew, ya instalado). Sin pérdida (`-lossless -z 9`) para el
arte plano con transparencia; con pérdida (`-q 85 -alpha_q 100`) para la ilustración panorámica.

**Rationale**: en el sistema no había ningún codificador WebP (`sips` y `ffmpeg` solo leen ese
formato). El arte plano —guirnaldas, corazones, confeti, rótulos— son zonas de color sólido:
sin pérdida comprime bien y evita los halos que la compresión con pérdida deja en los bordes con
alfa. `inicio_abajo.png` es una ilustración pictórica de 1,91 MB y 1942 × 809: ahí la pérdida
controlada es lo que justifica el formato.

---

## D8 — Tipografías

**Decisión**: descargar de Google Fonts los estáticos **Fraunces 600** y **Nunito Sans 400, 500,
700**, empaquetarlos en `assets/fonts/` con sus `OFL.txt` y declararlos en `pubspec.yaml`.

**Rationale**: el sistema de diseño lo pide expresamente y así la app funciona sin red y pinta
siempre con la tipografía correcta. Las variables completas pesan bastante más y no necesitamos
ejes intermedios. El paquete `google_fonts` se descartó por descargar en tiempo de ejecución.

---

## D9 — Estructura y arranque

**Decisión**: `ProviderScope` envolviendo la app en `main.dart`; un widget raíz decide entre
acceso y pantalla de sesión observando el estado de autenticación.

**Rationale**: resuelve FR-005 (no mostrar el acceso con sesión válida) y FR-024 sin introducir
un router. `go_router` se descarta aquí a propósito: la navegación real la define la feature de
Inicio, y adelantarla ahora sería decidir por ella.

---

## D10 — Pruebas

**Decisión**: doble de la fuente de identidad (una implementación de prueba del repositorio), no
`mockito` ni `firebase_auth_mocks`.

**Rationale**: el repositorio expone cuatro operaciones; una implementación de prueba escrita a
mano es más legible que un mock generado y no añade dependencias ni `build_runner`. Las pruebas
cubren el ViewModel (incluidos cancelación, sin red y proveedor no disponible), los tokens del
tema en claro y oscuro, y la pantalla.

**Lo que no se puede automatizar aquí**: el diálogo del sistema de Google y Apple. SC-001,
SC-004, SC-006 y SC-008 quedan declarados como comprobación manual en dispositivo.
