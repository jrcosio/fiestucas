# Fiestucas 1.0 — especificación funcional

**Producto:** app móvil para iOS y Android desarrollada con Flutter para descubrir fiestas patronales, romerías, verbenas, ferias y celebraciones populares de Cantabria, incluidas las de pueblos pequeños. **Objetivo:** saber qué hay hoy, este fin de semana o cerca, consultar un programa fiable y aportar un cartel en pocos pasos. Este paquete describe comportamiento y alcance, no maquetas pixel a pixel.

## Plataformas y arquitectura móvil

- Un único proyecto Flutter (Dart) para iOS y Android, con los mismos modelos, lógica de dominio, estados y diseño adaptable a ambas plataformas. El código nativo se limita a la integración con cada sistema. El panel web de moderación y las funciones de servidor quedan separados de la app móvil.
- Implementar adaptaciones nativas o plugins mantenidos para Google y Apple Sign In, selector/cámara, recepción de imágenes compartidas, mapas, enlaces profundos y notificaciones. La sesión la gestiona Firebase Authentication, así que no se mantiene un almacenamiento seguro propio de credenciales. Verificar ambos sistemas con dispositivos reales.
- La interfaz respeta áreas seguras, navegación y permisos de cada sistema sin crear dos especificaciones funcionales divergentes. Publicar y probar ambas versiones dentro del alcance 1.0.
- Los datos y las cuentas son comunes: un usuario ve favoritos y propuestas en cualquiera de los dos sistemas. Las notificaciones se entregan a iOS y Android mediante Firebase Cloud Messaging, apoyado en el servicio de cada sistema, con bandeja interna compartida.

## Decisiones de producto

- Navegación inferior: **Inicio | Mapa | + | Calendario | Guardadas**. El botón central `+` abre **Subir fiestuca**; en Inicio se acompaña de texto y una tarjeta explicativa.
- Descubrimiento público sin cuenta. El acceso con Google o Apple es obligatorio para enviar carteles, guardar favoritos entre dispositivos y consultar propuestas propias; no hay contraseña, correo manual ni redes adicionales. La ubicación es opcional en ambas plataformas; si se deniega, se elige municipio y se puede ver toda Cantabria.
- Cada ficha muestra cartel original, fuente, estado de verificación y fecha de actualización. El contenido aportado por usuarios entra en moderación antes de publicarse.
- La IA ayuda a transcribir carteles; nunca publica directamente ni inventa horas. El usuario confirma la extracción y un moderador decide la publicación.
- Fechas y horas en `Europe/Madrid`; un evento puede durar varios días y tener actividades después de medianoche.

## Alcance 1.0

| Dentro | Fuera de 1.0 |
|---|---|
| Inicio, Mapa, Calendario, Guardadas, Detalle, Enviar cartel, Revisar extracción, Confirmación | Chat público, entradas y pagos, reseñas, redes sociales, perfiles completos de organizadores |
| Buscar por nombre/localidad; filtros de fecha, distancia y tipo; compartir enlace; favoritos locales | Predicción de tiempos de coche, clasificación social de popularidad, búsqueda semántica |
| Cartel → extracción asistida → corrección → envío → moderación; panel web mínimo | Publicación automática de carteles, scraping indiscriminado, generación automática de programas anuales |
| Avisos básicos por fiestas guardadas y novedades próximas, con permiso explícito | Motor avanzado de reglas combinadas, avisos comerciales |

## Documentos por pantalla

1. [Inicio](01-inicio.md)
2. [Mapa](02-mapa.md)
3. [Calendario](03-calendario.md)
4. [Guardadas](04-guardadas.md)
5. [Detalle de fiestuca](05-detalle.md)
6. [Enviar cartel](06-enviar-cartel.md)
7. [Revisar extracción](07-revisar-extraccion.md)
8. [Envío confirmado y mis propuestas](08-envio-confirmado.md)
9. [Avisos y ajustes básicos](09-avisos-ajustes.md)
10. [Panel de moderación](10-panel-moderacion.md)
11. [Acceso con Google y Apple](11-acceso.md)

**Identidad visual:** [Sistema de diseño — colores, tipografía y modos claro/oscuro](12-sistema-diseno.md).

## Recorrido principal

