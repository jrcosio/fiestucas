<!--
Sync Impact Report
- Versión: 1.2.0 → 2.0.0 (MAJOR: se redefine de forma incompatible una regla MUST)
- Principios modificados:
  VI. Experiencia coherente y accesible → la app deja de ofrecer tema oscuro. Se
      retira la obligación de soportar dos temas y de seguir la preferencia del
      sistema, y se sustituye por la de presentarse siempre en claro.
- Por qué MAJOR: desaparece una obligación que las pantallas ya construidas
  cumplían, y ninguna funcionalidad futura tendrá que soportar dos temas. Es una
  redefinición del principio, no una aclaración.
- Principios añadidos: ninguno
- Secciones eliminadas: ninguna
- Plantillas dependientes: sin cambios.
- Seguimiento: el FR-017 de specs/001-acceso-google-apple/spec.md, el documento
  docs/producto/12-sistema-diseno.md y CLAUDE.md se corrigen en el mismo cambio.
- TODO pendientes: ninguno

Historial
- 1.2.0 (2026-09-20): el sistema de diseño de docs/producto/12-sistema-diseno.md
  pasa a ser de obligado cumplimiento.
- 1.1.0 (2026-09-20): excepción «Andamiaje de plataforma» en el flujo SDD;
  `firebase_core` declarado cimiento; regla de secretos precisada.
- 1.0.0 (2026-09-20): ratificación inicial con siete principios —I. Una sola app
  Flutter para iOS y Android; II. Arquitectura por funcionalidades con MVVM
  pragmático; III. Estado con Riverpod 3.x; IV. Firebase como plataforma del
  proyecto; V. Moderación previa y seguridad sin privilegios en el cliente;
  VI. Experiencia coherente y accesible; VII. Calidad verificable— y las
  secciones de restricciones, flujo SDD y gobernanza.
-->

# Constitución de Fiestucas

Fiestucas es la app para descubrir fiestas patronales, romerías, verbenas, ferias y
celebraciones populares de Cantabria, incluidas las de pueblos pequeños. Esta constitución
recoge las decisiones duraderas del proyecto. La especificación funcional vive en
`docs/producto/`; la guía operativa del día a día, en `CLAUDE.md`.

## Principios fundamentales

### I. Una sola app Flutter para iOS y Android

Fiestucas es un único proyecto Flutter/Dart que se publica en iOS y Android.

- Los modelos, la lógica de dominio y las reglas de producto son compartidos al 100 %.
- El código específico de plataforma se limita a integración nativa: permisos, acceso con
  Google y Apple, recepción de imágenes compartidas desde otras apps, enlaces profundos y
  notificaciones.
- PROHIBIDO bifurcar el comportamiento funcional por plataforma o mantener dos
  especificaciones divergentes. Las diferencias legítimas son de permisos, convenciones de
  navegación y áreas seguras, no de qué hace el producto.
- Todo flujo que dependa de una integración nativa se verifica en ambos sistemas antes de
  darse por terminado.

Razón: una sola fuente de verdad funcional evita que una plataforma se quede atrás y hace
que cada corrección valga para las dos.

### II. Arquitectura por funcionalidades con MVVM pragmático

El código se organiza por funcionalidades y aplica MVVM con cuatro responsabilidades:

- **View**: widgets que presentan el estado y envían acciones.
- **ViewModel**: coordina el estado y las acciones de una pantalla.
- **Repository**: fuente de verdad de los datos de la aplicación.
- **Service/adapter**: acceso a Firebase, almacenamiento local o APIs externas.

Se incorporan casos de uso SOLO cuando exista lógica de negocio reutilizable o haya que
coordinar varios repositorios. PROHIBIDO crear capas, interfaces o clases que únicamente
deleguen una llamada sin aportar una separación útil.

Razón: la separación debe pagarse con claridad real; la indirección gratuita solo añade
ficheros que mantener.

### III. Estado con Riverpod 3.x

La gestión de estado y dependencias se hace con Riverpod 3.x.

- Los widgets observan ViewModels y les envían acciones. NUNCA consultan Firebase
  directamente ni contienen reglas de negocio.
- Los ViewModels dependen de repositorios o, cuando corresponda, de casos de uso.
- Los cuatro estados —carga, datos, vacío y error— se modelan y se presentan de forma
  explícita en cada pantalla; un estado sin tratar es un defecto, no un detalle pendiente.

Razón: hace la interfaz predecible y comprobable, y permite cambiar el origen de datos sin
reescribir pantallas.

### IV. Firebase como plataforma del proyecto

Firebase es la plataforma principal de Fiestucas:

| Servicio | Uso |
|---|---|
| Firebase Authentication | Acceso con Google y Apple, únicos proveedores |
| Cloud Firestore | Datos de la aplicación |
| Cloud Storage | Carteles e imágenes |
| Firebase Analytics | Analítica de uso |
| Firebase Crashlytics | Seguimiento de fallos |
| Firebase Cloud Messaging | Notificaciones |

