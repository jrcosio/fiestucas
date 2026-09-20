# Pantalla 04 — Guardadas

**Objetivo:** recuperar fiestas de interés y seguir cambios relevantes.

## Contenido y acciones

Lista de eventos favoritos ordenada por próxima fecha, con separador de pasadas; cartel miniatura, título, localidad y fecha. Guardar/quitar desde tarjeta o Detalle, abrir ficha y compartir. CTA contextual para activar avisos de cambios/cancelaciones. Botón central `+` visible.

## Reglas y aceptación

Persistencia local sin iniciar sesión, idempotente por ID. Si un favorito fue cancelado, mostrar etiqueta **Cancelada** y mantener acceso a la ficha; si ya pasó, conservarlo en sección Pasadas hasta que el usuario lo quite. Sin red, abrir metadatos cacheados y marcar cuándo se actualizaron; las acciones se sincronizan cuando sea posible. Lista vacía con enlace a Inicio. Borrar datos/desinstalar puede perder favoritos: explicarlo en Ajustes.
