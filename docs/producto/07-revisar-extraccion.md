# Pantalla 07 — Revisar extracción

**Objetivo:** que una persona corrija lo interpretado antes de pedir publicación.

## Diseño funcional

Cartel visible junto a formulario editable: **nombre de fiesta**, **localidad y municipio**, **fecha de inicio/fin**, **lugar**, **actividades** (cada una con fecha, hora opcional, título y tipo), **organizador**, **fuente/contacto opcional**. Destacar campos dudosos o no detectados; mostrar literalmente «No encontrado» y permitir introducirlos. Herramientas para añadir, borrar y reordenar actividades. El campo localidad se elige del catálogo, con opción de sugerir una ausente.

## Validación y envío

Obligatorios: nombre, municipio/localidad, fecha de inicio y fin coherentes, al menos una actividad o descripción, cartel y confirmación de que puede compartirlo. Fecha pasada se permite solo cuando el programa siga vigente; de lo contrario advertir. Detectar posibles duplicados y mostrar fichas para consultar antes de seguir; permitir «Es una corrección» para enlazar la propuesta. Botón final **Enviar para revisión**, jamás «Publicar».

## Estados y aceptación

Sin extracción: formulario vacío sobre el cartel. Error por campo con foco y texto comprensible; conservar cambios al volver o al girar el dispositivo. Tras envío correcto se muestra Confirmación; reintento de red con clave idempotente evita duplicados. Probar cartel con múltiples fechas, horas ambiguas, localidad homónima y discrepancia entre texto y diseño.
