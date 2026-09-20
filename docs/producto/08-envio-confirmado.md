# Pantalla 08 — Envío confirmado y mis propuestas

**Objetivo:** confirmar recepción y explicar qué sucede después.

## Confirmación

Mensaje «¡Fiestuca enviada! Revisaremos la información antes de publicarla». Mostrar título, localidad, fecha y estado **Pendiente de revisión**. Acciones **Volver a Fiestucas**, **Ver mis envíos** y **Enviar otra**. No prometer plazo de moderación.

## Mis propuestas

Lista de propuestas de la cuenta, leída del servidor y con caché local para consultarla sin red, con estado: **Pendiente**, **Necesita cambios**, **Publicada**, **No publicada**. En «Necesita cambios», mostrar motivo y volver al formulario conservando los datos; en «Publicada», enlazar ficha pública; en «No publicada», explicar motivo y ofrecer corregir si procede. Cada propuesta solo es legible por la cuenta que la envió, según las reglas de seguridad: no hay códigos ni enlaces de acceso compartibles. Las propuestas se recuperan al iniciar sesión en cualquier dispositivo; los borradores aún no enviados son locales y se pierden si se borran los datos de la app.

## Aceptación

La confirmación solo aparece si el servidor recibe la propuesta; al perder respuesta, consultar por clave idempotente antes de reenviar. Ninguna propuesta pendiente figura en resultados públicos. Cambios de estado se reflejan al abrir y, si el usuario lo permite, mediante aviso.
