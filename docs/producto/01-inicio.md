# Pantalla 01 — Inicio

**Objetivo:** responder «¿qué fiestucas hay hoy o este finde?» en pocos segundos.

## Contenido

Cabecera con marca Fiestucas, municipio seleccionado y acceso a buscar/filtrar. Secciones: **Hoy hay fiestuca**, **Este finde**, **Cerca de ti** (solo con ubicación o municipio), y **Próximamente**. Cada tarjeta muestra título, localidad/municipio, fecha u hora de inicio, categorías, imagen si existe y distancia aproximada cuando procede. Añadir tarjeta «¿Conoces una fiesta que no aparece? Sube el cartel» con acción **Subir cartel**.

## Interacción

Tocar tarjeta abre Detalle; buscar filtra título, localidad y actividades de los eventos publicados; filtros simples por fecha, tipo y municipio/radio. `+ Subir fiestuca` central y visible abre Enviar cartel. Cambiar municipio funciona sin permiso de ubicación. Acceso a Avisos desde icono de cabecera.

## Estados y aceptación

Carga con placeholders; sin resultados, mensaje contextual y acceso a limpiar filtros o subir cartel; error de red con reintento y datos recientes identificados como tales si existe caché. No mostrar eventos caducados como si fueran próximos. Verificar que el botón `+` y la tarjeta conducen al mismo flujo y que el texto de distancia no se confunde con tiempo de viaje.
