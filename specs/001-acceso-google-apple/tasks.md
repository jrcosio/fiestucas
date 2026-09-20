---
description: "Lista de tareas — Acceso con Google y Apple"
---

# Tasks: Acceso con Google y Apple

**Input**: Documentos de diseño en `/specs/001-acceso-google-apple/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: SÍ se generan tareas de prueba. El principio VII de la constitución las exige para la
lógica y los flujos críticos, y el spec declara qué criterios de éxito se automatizan (SC-002,
SC-003, SC-005, SC-007) y cuáles exigen dispositivo real (SC-001, SC-004, SC-006, SC-008).

**Organization**: por historia de usuario, en orden de prioridad. Cada fase es un incremento
comprobable por sí solo.

## Format: `[ID] [P?] [Story] Descripción`

- **[P]**: se puede hacer en paralelo (ficheros distintos, sin dependencias pendientes)
- **[US1..US4]**: historia de usuario a la que pertenece la tarea

## Path Conventions

Proyecto Flutter único: `lib/` para el código, `assets/` para recursos, `test/` para pruebas.
Configuración nativa en `android/` e `ios/`. Rutas exactas en la sección «Project Structure» del
plan.

---

## Phase 1: Setup

- [X] T001 Añadir las dependencias de la feature con `flutter pub add flutter_riverpod firebase_auth google_sign_in sign_in_with_apple` y comprobar que `pubspec.yaml` queda con las versiones de research.md (3.4.3 / 6.7.0 / 7.2.0 / 8.2.0)
- [X] T002 [P] Convertir el arte plano a WebP sin pérdida con `cwebp -lossless -z 9` desde `docs/imagenes/` hacia `assets/images/decor/` (guirnalda-01..04, corazon-01..04, corazon-doble, flor-radial-01..03) y `assets/images/rotulos/` (los tres rótulos), renombrando a kebab-case
- [X] T003 [P] Convertir `docs/imagenes/inicio_abajo.png` a `assets/images/escenas/inicio-abajo.webp` con `cwebp -q 85 -alpha_q 100` y comprobar que baja de 1,91 MB al orden de 150–250 KB
- [X] T004 [P] Copiar `docs/imagenes/logo.webp` a `assets/images/brand/logo.webp` y los seis `g1..g6.webp` a `assets/images/decor/confeti-01..06.webp`
- [X] T005 [P] Descargar la marca «G» oficial de Google según sus directrices de marca y guardarla como `assets/images/brand/google-g.webp`, sin recolorear ni redibujar
- [X] T006 [P] Descargar de Google Fonts los estáticos Fraunces 600 y Nunito Sans 400/500/700 a `assets/fonts/` junto con sus ficheros `OFL.txt`
- [X] T007 Declarar en `pubspec.yaml` las secciones `assets:` (las cuatro carpetas de imágenes) y `fonts:` (las dos familias con sus pesos), y ejecutar `flutter pub get`

**Checkpoint**: `flutter pub get` resuelve y los recursos están en su sitio con el peso esperado.

---

## Phase 2: Foundational (bloquea todas las historias)

**Purpose**: el sistema de diseño en código y las piezas de dominio que comparten todas las
historias. Sin esto no se puede pintar ni probar ninguna pantalla.

- [X] T008 [P] Crear `lib/core/theme/fiestucas_spacing.dart` con la escala 4/8/12/16/24/32/40, los radios 12/16/20/24, la altura mínima de botón 52 dp y el área táctil mínima 48 dp de la sección 4 del sistema de diseño
- [X] T009 [P] Crear `lib/core/theme/fiestucas_colors.dart` con el `ThemeExtension<FiestucasColors>` para lo que no cabe en `ColorScheme`: `action`, `onAction`, `surfaceElevated`, `accentGold`, `onAccentGold` y los colores de estado de verificación, con sus variantes clara y oscura de la sección 2
- [X] T010 Crear `lib/core/theme/fiestucas_typography.dart` con el `TextTheme` de la tabla de la sección 3 (Fraunces 600 en display 30 y headline 24; Nunito Sans 700/500/400 en el resto) y los interlineados indicados
- [X] T011 Crear `lib/core/theme/fiestucas_theme.dart` con `FiestucasTheme.light` y `FiestucasTheme.dark`, componiendo `ColorScheme`, `TextTheme` y la extensión de colores; ningún hexadecimal fuera de este fichero y de `fiestucas_colors.dart`
- [X] T012 [P] Escribir `test/core/theme/fiestucas_theme_test.dart`: los dos temas exponen la extensión, los tokens coinciden con los valores del documento de diseño y los pares de contraste declarados cumplen el mínimo
- [X] T013 Reescribir `lib/main.dart` para envolver la app en `ProviderScope` y configurar `MaterialApp` con `theme`, `darkTheme` y `themeMode: ThemeMode.system`
- [X] T014 [P] Crear los modelos de dominio en `lib/features/acceso/model/`: `sesion_usuario.dart`, `error_acceso.dart` (las siete variantes) y `estado_acceso.dart` (unión cerrada Inicial/Autenticando/Fallido/Autenticado), según data-model.md
- [X] T015 Crear `lib/features/acceso/repository/autenticacion_repository.dart` con la interfaz y `AccesoException`, exactamente como fija `contracts/autenticacion-repository.md`
- [X] T016 [P] Crear `test/features/acceso/autenticacion_repository_falso.dart`: doble programable con éxito, cada variante de `ErrorAcceso`, retardo configurable y control de `appleDisponible()`

**Checkpoint**: `flutter analyze` sin avisos y el test del tema en verde. Ya se puede construir
cualquier historia.

---

## Phase 3: User Story 1 — Entrar con Google (P1) 🎯 MVP

**Goal**: alguien entra con Google y queda identificado, con la pantalla completa según el mockup.

**Independent Test**: abrir la app, pulsar **Continuar con Google**, completar el diálogo y ver la
pantalla de sesión. Con el doble del repositorio se comprueba entero sin consolas configuradas.

- [X] T017 [US1] Implementar `lib/features/acceso/repository/firebase_autenticacion_repository.dart` para Google: `initialize()` con `serverClientId`, `authenticate()`, canje de `idToken` por credencial de Firebase, más `sesion`, `sesionActual` y `salir()`; traducir todo fallo a `AccesoException` (garantías C1–C5 y C7 del contrato)
- [X] T018 [US1] Crear `lib/features/acceso/view_model/acceso_view_model.dart` como `Notifier<EstadoAcceso>` con la acción `entrarCon`, las transiciones de data-model.md y el rechazo de intentos mientras hay uno en curso
- [X] T019 [P] [US1] Escribir `test/features/acceso/acceso_view_model_test.dart`: camino feliz, cancelación que vuelve a `Inicial` sin error, fallo que pasa a `Fallido`, y pulsación durante la carga que no inicia un segundo intento
- [X] T020 [P] [US1] Crear los widgets decorativos en `lib/features/acceso/view/widgets/`: `guirnalda_superior.dart` (guirnaldas en las dos esquinas), `logo_con_confeti.dart` (logo, lema como texto y trazos de confeti) y `escena_inferior.dart` (ilustración con borde superior curvo), todos marcados como decorativos salvo el logo
- [X] T021 [P] [US1] Crear `lib/features/acceso/view/widgets/boton_google.dart`: fondo `surface`, borde `outline`, radio 16, altura 52, la «G» oficial sin recolorear y el texto «Continuar con Google» en Nunito Sans 700
- [X] T022 [US1] Crear `lib/features/acceso/view/acceso_screen.dart` componiendo el mockup: guirnaldas, logo con confeti, «Entra en Fiestucas» en Fraunces, subtítulo, los botones, «Ahora no», la frase de invitado, la escena inferior y los enlaces legales; con desplazamiento para que nada se corte en pantalla estrecha o con texto ampliado
- [X] T023 [US1] Crear `lib/features/sesion/view/sesion_screen.dart`: pantalla provisional que confirma la sesión y permite cerrarla (FR-024), marcada en el propio fichero como sustituible por Inicio
- [X] T024 [US1] Conectar el arranque en `lib/main.dart`: observar la sesión y mostrar acceso o pantalla de sesión, sin parpadeo mientras llega el primer valor (FR-005, FR-023)
- [X] T025 [P] [US1] Escribir `test/features/acceso/acceso_screen_test.dart`: aparecen los dos botones y «Ahora no», pulsar Google invoca al ViewModel, y durante la carga los botones quedan bloqueados
- [ ] T026 [US1] ⚙️ **Trámite del responsable del producto** — Configuración de plataforma para Google: `serverClientId` tomado del `client_type: 3` de `android/app/google-services.json`, y esquema de URL inverso (`REVERSED_CLIENT_ID`) añadido a `ios/Runner/Info.plist`

**Checkpoint**: la app arranca en la pantalla de acceso, se parece al mockup y el login con Google
funciona de extremo a extremo. Esto ya es un MVP entregable.

---

## Phase 4: User Story 2 — Entrar con Apple (P2)

**Goal**: el mismo resultado con Apple, incluido el caso de correo oculto y el de dispositivo sin
soporte.

**Independent Test**: pulsar **Continuar con Apple** y completar; y forzar `appleDisponible()` a
falso para ver el mensaje con Google aún accesible.

- [X] T027 [US2] Ampliar `firebase_autenticacion_repository.dart` con Apple: `SignInWithApple.isAvailable()`, nonce aleatorio con SHA-256 hacia Apple y `rawNonce` hacia Firebase, y `WebAuthenticationOptions` para el flujo en Android (D4 de research.md)
- [X] T028 [P] [US2] Crear `lib/features/acceso/view/widgets/boton_apple.dart` usando el botón oficial del paquete en estilo negro, con el texto «Continuar con Apple», altura 52 y radio 16
- [X] T029 [US2] Añadir a `acceso_screen.dart` el botón de Apple con el mismo peso visual que el de Google, y el mensaje de «Apple no disponible» cuando corresponda, manteniendo Google accesible y sin ofrecer ninguna tercera vía
- [X] T030 [P] [US2] Ampliar `acceso_view_model_test.dart` y `acceso_screen_test.dart` con Apple: camino feliz, cancelación, correo ausente y dispositivo sin soporte
- [ ] T031 [US2] ⚙️ **Trámite del responsable del producto** — Configuración de plataforma para Apple: capacidad *Sign in with Apple* en el target Runner de Xcode, y Service ID con su clave cargados en la consola de Firebase para el flujo en Android

**Checkpoint**: los dos proveedores funcionan y la pantalla está completa respecto al mockup.

---

## Phase 5: User Story 3 — Seguir explorando sin cuenta (P2)

**Goal**: salir del acceso sin crear cuenta, y poder leer los textos legales.

**Independent Test**: pulsar **Ahora no** y el gesto de retroceso; abrir Privacidad y Condiciones
y volver.

- [X] T032 [US3] Implementar la acción **Ahora no** en `acceso_screen.dart`: cierra la pantalla sin tocar el repositorio, y el gesto de retroceso hace lo mismo (FR-007, FR-008)
- [X] T033 [P] [US3] Crear `lib/features/legal/view/legal_screen.dart`: pantalla reutilizable para Privacidad y para Condiciones, con el texto embarcado y disponible sin conexión (FR-010)
- [X] T034 [US3] Enlazar Privacidad y Condiciones desde `acceso_screen.dart` a esa pantalla, y mostrar la frase «Puedes explorar las fiestas sin cuenta» (FR-009)
- [X] T035 [P] [US3] Ampliar `acceso_screen_test.dart`: **Ahora no** cierra sin invocar al repositorio, y cada enlace legal abre su pantalla

**Checkpoint**: nadie queda atrapado en el acceso y la app cumple el requisito legal de las
tiendas.

---

## Phase 6: User Story 4 — Entender qué ha fallado y reintentar (P3)

**Goal**: cada condición de error tiene mensaje concreto y salida.

**Independent Test**: programar el doble del repositorio con cada variante y comprobar mensaje y
recuperación.

- [X] T036 [US4] Completar en `firebase_autenticacion_repository.dart` el mapeo de las siete variantes de `ErrorAcceso` según la tabla de data-model.md, sin dejar escapar ninguna excepción de los SDK (garantía C3)
- [X] T037 [US4] Presentar los errores en `acceso_screen.dart`: texto concreto por variante, botón **Reintentar** que repite el mismo proveedor, y `cancelado` tratado en silencio sin tono de error (FR-014, FR-015)
- [X] T038 [P] [US4] Ampliar `acceso_view_model_test.dart` con las siete variantes, comprobando que cancelación vuelve a `Inicial` y el resto a `Fallido` con su motivo

**Checkpoint**: la pantalla se comporta bien en la calle, sin cobertura y con proveedores caídos.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T039 [P] Repasar accesibilidad en `lib/features/acceso/view/`: adornos excluidos del árbol semántico, logo e ilustración con descripción, áreas táctiles ≥ 48 dp y orden de lectura correcto (FR-020)
- [X] T040 [P] Actualizar `test/smoke_test.dart` al nuevo arranque con `ProviderScope`
- [X] T041 Pasar la lista de revisión visual de la sección 8 del sistema de diseño sobre la pantalla de acceso, en claro y oscuro, con texto ampliado y en pantalla de 320 dp
- [X] T042 Ejecutar `flutter analyze` sin avisos y `flutter test` en verde
- [X] T043 Compilar `flutter build apk --debug` y `flutter build ios --simulator --no-codesign`
- [~] T044 Verificación manual en dispositivo iOS y Android siguiendo el guion de [quickstart.md](quickstart.md), midiendo además el tiempo hasta pantalla utilizable (SC-008) y el contraste con el inspector de accesibilidad (SC-006); anotar qué quedó comprobado y qué no

---

## Dependencies & Execution Order

```
Phase 1 (Setup)
      ↓
