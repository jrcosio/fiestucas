# Feature Specification: Acceso con Google y Apple

**Feature Branch**: `001-acceso-google-apple`

**Created**: 2026-09-20

**Status**: Draft

**Input**: Pantalla de acceso con Google y Apple para Fiestucas, fiel al mockup `docs/login.png`, con autenticación real, tema claro y oscuro, tipografías y recursos gráficos del proyecto empaquetados. Fuentes: `docs/producto/11-acceso.md`, `docs/producto/12-sistema-diseno.md`, `docs/producto/00-README.md` y `.specify/memory/constitution.md`.

## Clarifications

### Session 2026-09-20

- Q: ¿A dónde llevan los enlaces de Privacidad y Condiciones? → A: A pantallas internas de la
  app, con el texto embarcado; no dependen de una web publicada.
- Q: Como el acceso es la pantalla inicial temporal, ¿qué se ve justo después de identificarse?
  → A: Una pantalla provisional de sesión que confirma quién ha entrado y permite cerrar sesión,
  sustituible por Inicio sin tocar el acceso.
- Q: ¿Se incluye ya un selector manual de tema? → A: No. La app solo sigue la preferencia del
  sistema; el selector y su persistencia pertenecen a Ajustes.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Entrar con Google (Priority: P1)

Alguien que ha encontrado una fiesta que no está en Fiestucas quiere aportar su cartel. Al
pulsar **Enviar para revisión** se le pide identificarse. Elige **Continuar con Google**,
completa el diálogo del sistema y vuelve exactamente donde estaba, con su cartel y sus
correcciones intactos, listo para confirmar el envío.

**Why this priority**: Es el camino de acceso más común y el que desbloquea la aportación de
contenido, que es lo que da vida al catálogo. Sin él, la app solo se consume, no se alimenta.

**Independent Test**: Se puede probar de principio a fin abriendo la pantalla de acceso,
pulsando **Continuar con Google** y comprobando que la persona queda identificada y regresa a su
punto de origen. Entrega valor por sí solo aunque Apple no esté disponible todavía.

**Acceptance Scenarios**:

1. **Given** una persona sin sesión en la pantalla de acceso, **When** pulsa **Continuar con
   Google** y completa el diálogo del proveedor, **Then** queda identificada y vuelve al punto
   desde el que llegó.
2. **Given** una persona que llegó desde un cartel a medio revisar, **When** termina de
   identificarse, **Then** vuelve a Revisar extracción con la imagen y el formulario tal como
   los dejó, y **sin** que el envío se haya producido: debe confirmarlo ella.
   *(Diferido a la feature de Enviar cartel; aquí solo se garantiza que el acceso no destruye
   el estado de quien lo invocó.)*
3. **Given** una persona identificándose, **When** pulsa el botón varias veces seguidas,
   **Then** solo se inicia un intento y el resto de pulsaciones se ignoran.
4. **Given** una persona ya identificada, **When** vuelve a abrir la app, **Then** no ve la
   pantalla de acceso.
5. **Given** una persona que llegó al acceso como pantalla inicial, **When** termina de
   identificarse, **Then** ve una pantalla provisional que confirma la sesión y permite
   cerrarla.

---

### User Story 2 - Entrar con Apple (Priority: P2)

Quien prefiere no usar su cuenta de Google, o quiere mantener su correo oculto, elige
**Continuar con Apple** y obtiene exactamente el mismo resultado.

**Why this priority**: Funcionalmente equivalente a US1, pero es **bloqueante para publicar en
iOS**: las directrices de la App Store exigen ofrecer *Sign in with Apple* cuando se ofrece otro
proveedor de identidad social. Se queda en P2 porque se puede desarrollar y demostrar después de
Google, pero cuenta como **bloqueante de publicación**: ninguna versión sale a iOS sin ella.

**Independent Test**: Igual que US1 pero con el botón de Apple, incluyendo el caso de correo
oculto por el proveedor.

**Acceptance Scenarios**:

1. **Given** una persona sin sesión, **When** pulsa **Continuar con Apple** y completa el
   diálogo, **Then** queda identificada igual que con Google.
2. **Given** una persona que elige ocultar su correo, **When** termina de identificarse,
   **Then** la cuenta se crea igualmente y ninguna funcionalidad le pide el correo.
3. **Given** una persona que ya entró antes con Google, **When** entra ahora con Apple,
   **Then** obtiene una cuenta distinta: no se fusiona nada por coincidencia de correo.