`Inicio/Mapa/Calendario → Detalle → Guardar o compartir`. Aportación: `+ → foto/archivo → extracción → revisión editable → acceso si no hay sesión → envío → pendiente de moderación → publicada/rechazada`. Se permite preparar el borrador como invitado sin perderlo durante el acceso. Un fallo de extracción permite corregir manualmente y conservar el cartel.

## Reglas transversales

- Solo son públicos los eventos `published`; `draft`, `pending`, `needs_changes`, `rejected`, `cancelled` y `expired` tienen tratamiento explícito. Una cancelación ya publicada conserva la ficha con aviso visible y se excluye de sugerencias normales.
- La ficha padre agrupa varios días; cada actividad tiene fecha local, hora opcional, título y tipo. Mostrar «Hora por confirmar» cuando falta y «Dato sin confirmar» cuando la fuente es comunitaria.
- Distancia aproximada en línea recta, indicada como tal; navegación externa para llegar. Evitar prometer tiempos de coche.
- Favoritos de invitado guardados localmente; tras iniciar sesión se asocian a la cuenta y se sincronizan sin duplicados. Las propuestas se vinculan a la cuenta autenticada y aparecen en «Mis propuestas». No mostrar identidad ni datos de contacto del remitente en fichas públicas.
- Notificaciones en iOS y Android solo tras permiso del sistema y preferencia activada. Un evento nuevo coincide con la zona elegida; cambios/cancelaciones de guardados pueden generar aviso. Sin permiso, la app funciona completa y muestra avisos dentro de la app.
- Fuente original y permiso de uso del cartel se registran; permitir retirada/corrección y no presentar el proyecto como oficial. Accesibilidad: texto escalable, contraste, descripciones de iconos y alternativa en lista al mapa.

## Datos y servicios mínimos

`Event(id, title, slug, municipality_id, village, venue, lat?, lon?, starts_on, ends_on, description?, poster_url?, source_name, source_url?, source_type, verification_state, publication_state, updated_at)`; `Activity(id, event_id, local_date, start_time?, end_time?, title, category)`; `Submission(id, user_id, poster, extracted_payload, corrected_payload, status, created_at, moderation_note?)` y `User(id, created_at)`. La identidad del proveedor (Google o Apple) la gestiona Firebase Authentication: no se mantiene una entidad propia de identidades y sigue prohibido fusionar cuentas por coincidencia de correo. Los datos viven en Cloud Firestore, con las entidades modeladas como colecciones y las actividades colgando de su evento. Mantener procedencia por campo cuando se detecten discrepancias. Índices compuestos para fechas, municipios y estado; deduplicación por municipio, fechas, título y similitud de cartel antes de aprobar.

Acceso orientativo: la app lee de Cloud Firestore, desde sus repositorios, los eventos publicados filtrando por fecha, categoría, texto y zona, y la ficha de un evento concreto. La cuenta escribe y corrige su propio borrador de propuesta y lee sus propuestas por identificador de usuario, con reglas de seguridad que impiden tocar o leer borradores ajenos. Las operaciones privilegiadas son funciones de servidor invocables: extraer el cartel, enviar la propuesta a revisión y las decisiones de moderación. Imágenes en Cloud Storage y trabajo asíncrono en servidor para extracción y notificaciones. El cliente no contiene claves de IA.

## Criterios de salida de 1.0

- Se puede descubrir una fiesta, abrir programa, consultar fuente, guardar, compartir y navegar a su ubicación.
- Se puede compartir una imagen desde otra app o elegir foto, corregir todos los campos obligatorios, identificarse con Google o Apple, enviar y conocer el estado.
- Ninguna aportación aparece públicamente antes de aprobarla; cartel ambiguo o IA fallida sigue teniendo vía manual.
- Se prueban en iOS y Android: cambio de día, actividad pasada la medianoche, permisos denegados, imagen ilegible, duplicado, cancelación y conexión intermitente; además, acceso con Google/Apple, imagen compartida desde otra app, enlaces profundos y restauración de sesión.
- Estos escenarios se cubren con pruebas automatizadas siempre que sea posible, y lo que quede como comprobación manual en dispositivo real se declara de forma explícita. `flutter analyze` sin avisos y `flutter test` en verde.