Cada servicio se integra cuando la funcionalidad correspondiente lo necesita. PROHIBIDO
añadir dependencias por anticipado sin un uso concreto, tanto en `pubspec.yaml` como en la
configuración nativa. La extracción asistida de carteles se ejecuta en servidor: el cliente
no contiene claves de IA ni de servicios de terceros.

`firebase_core` y el fichero generado `lib/firebase_options.dart` son el cimiento de la
plataforma, no un servicio anticipado: registran la app contra el proyecto Firebase y sin
ellos no funciona ninguno de los seis servicios. Los seis mantienen intacta la regla
anterior.

Razón: una plataforma común reduce piezas que operar, y añadir solo lo que se usa mantiene
la app ligera y auditable.

### V. Moderación previa y seguridad sin privilegios en el cliente

- Ninguna aportación de usuario es pública antes de aprobarse. La acción del usuario es
  «Enviar para revisión», JAMÁS «Publicar».
- Las operaciones privilegiadas (publicar, rechazar, pedir cambios, extraer un cartel,
  asignar rol de moderador) se ejecutan en un entorno de servidor. PROHIBIDO ejecutar
  operaciones con permisos administrativos desde la app.
- Las reglas de seguridad deben impedir leer borradores ajenos, modificar eventos publicados
  sin autorización y elevar privilegios desde el cliente. Una funcionalidad que escribe datos
  no está terminada sin sus reglas.
- PROHIBIDO incluir secretos en la aplicación o en Git: credenciales de servicio, claves de
  API de terceros y claves de IA. Los ficheros de configuración de cliente que genera
  FlutterFire —`lib/firebase_options.dart`, `android/app/google-services.json` y
  `ios/Runner/GoogleService-Info.plist`— no son secretos: son identificadores públicos que ya
  viajan dentro del binario de la app, hacen falta para compilar y SE VERSIONAN en Git. Lo que
  protege esos datos son las reglas de seguridad, no su ocultación.
- Las fichas públicas no muestran la identidad ni los datos de contacto de quien aporta.

Razón: el contenido lo aporta la comunidad y la confianza en los datos es el producto; la
autorización se decide donde no puede manipularse.

### VI. Experiencia coherente y accesible

- Comportamiento coherente en iOS y Android, respetando áreas seguras y convenciones de cada
  sistema, con diseño adaptable a distintos tamaños.
- Accesibilidad: texto escalable, contraste suficiente y descripciones de iconos.
- Los permisos se solicitan solo cuando hacen falta y tras una acción que los justifique,
  nunca en el primer arranque, y SIEMPRE con alternativa si se deniegan: municipio elegido en
  vez de ubicación, lista en vez de mapa, bandeja interna en vez de notificaciones.
- Las fechas y horas se tratan en la zona horaria `Europe/Madrid`. Un evento puede durar
  varios días y tener actividades después de medianoche, que conservan su fecha local
  correcta.
- Se conserva la identidad visual de Fiestucas y se utilizan los recursos gráficos del
  proyecto.

El sistema de diseño de `docs/producto/12-sistema-diseno.md` es de OBLIGADO CUMPLIMIENTO en
toda pantalla:

- Paleta, tipografía (Fraunces en títulos, Nunito Sans en texto), escala de espaciado, radios,
  altura de botón y área táctil mínima salen de ese documento.
- Los colores se aplican SIEMPRE por token semántico. PROHIBIDO escribir un hexadecimal suelto
  en un widget. Lo que no cabe en `ColorScheme` se expone mediante un `ThemeExtension`.
- Fiestucas se presenta SIEMPRE en tema claro y NO sigue la preferencia de oscuro del sistema.
  La identidad de la marca —fondo crema, verde bosque y el arte festivo de guirnaldas, confeti,
  rótulos e ilustraciones— está construida sobre ese fondo, y los carteles originales de las
  fiestas, que son el contenido principal de la app, se leen sobre claro. Es una decisión de
  producto, no una limitación técnica.
- La paleta oscura sigue documentada en el sistema de diseño, y `FiestucasTheme.dark` sigue
  definido y probado en el código, como reserva por si algún día se retoma. Si vuelve, vuelve con
  su regla: ningún logo, rótulo o frase de tinta oscura queda sobre fondo oscuro.
- Los recursos gráficos son ornamento puntual y NUNCA sustituyen a la información de una
  fiesta: una pantalla tiene un motivo dominante y, como máximo, un acento pequeño.
- Ninguna pantalla se da por cerrada sin pasar la lista de revisión visual de la sección 8 de
  ese documento.

