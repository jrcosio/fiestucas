# Pantalla 02 — Mapa

**Objetivo:** localizar fiestas próximas en Cantabria.

## Contenido y acciones

Mapa con marcadores agrupados para eventos publicados con coordenadas comprobadas; al tocar uno, tarjeta breve con nombre, fecha, municipio y acceso a Detalle. Selector **Hoy / Mañana / Este finde / Fecha**, tipos y radio **10 / 25 / 50 / 100 km / Toda Cantabria**. Botón «Buscar en esta zona» al mover el mapa y alternativa **Ver lista** con los mismos resultados. Botón central `+` abre Enviar cartel.

## Reglas

Ubicación solo mientras se usa y solo tras una acción que la requiera; comienzo por municipio escogido si no hay permiso. Un evento sin coordenadas no se inventa en el mapa y sí permanece accesible en Inicio/Calendario. El radio se calcula desde posición o municipio elegido y la interfaz lo denomina distancia aproximada. La vista conserva filtros al abrir/cerrar una ficha.

## Estados y aceptación

Mapa sin conexión: mostrar lista de eventos recientes si hay datos y aviso de actualización pendiente. Sin puntos: cambiar filtros o municipio. Verificar accesibilidad de la lista, agrupación de puntos coincidentes y ausencia de marcadores de propuestas pendientes o fiestas canceladas en el resultado normal.
