# CLAUDE.md — Fiestucas

App Flutter (iOS + Android) para descubrir fiestas patronales, romerías, verbenas, ferias y
celebraciones populares de Cantabria, incluidas las de pueblos pequeños.

- **Gobierno del proyecto**: `.specify/memory/constitution.md` — manda sobre todo lo demás,
  incluido este fichero.
- **Especificación funcional**: `docs/producto/00-README.md` y los documentos de pantalla
  `01-inicio.md` … `11-acceso.md`.

---

## 1. Ciclo SDD obligatorio (regla no negociable)

**Toda funcionalidad recorre el ciclo completo de Spec Kit, en orden y sin saltos:**

```
/speckit-specify → /speckit-clarify → /speckit-plan → /speckit-tasks → /speckit-analyze → /speckit-implement
```

- **PROHIBIDO escribir código de producto sin un `tasks.md`** en `specs/<NNN>-<nombre>/`.
  Si llega una petición de código sin especificación, se responde empezando por
  `/speckit-specify`, no editando `lib/`.
- `/speckit-clarify` se ejecuta siempre antes de planificar, aunque la spec parezca cerrada.
- `/speckit-analyze` debe terminar **sin hallazgos CRITICAL** antes de `/speckit-implement`.
- Aplica igual a reglas de seguridad de Firestore/Storage, funciones de servidor y cambios de
  modelo de datos, no solo a pantallas.

**Artefactos de cada funcionalidad** (`specs/<NNN>-<nombre>/`): `spec.md`, `plan.md`,
`tasks.md`, más `research.md`, `data-model.md`, `contracts/` y `checklists/` cuando el plan
los genere.

**Rama de trabajo**: Spec Kit no crea rama en este repo (no hay hook `before_specify`). Crear
`git checkout -b <NNN>-<nombre>` antes de implementar; no trabajar sobre `main`.

**Otros comandos**: `/speckit-converge` para retomar trabajo a medias, `/speckit-checklist`
opcional, `/speckit-constitution` para enmendar el gobierno del proyecto.

**Única excepción — andamiaje de plataforma**: el trabajo que no entrega comportamiento de
producto (arranque del proyecto, configuración de Firebase y de las plataformas nativas,
formateo, CI, dependencias de cimiento) no pasa por el ciclo SDD. Va en un commit propio que
explique qué habilita. En cuanto aparece una pantalla, un dato o una regla de negocio, manda el
ciclo completo.

---

## 2. Reglas de código

**Organización**: por funcionalidad, no por tipo técnico. Estructura concreta de carpetas y
paquetes: la decide el `plan.md` de cada funcionalidad, no este fichero.

**MVVM pragmático**

| Capa | Responsabilidad |
|---|---|
| View | Widgets: presentan estado y envían acciones |
| ViewModel | Coordina el estado y las acciones de una pantalla |
| Repository | Fuente de verdad de los datos |
| Service/adapter | Firebase, almacenamiento local, APIs |

- Casos de uso **solo** con lógica de negocio reutilizable o coordinación de varios
  repositorios.
- No crear clases, interfaces ni capas que solo deleguen una llamada.

**Estado — Riverpod 3.x**

- Los widgets observan ViewModels y les envían acciones. **Ningún widget toca Firebase** ni
  contiene reglas de negocio.
- Modelar y pintar siempre los cuatro estados: **carga, datos, vacío y error**.

**Interfaz**

- Mismo comportamiento en iOS y Android; las diferencias son de permisos, navegación y áreas
  seguras, nunca funcionales.
- Accesibilidad: texto escalable, contraste, descripciones de iconos.
- Permisos: solo tras una acción que los justifique, nunca en el primer arranque, y siempre
  con alternativa si se deniegan (municipio en vez de ubicación, lista en vez de mapa, bandeja
  interna en vez de push).
- Fechas y horas en **`Europe/Madrid`**. Los eventos pueden durar varios días y tener
  actividades pasada la medianoche, que conservan su fecha local.

---

## 3. Diseño