4. **Given** un dispositivo donde Apple no está disponible, **When** se abre la pantalla,
   **Then** se explica el motivo, Google sigue accesible y no aparece ninguna tercera vía.

---

### User Story 3 - Seguir explorando sin cuenta (Priority: P2)

Quien solo quiere ver qué hay este fin de semana no debería tener que registrarse. Desde la
pantalla de acceso puede pulsar **Ahora no** y continuar.

**Why this priority**: Es una promesa explícita del producto —el descubrimiento es público— y
evita el abandono en la primera pantalla. Protege además el trabajo ya hecho: salir del acceso
nunca puede costarle a nadie su borrador.

**Independent Test**: Abrir la pantalla, pulsar **Ahora no** (o el gesto de retroceso) y
comprobar que se vuelve al punto de origen sin cuenta creada y sin pérdida de datos.

**Acceptance Scenarios**:

1. **Given** una persona en la pantalla de acceso, **When** pulsa **Ahora no**, **Then** vuelve
   al punto de origen sin crear ninguna cuenta.
2. **Given** una persona que llegó desde un cartel a medio revisar, **When** sale con **Ahora
   no**, con el gesto de retroceso o cancelando el diálogo del proveedor, **Then** conserva el
   cartel y las correcciones. *(Diferido a la feature de Enviar cartel.)*
3. **Given** una persona sin cuenta, **When** sigue usando la app, **Then** puede explorar
   Inicio, Mapa, Calendario y Detalle con normalidad. *(Diferido: ninguna de esas pantallas
   existe todavía.)*

---

### User Story 4 - Entender qué ha fallado y poder reintentar (Priority: P3)

Cuando algo sale mal —se va la cobertura, el proveedor no responde, la sesión ha caducado— la
persona ve un mensaje concreto y una salida, en lugar de una pantalla muerta.

**Why this priority**: No aporta capacidad nueva, pero sin ello el acceso resulta frágil
justamente en la calle, que es donde se usa la app. Se implementa una vez que los caminos
felices funcionan.

**Independent Test**: Forzar cada condición de error y comprobar mensaje, botón de reintento y
conservación del borrador.

**Acceptance Scenarios**:

1. **Given** un dispositivo sin conexión, **When** se intenta entrar, **Then** se explica que no
   hay red, se ofrece reintentar y se conserva el borrador.
2. **Given** una persona que cancela el diálogo del proveedor, **When** vuelve a la app,
   **Then** no ve ningún mensaje alarmante ni de error.
3. **Given** una sesión caducada o una cuenta eliminada, **When** se intenta una acción
   protegida, **Then** se pide acceder de nuevo explicando por qué.

---

### Edge Cases

- **Doble pulsación y pulsación durante la carga**: solo se inicia un intento; el resto se
  ignora mientras haya uno en curso.
- **Cancelación del diálogo del sistema**: se trata como decisión legítima, no como error.
- **Pérdida de red a mitad del intercambio**: mensaje concreto y reintento, sin cuenta a medias.
- **Credencial rechazada o caducada por el proveedor**: se pide acceder de nuevo.
- **Proveedor temporalmente caído**: se explica y se mantiene disponible el otro.
- **Apple no disponible en el dispositivo**: se indica el motivo y se mantiene Google; nunca se
  ofrece una tercera vía.
- **Correo ausente u oculto**: la cuenta funciona igual; nada depende del correo, la foto ni el
  nombre.
- **Misma persona con los dos proveedores**: dos identidades separadas, sin fusión automática.
- **Texto del sistema ampliado al máximo**: ningún botón ni enlace queda cortado o inalcanzable.
- **Pantalla estrecha o teclado abierto**: el contenido sigue siendo alcanzable mediante
  desplazamiento; la ilustración decorativa cede espacio antes que las acciones.
- **Tema oscuro**: ningún logo, rótulo o frase de tinta oscura queda sobre fondo oscuro.
- **Reapertura con sesión válida**: la pantalla no se muestra.

## Requirements *(mandatory)*

### Functional Requirements

**Acceso e identidad**

- **FR-001**: La pantalla MUST ofrecer exactamente dos métodos de identificación, **Continuar
  con Google** y **Continuar con Apple**, presentados con el mismo peso visual y con las marcas
  oficiales de cada proveedor sin recolorear ni redibujar.
- **FR-002**: El sistema MUST NOT ofrecer contraseña, registro por correo, acceso anónimo a
  acciones protegidas ni ningún otro proveedor.
- **FR-003**: El sistema MUST anclar la identidad al identificador estable que entrega el
  proveedor, y MUST NOT usar el correo, el nombre o la foto como requisito funcional.
