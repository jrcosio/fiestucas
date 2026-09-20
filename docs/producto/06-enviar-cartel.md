# Pantalla 06 — Enviar cartel

**Objetivo:** aportar una fiesta con una foto sin tener que transcribirla entera.

## Entrada y componentes

Se abre con el botón `+`, tarjeta de Inicio o la opción «Compartir con Fiestucas» desde otra app en iOS y Android (si está habilitada la extensión/receptor correspondiente). Explicación breve: «Sube un cartel; revisa lo que detectemos; lo publicaremos tras comprobarlo». Acciones **Hacer foto**, **Elegir imagen** y, si llega desde otra app, **Usar esta imagen**. Vista previa, cambiar imagen, recortar/rotar opcional, continuar. Aceptar formatos comunes JPG/PNG/HEIC si el servidor los soporta; definir límite de tamaño en configuración y explicarlo antes del envío.

## Comportamiento

Comprobar legibilidad básica/tamaño, subir con indicador de progreso y crear borrador privado; procesar extracción asíncrona. Conexión perdida permite reintentar sin duplicar el borrador. Si la IA falla o el cartel es ilegible, ofrecer «Rellenar manualmente» o sustituir imagen. Permitir seleccionar y analizar el cartel como invitado; pedir acceso Google/Apple al pulsar «Enviar para revisión» y recuperar exactamente el borrador tras autenticarse. Solicitar permiso de cámara solo al usarla; selector del sistema para archivos/fotos.

## Estados y aceptación

Seleccionar → previsualizar → subir → analizando → Revisar extracción. Cancelar antes del envío final descarta o conserva un borrador local tras aviso. Verificar la recepción de imágenes compartidas desde WhatsApp y la galería en iOS y Android, foto vertical, cartel con varios días y error de servidor. El contenido sigue privado durante todo el flujo y la subida definitiva queda asociada al usuario autenticado.