Phase 2 (Foundational)   ← bloquea todo lo demás
      ↓
Phase 3 (US1 Google, P1) ← MVP
      ↓
      ├─ Phase 4 (US2 Apple, P2)
      ├─ Phase 5 (US3 Sin cuenta, P2)
      └─ Phase 6 (US4 Errores, P3)
                ↓
         Phase 7 (Polish)
```

- Las fases 4, 5 y 6 son independientes entre sí una vez terminada la 3: las tres tocan
  `acceso_screen.dart`, así que conviene hacerlas en serie aunque no dependan lógicamente.
- T026 y T031 son configuración de consola: pueden ir en paralelo al código, pero **bloquean la
  verificación en dispositivo** de su historia.
- US1 es el único incremento que por sí solo ya entrega producto utilizable.

## Parallel Example

Al empezar la fase 1, estas cinco pueden ir a la vez porque tocan ficheros distintos:

```
T002  arte plano → WebP sin pérdida
T003  ilustración panorámica → WebP con pérdida
T004  logo y confeti (copia)
T005  marca G de Google (descarga)
T006  tipografías (descarga)
```

En la fase 2, `T008`, `T009`, `T012`, `T014` y `T016` son paralelizables; `T010`, `T011`, `T013`
y `T015` dependen de las anteriores.

## Implementation Strategy

**MVP primero**: fases 1 → 2 → 3. Al terminar la fase 3 hay una app que arranca en su pantalla de
acceso, se parece al mockup y permite entrar con Google. Es demostrable y probable en dispositivo.

**Incremental**: Apple (fase 4) es lo siguiente, porque sin él no se puede publicar en iOS.
Después «Ahora no» y los textos legales (fase 5), que también son requisito de tienda. Los errores
(fase 6) se pueden cerrar al final sin bloquear nada.

## Notes

- Ninguna tarea añade servicios de Firebase más allá de Authentication: Firestore, Storage,
  Analytics, Crashlytics y Messaging entran con la funcionalidad que los use (principio IV).
- Ningún widget importa `firebase_auth`, `google_sign_in` ni `sign_in_with_apple`: solo
  `firebase_autenticacion_repository.dart` (principio III).
- Ningún hexadecimal fuera de `lib/core/theme/` (principio VI).
- **T026 y T031 no las ejecuta quien implementa**: son trámites en las consolas de Firebase, Apple
  Developer y Xcode. Bloquean la verificación en dispositivo de su historia, no el código.
- FR-008, FR-011 y FR-012 quedan explícitamente diferidos a las features que crean sus puntos de
  entrada; no tienen tarea aquí a propósito.

## Estado al cerrar la implementación

- **41 de 44 completadas.**
- **T026 y T031** siguen abiertas: son trámites en las consolas de Firebase, Apple Developer y
  Xcode. Comprobado que hoy `android/app/google-services.json` no tiene ningún `oauth_client` y
  que `ios/Runner/GoogleService-Info.plist` no trae `CLIENT_ID` ni `REVERSED_CLIENT_ID`: esos
  valores aparecen al habilitar Google en la consola y registrar la huella SHA-1. Hasta entonces
  el intento real de entrar termina en un error explicado, no en un cuelgue.
- **T044** queda a medias: la pantalla se ha verificado en el simulador de iPhone en claro y en
  oscuro, y compilan APK de Android e iOS para simulador. Falta el guion completo en dispositivo
  real de ambas plataformas, que depende de T026 y T031.