- **FR-004**: El sistema MUST NOT fusionar cuentas por coincidencia de correo: dos proveedores
  distintos son dos identidades.
- **FR-005**: El sistema MUST mantener la sesión entre arranques de la app y MUST NOT mostrar
  esta pantalla cuando la sesión es válida.
- **FR-006**: Identificarse MUST NOT publicar ni enviar nada por sí solo: tras volver, la
  persona confirma la acción que había iniciado.

**Salidas y conservación del trabajo**

- **FR-007**: La pantalla MUST ofrecer **Ahora no** y MUST devolver a la persona al punto de
  origen sin crear cuenta.
- **FR-008**: Salir por **Ahora no**, por retroceso o cancelando el diálogo del proveedor MUST
  cerrar la pantalla sin destruir el estado de quien la invocó. *Verificación diferida*: no hay
  borrador de cartel hasta que exista Enviar cartel; aquí se garantiza por construcción, porque
  la pantalla de acceso no posee ni modifica ese estado.
- **FR-009**: La pantalla MUST explicar que se puede seguir explorando sin cuenta.
- **FR-010**: La pantalla MUST enlazar a Privacidad y a Condiciones, y cada enlace MUST abrir
  una pantalla interna de la app con ese texto. Los textos MUST estar disponibles sin conexión y
  MUST NOT depender de una web publicada.

**Entradas a la pantalla**

- **FR-011**: La pantalla MUST poder abrirse bajo demanda desde cualquier punto de la app y
  devolver el control a quien la invocó. *Diferido*: los tres puntos de entrada concretos
  —Ajustes, Enviar cartel y Guardadas— se conectan con sus respectivas features; ninguna existe
  todavía.
- **FR-012**: La pantalla MUST admitir un mensaje contextual de quien la invoca. *Diferido*: el
  texto «Identifícate para enviar tu fiestuca. El cartel y tus correcciones seguirán aquí» se
  activa con la feature de Enviar cartel.

**Estados y errores**

- **FR-013**: Durante un intento en curso, el sistema MUST mostrar progreso y MUST bloquear
  pulsaciones repetidas.
- **FR-014**: El sistema MUST distinguir y comunicar con texto concreto: cancelación por la
  persona (sin tono de error), ausencia de red, credencial inválida, proveedor no disponible,
  Apple no disponible en el dispositivo y sesión caducada o cuenta eliminada.
- **FR-015**: Todo estado de error MUST ofrecer una salida: reintentar o **Ahora no**.
  *Nota sobre la sesión caducada*: su traducción a mensaje se implementa aquí, pero el escenario
  solo se puede provocar desde una acción protegida, que llegará con su feature.

**Identidad visual y accesibilidad**

- **FR-016**: La pantalla MUST seguir el sistema de diseño del proyecto en paleta, tipografía,
  espaciado, radios, altura de botón y área táctil mínima.
- **FR-017**: La app MUST ofrecer tema claro y tema oscuro y MUST seguir la preferencia del
  sistema. Esta feature MUST NOT incluir un selector manual de tema: ese control pertenece a
  Ajustes.
- **FR-018**: En tema oscuro, ningún logo, rótulo o frase de tinta oscura MUST quedar sobre
  fondo oscuro.
- **FR-019**: La pantalla MUST usar los recursos gráficos propios del proyecto como ornamento, y
  estos MUST NOT tapar ni sustituir a las acciones ni a la información.
- **FR-020**: Los elementos decorativos MUST marcarse como tales para las tecnologías de apoyo, y
  los elementos con significado MUST tener descripción accesible.
- **FR-021**: La pantalla MUST seguir siendo utilizable con el texto del sistema ampliado y en
  pantallas estrechas, sin cortar acciones.

**Comportamiento común**

- **FR-022**: La pantalla MUST comportarse igual en iOS y Android, respetando las áreas seguras
  y las convenciones de navegación de cada sistema.
- **FR-023**: Mientras no exista la pantalla de Inicio, la pantalla de acceso MUST ser la
  pantalla inicial de la app, y esa condición MUST ser temporal y sustituible sin rehacer la
  pantalla.
- **FR-024**: Cuando alguien se identifica sin punto de origen al que volver, el sistema MUST
  llevarle a una pantalla provisional que confirme la sesión iniciada y permita cerrarla. Esa
  pantalla MUST ser sustituible por Inicio sin modificar la pantalla de acceso.

### Key Entities