**Fuente única: `docs/producto/12-sistema-diseno.md`.** De ahí salen paleta, tipografía,
espaciado, radios, alturas y área táctil. No se inventan valores.

- **Token semántico siempre.** Nunca un hexadecimal suelto en un widget. Lo que no cabe en
  `ColorScheme` va en el `ThemeExtension` `FiestucasColors` (`action`, `surfaceElevated`,
  `accentGold`, estados de verificación).

  ```dart
  final scheme = Theme.of(context).colorScheme;
  final brand = Theme.of(context).extension<FiestucasColors>()!;
  ```

- **Siempre tema claro.** La app no sigue la preferencia de oscuro del sistema: la identidad de
  marca y los carteles de las fiestas viven sobre el fondo crema. `FiestucasTheme.dark` sigue
  definido y probado como reserva, pero no se enchufa.
- **Tipografía**: Fraunces en títulos, Nunito Sans en texto, empaquetadas en `assets/fonts/`.
- **Adornos**: un motivo dominante por pantalla y, como mucho, un acento pequeño. Nunca tapan
  ni sustituyen la información de una fiesta. Marcados como decorativos para accesibilidad.
- **Antes de cerrar una pantalla**, pasar la lista de revisión visual de la sección 8 del
  documento de diseño.

## 4. Firebase

| Servicio | Uso |
|---|---|
| Authentication | Acceso con Google y Apple (únicos proveedores) |
| Cloud Firestore | Datos |
| Cloud Storage | Carteles e imágenes |
| Analytics | Analítica de uso |
| Crashlytics | Seguimiento de fallos |
| Cloud Messaging | Notificaciones |

- La dependencia se añade a `pubspec.yaml` **cuando se usa**, no antes.
- Operaciones privilegiadas (publicar, rechazar, pedir cambios, extraer cartel, asignar rol)
  → Cloud Functions. Nunca permisos de administrador en la app.
- Una funcionalidad que escribe datos no está terminada sin sus reglas de seguridad: nadie lee
  borradores ajenos, nadie modifica eventos publicados sin autorización, nadie eleva
  privilegios desde el cliente.
- **Cero secretos** en el código o en Git: credenciales de servicio, claves de API de terceros
  y claves de IA.
- En cambio, `lib/firebase_options.dart`, `android/app/google-services.json` y
  `ios/Runner/GoogleService-Info.plist` **sí se versionan**: son identificadores públicos que ya
  viajan dentro del binario y hacen falta para compilar. Lo que protege esos datos son las reglas
  de seguridad, no ocultarlos.

---

## 5. Comandos

```bash
flutter pub get
flutter analyze      # sin avisos antes de dar nada por terminado
flutter test         # en verde antes de dar nada por terminado
dart format .
```

Los flujos con integración nativa (Sign In, cámara, imagen compartida, enlaces profundos,
notificaciones, permisos) se verifican en iOS **y** Android; lo que quede como comprobación
manual se declara explícitamente.

---

## 6. Vocabulario del dominio

Usar estos nombres, no sinónimos inventados:

- **fiestuca** (marca y término coloquial), **evento**, **actividad**, **cartel**,
  **propuesta**, **borrador**, **extracción**, **moderación**.
- Estados de publicación: `draft`, `pending`, `needs_changes`, `rejected`, `cancelled`,
  `expired`, `published`.
- Nivel de verificación: **Oficial / Verificada / Comunidad**.
- La acción del usuario es **«Enviar para revisión»**, jamás «Publicar».

Los textos literales de interfaz están en `docs/producto/`: copiarlos tal cual, no
reescribirlos.

---

## 7. Límites

- No inventar funcionalidades fuera del alcance 1.0 (tabla de `docs/producto/00-README.md`).
- No añadir paquetes sin un uso concreto en la funcionalidad que se está construyendo.
- El panel web de moderación es otro artefacto: no se implementa desde la app y su stack se
  decide en su propia funcionalidad.
- Ante conflicto entre este fichero y la constitución, manda la constitución.
