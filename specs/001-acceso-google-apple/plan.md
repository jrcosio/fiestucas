# Implementation Plan: Acceso con Google y Apple

**Branch**: `001-acceso-google-apple` | **Date**: 2026-09-20 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-acceso-google-apple/spec.md`

## Summary

Pantalla de acceso con los dos únicos proveedores del producto, Google y Apple, fiel al mockup
`docs/login.png`, con sesión real gestionada por Firebase Authentication. La feature levanta
además los cimientos visuales que usarán todas las pantallas siguientes: el tema claro y oscuro
del sistema de diseño, las tipografías empaquetadas y los recursos gráficos convertidos a WebP.

El enfoque técnico está fijado en [research.md](research.md): Riverpod 3.x con `Notifier`, un
repositorio como única frontera con Firebase, y los plugins de proveedor usados solo para obtener
una credencial que se canjea por sesión. La pantalla se puede verificar entera sin ninguna consola
configurada, gracias al doble del repositorio.

## Technical Context

**Language/Version**: Dart 3.13.4 / Flutter 3.47.5 (stable)

**Primary Dependencies**: `flutter_riverpod` 3.4.3 · `firebase_core` 4.15.0 (ya presente) ·
`firebase_auth` 6.7.0 · `google_sign_in` 7.2.0 · `sign_in_with_apple` 8.2.0

**Storage**: Ninguno propio. La sesión la custodia Firebase Authentication. Esta feature **no**
introduce Firestore ni Cloud Storage.

**Testing**: `flutter_test` con un doble del repositorio de autenticación escrito a mano. Sin
`mockito`, sin `build_runner`.

**Target Platform**: iOS 15+ y Android (minSdk 24), únicas plataformas del proyecto.

**Project Type**: Aplicación móvil Flutter, única, para iOS y Android.

**Performance Goals**: Pantalla pintada y utilizable en menos de 1 s desde el arranque en gama
media (SC-008), sin saltos de contenido al resolver los recursos gráficos.

**Constraints**: Recursos gráficos en WebP; la ilustración panorámica debe bajar de 1,91 MB al
orden de 150–250 KB. Tipografías embarcadas: la app no descarga fuentes en ejecución. Contraste
mínimo 4,5:1 en texto normal y 3:1 en texto grande e iconos, en claro y en oscuro.

**Scale/Scope**: Una pantalla de acceso, dos pantallas legales, una pantalla provisional de
sesión, un tema completo y ~24 recursos gráficos.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Evaluado contra `.specify/memory/constitution.md` **v1.2.0**.

| Principio | Cómo lo cumple este plan | Estado |
|---|---|---|
| **I. Una sola app Flutter** | Un único proyecto; toda la lógica en Dart compartido. Lo específico de plataforma se limita a configuración nativa (esquema de URL inverso en iOS, `serverClientId` en Android, capacidad de Apple en Xcode). Ninguna bifurcación de comportamiento funcional; la única diferencia visible es que Apple puede no estar disponible en un dispositivo, y eso ya es un requisito del producto (FR-014). Verificación en ambos sistemas prevista en [quickstart.md](quickstart.md). | ✅ |
| **II. MVVM pragmático por funcionalidad** | `lib/features/acceso/` con View, ViewModel, Repository y Service. **Sin casos de uso**: no hay lógica reutilizable ni coordinación de varios repositorios, así que añadirlos sería una capa de paso, que el principio prohíbe. El servicio existe porque encapsula tres SDK distintos, no porque delegue una llamada. | ✅ |
| **III. Riverpod 3.x** | `flutter_riverpod` 3.4.3, `ProviderScope` en `main`. Ningún widget importa `firebase_auth` ni los plugins de proveedor: la pantalla observa el ViewModel y le envía acciones. Los cuatro estados son explícitos y cerrados en `EstadoAcceso` (ver [data-model.md](data-model.md)). | ✅ |
| **IV. Firebase como plataforma** | Solo Authentication, que es exactamente lo que esta funcionalidad necesita. **No** se añaden Firestore, Storage, Analytics, Crashlytics ni Messaging: entrarán con la funcionalidad que los use. No se crea ningún documento de perfil (ver D5 en research). | ✅ |
| **V. Moderación y seguridad** | No hay contenido publicable aquí, así que la parte de moderación no aplica. Sí aplica el resto: cero operaciones privilegiadas en el cliente, cero secretos añadidos. Los ficheros de configuración de Firebase ya versionados siguen siendo identificadores públicos. El nonce de Apple se genera en el dispositivo y no se persiste. | ✅ |
| **VI. Experiencia coherente, accesible y sistema de diseño** | El tema sale íntegro de `docs/producto/12-sistema-diseno.md`: paleta clara y oscura, Fraunces y Nunito Sans, escala de espaciado, radios, botón de 52 dp y área táctil de 48 dp. Colores solo por token, con `ThemeExtension` para `action` y compañía. Adornos marcados como decorativos; un motivo dominante (la ilustración inferior) y un acento (la guirnalda). Ningún permiso se solicita en esta pantalla. | ✅ |
| **VII. Calidad verificable** | Los ocho criterios de éxito del spec son medibles y el spec ya declara cuáles se automatizan y cuáles exigen dispositivo. `flutter analyze` sin avisos y `flutter test` en verde son condición de terminado. | ✅ |
| **Flujo SDD** | La feature recorre el ciclo completo. La corrección de `docs/producto/00-README.md` y la enmienda de la constitución a v1.2.0 se hicieron **antes**, fuera del ciclo, acogidas a la excepción de andamiaje de plataforma. | ✅ |

**Re-evaluación tras el diseño de Fase 1**: sin cambios. El diseño no introdujo ninguna capa,
dependencia ni servicio de Firebase adicional respecto a la evaluación previa. **Sin violaciones
que justificar**, así que la tabla de Complexity Tracking queda vacía.

## Project Structure

### Documentation (this feature)

```text
specs/001-acceso-google-apple/
├── plan.md              # Este fichero
├── spec.md              # Qué y por qué
├── research.md          # Fase 0: decisiones técnicas verificadas
├── data-model.md        # Fase 1: entidades de dominio y estados
├── quickstart.md        # Fase 1: cómo validar
├── contracts/
│   └── autenticacion-repository.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Lo genera /speckit-tasks
```

### Source Code (repository root)

```text
lib/
├── main.dart                        # ProviderScope + arranque; decide acceso o sesión
├── firebase_options.dart            # Generado por FlutterFire
├── core/
│   └── theme/
│       ├── fiestucas_colors.dart    # ThemeExtension: action, surfaceElevated, accentGold…
│       ├── fiestucas_theme.dart     # FiestucasTheme.light / .dark
│       ├── fiestucas_typography.dart# TextTheme (Fraunces + Nunito Sans)
│       └── fiestucas_spacing.dart   # Escala, radios, alturas
└── features/
    ├── acceso/
    │   ├── model/
    │   │   ├── sesion_usuario.dart
    │   │   ├── estado_acceso.dart
    │   │   └── error_acceso.dart
    │   ├── repository/
    │   │   ├── autenticacion_repository.dart          # Interfaz + AccesoException
    │   │   └── firebase_autenticacion_repository.dart # Única frontera con los SDK
    │   ├── view_model/
    │   │   └── acceso_view_model.dart                 # Notifier de Riverpod
    │   └── view/
    │       ├── acceso_screen.dart
    │       └── widgets/
    │           ├── boton_google.dart
    │           ├── boton_apple.dart
    │           ├── guirnalda_superior.dart
    │           ├── logo_con_confeti.dart
    │           └── escena_inferior.dart
    ├── legal/
    │   └── view/legal_screen.dart   # Privacidad y Condiciones (FR-010)
    └── sesion/
        └── view/sesion_screen.dart  # Provisional, sustituible por Inicio (FR-024)

assets/
├── fonts/                # Fraunces 600; Nunito Sans 400/500/700; OFL.txt
└── images/
    ├── brand/            # logo.webp, google-g.webp
    ├── decor/            # guirnalda-01..04, confeti-01..06, corazon-*, flor-radial-*
    ├── rotulos/          # rotulo-*.webp
    └── escenas/          # inicio-abajo.webp

test/
├── smoke_test.dart                      # Ya existe; se adapta al nuevo arranque
├── core/theme/fiestucas_theme_test.dart
└── features/acceso/
    ├── acceso_view_model_test.dart
    ├── autenticacion_repository_falso.dart
    └── acceso_screen_test.dart
```

**Structure Decision**: organización por funcionalidad con un `core/` para lo transversal, tal
como pide el principio II. Se descarta la estructura «Mobile + API» de la plantilla: no hay `api/`
propio —el servidor es Firebase— ni carpetas separadas por plataforma, porque la app es una sola
(principio I). `legal/` y `sesion/` nacen como features propias, aunque mínimas, para que
sustituirlas más adelante no obligue a tocar `acceso/`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

Sin violaciones. Ninguna fila que rellenar.