Razón: la app se usa de pie, en la calle y con prisa; negar un permiso no puede dejar a
nadie sin producto. Y una identidad aplicada a ojo, widget a widget, se deshace en cuanto
crece el número de pantallas.

### VII. Calidad verificable

- Cada funcionalidad define criterios de aceptación verificables antes de implementarse.
- Se añaden pruebas útiles para la lógica y los flujos críticos; se busca confianza, no
  cobertura por cobertura.
- `flutter analyze` sin avisos y `flutter test` en verde antes de dar una tarea por
  terminada.
- Los flujos que usan integraciones nativas se verifican en iOS y Android; lo que quede como
  comprobación manual en dispositivo se declara explícitamente.
- La documentación se mantiene alineada con las decisiones implementadas.

Razón: un criterio que no se puede comprobar no es un criterio, y lo que no se ejecuta en
ambas plataformas no está entregado.

## Restricciones de producto y plataforma

- `docs/producto/` es la fuente funcional del proyecto y `docs/producto/12-sistema-diseno.md`
  la fuente de la identidad visual; esta constitución es la fuente de gobierno. Ante un
  conflicto manda la constitución y el documento afectado se corrige.
- El alcance de la versión 1.0 es el de la tabla de `docs/producto/00-README.md`. PROHIBIDO
  inventar funcionalidades fuera de ese alcance.
- Vocabulario de dominio obligatorio: fiestuca, evento, actividad, cartel, propuesta,
  borrador, extracción y moderación; estados de publicación `draft`, `pending`,
  `needs_changes`, `rejected`, `cancelled`, `expired` y `published`; niveles de verificación
  Oficial, Verificada y Comunidad. Los microcopys literales de los documentos de pantalla se
  respetan tal cual.
- El panel web de moderación queda fuera del ámbito de esta constitución, salvo por los
  principios V y VII: comparte modelo de datos, reglas de seguridad y registro de auditoría
  con la app, pero su stack se decide en su propia funcionalidad.
- Esta constitución fija principios duraderos. NO impone una estructura de carpetas detallada
  ni selecciona paquetes concretos: esas decisiones pertenecen al plan de cada funcionalidad.

## Flujo de desarrollo (SDD obligatorio)

El ciclo completo de desarrollo dirigido por especificación (SDD) de Spec Kit es OBLIGATORIO
para toda funcionalidad, en este orden y sin saltos:

`/speckit-specify` → `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks` →
`/speckit-analyze` → `/speckit-implement`

- PROHIBIDO escribir código de producto sin un `tasks.md` generado para esa funcionalidad.
  Una petición de código sin especificación se atiende empezando por `/speckit-specify`.
- `/speckit-analyze` debe quedar sin hallazgos CRITICAL antes de implementar.
- Los artefactos viven en `specs/<NNN>-<nombre>/`: `spec.md`, `plan.md`, `tasks.md` y los
  documentos de diseño que genere el plan.
- `/speckit-converge` se usa para retomar trabajo incompleto; `/speckit-checklist` queda a
  discreción de cada funcionalidad.
- Este flujo aplica igualmente a las reglas de seguridad, las funciones de servidor y los
  cambios de modelo de datos, no solo a las pantallas.

### Excepción: andamiaje de plataforma

El trabajo que no entrega comportamiento de producto —arranque del proyecto, configuración de
Firebase y de las plataformas nativas, formateo, integración continua y dependencias de
cimiento— no requiere ciclo SDD. Va en un commit propio que explique qué habilita y sigue
sujeto al resto de principios.

Esta excepción NUNCA sirve para adelantar funcionalidad de producto: en cuanto aparece una
pantalla, un dato o una regla de negocio, manda el ciclo completo.

## Gobernanza

Esta constitución prevalece sobre cualquier otra práctica del proyecto, incluidos los
documentos de producto y los hábitos heredados de otros repositorios.

- **Enmiendas**: se aprueban por escrito, se aplican con `/speckit-constitution` y quedan
  registradas en el Sync Impact Report de la cabecera del documento.
- **Versionado semántico**: MAJOR al retirar o redefinir un principio de forma incompatible;
  MINOR al añadir un principio o una sección o ampliar materialmente una guía; PATCH para
  aclaraciones, redacción y correcciones sin cambio de significado.
- **Cumplimiento**: el gate «Constitution Check» de `plan.md` se rellena a partir de estos
  siete principios en cada funcionalidad. Una violación solo puede seguir adelante si se
  justifica en la tabla «Complexity Tracking» del plan explicando por qué la alternativa más
  simple no basta.
- **Guía operativa**: `CLAUDE.md` traduce estos principios a reglas de trabajo diarias. Si
  `CLAUDE.md` y esta constitución discrepan, manda la constitución y se corrige `CLAUDE.md`.

**Version**: 2.0.0 | **Ratified**: 2026-09-20 | **Last Amended**: 2026-09-20