- **Cuenta**: la persona identificada dentro de Fiestucas. Se crea la primera vez que alguien
  entra y es lo que vincula sus propuestas y sus favoritos sincronizados. No depende del correo.
- **Identidad de proveedor**: la prueba de quién es alguien según Google o Apple, anclada al
  identificador estable del proveedor. Cada proveedor produce una identidad distinta.
- **Sesión**: el estado de «alguien ha entrado» que persiste entre arranques, se renueva sola y
  puede caducar o invalidarse.
- **Borrador en curso**: el cartel y las correcciones que la persona traía al llegar al acceso;
  no pertenece a esta pantalla, pero esta pantalla no puede perderlo.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Una persona sin cuenta completa la identificación y vuelve a su punto de origen en
  **menos de 20 segundos**, descontando el tiempo que tarde el diálogo del proveedor.
- **SC-002**: En el **100 %** de las salidas sin completar —**Ahora no**, retroceso o
  cancelación— no se crea ninguna cuenta y no se pierde el borrador.
- **SC-003**: Las **seis** condiciones de error de FR-014 muestran un mensaje concreto y una vía
  de recuperación; ninguna deja la pantalla en blanco ni bloqueada.
- **SC-004**: La misma persona, entrando con el mismo proveedor desde otro dispositivo —incluido
  el otro sistema operativo—, obtiene **la misma cuenta**, identificada por el mismo
  identificador estable. *Ver sus propuestas* se verificará con la feature que las cree.
- **SC-005**: Con el texto del sistema al **200 %** y en una pantalla de **320 dp** de ancho,
  los dos botones, **Ahora no** y los enlaces legales siguen siendo visibles y pulsables.
- **SC-006**: El contraste es de al menos **4,5:1** en texto normal y **3:1** en texto grande e
  iconos funcionales, comprobado en claro y en oscuro.
- **SC-007**: Reabrir la app con sesión válida lleva directamente al contenido, **sin** pasar por
  la pantalla de acceso, en el **100 %** de los casos.
- **SC-008**: La pantalla queda pintada y utilizable en **menos de 1 segundo** desde el arranque
  en un dispositivo de gama media, sin saltos de contenido al cargar los recursos gráficos.

**Cómo se comprueba cada criterio**: SC-002, SC-003, SC-005 y SC-007 se cubren con pruebas
automatizadas sobre la lógica de la pantalla y sus estados. SC-001, SC-004, SC-006 y SC-008
exigen dispositivo real en iOS y Android, y se declaran como comprobación manual.

## Assumptions

- **Fusión de favoritos**: `11-acceso.md` indica que, al entrar desde Guardadas, los favoritos
  locales se combinan con los de la cuenta. Guardadas no existe todavía, así que esta feature
  deja el punto de entrada preparado pero **no** implementa la fusión: llegará con su pantalla.
- **Cierre de sesión y borrado de cuenta** se gestionan desde Ajustes, que es otra pantalla y
  otra feature. La pantalla provisional de sesión de FR-024 incluye un cierre de sesión solo
  para poder repetir la prueba en dispositivo; desaparece con ella.
- **Selector de tema**: vive en Ajustes. Esta feature solo sigue la preferencia del sistema.
- **Textos legales**: esta feature construye las dos pantallas y su navegación; la redacción de
  Privacidad y Condiciones es contenido que aporta el responsable del producto. Mientras falte,
  las pantallas existen con el texto que haya.
- **Vinculación de cuentas entre proveedores** queda explícitamente fuera de 1.0, tal y como
  dice `11-acceso.md`.
- **Pantalla inicial temporal**: se asume que la pantalla de acceso hace de pantalla inicial solo
  hasta que exista Inicio, por decisión del responsable del producto, para poder verla y
  probarla en dispositivo.
- **Textos de interfaz**: se usan literalmente los microcopys de `11-acceso.md` y del mockup
  («Entra en Fiestucas», «Continuar con Google», «Continuar con Apple», «Ahora no»,
  «Identifícate para enviar tu fiestuca. El cartel y tus correcciones seguirán aquí»).
- **El lema «Fiestas y romerías de Cantabria»** se compone como texto, porque el archivo del logo
  no lo incluye; así además escala con el ajuste de texto del sistema.
- **Disponibilidad de los proveedores**: se asume que la configuración de Google y Apple en sus
  respectivas consolas estará hecha antes de la verificación en dispositivo. Mientras no lo esté,
  la pantalla se verifica con un doble de la fuente de identidad.
- **Conectividad**: se asume que la identificación requiere red y que no existe un modo de
  acceso sin conexión.
