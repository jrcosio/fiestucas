# Pantalla 11 — Acceso con Google y Apple

**Objetivo:** identificar a quien quiera enviar una fiestuca, recuperar sus propuestas o sincronizar favoritos, con solo dos proveedores: Google y Apple. Explorar Inicio, Mapa, Calendario y Detalle continúa disponible sin cuenta.

## Entrada y presentación

Se abre al tocar **Iniciar sesión** en Ajustes, al pulsar **Enviar para revisión** sin sesión o al intentar sincronizar favoritos. Si aparece dentro del flujo de un cartel, una frase indica: «Identifícate para enviar tu fiestuca. El cartel y tus correcciones seguirán aquí». Cabecera con logo Fiestucas y elementos gráficos festivos, título **Entra en Fiestucas**, subtítulo breve y dos botones iguales en importancia: **Continuar con Google** y **Continuar con Apple**, con marcas oficiales conforme a sus guías. Debajo: «Puedes seguir descubriendo fiestucas sin cuenta», acción **Ahora no** y enlaces a Privacidad y Condiciones.

## Acciones y navegación

1. Elegir proveedor abre el flujo seguro del sistema/proveedor; la app no pide ni almacena contraseñas.
2. Firebase Authentication verifica la identidad del proveedor, crea o recupera la cuenta y gestiona la sesión: emisión, renovación, persistencia en el dispositivo y cierre. El servidor solo interviene para completar el perfil interno y, cuando corresponda, asignar el rol de moderación.
3. Si venía de un cartel, vuelve a Revisar extracción y completa el envío solo tras confirmar; conserva imagen y formulario. Si venía de Guardadas, combina favoritos locales y remotos. Desde Ajustes, vuelve a Ajustes con la cuenta visible.
4. **Ahora no**, retroceso o cancelación vuelven al punto de origen sin crear cuenta ni perder el borrador. Al reiniciar la app con sesión válida, no mostrar esta pantalla.

## Reglas de identidad

Usar identificador estable (`sub`) del proveedor junto a su nombre como clave de identidad; el correo puede faltar o cambiar, especialmente si Apple oculta el correo. Dos inicios con proveedores distintos son dos identidades hasta que se implementa vinculación explícita: nunca fusionar cuentas por coincidencia de correo. No usar foto, nombre o correo como requisito funcional. Gestionar cierre de sesión y eliminación de cuenta desde Ajustes; al cerrar sesión se ocultan datos privados de la cuenta y los borradores pendientes se conservan localmente solo si el usuario elige conservarlos. La acción de borrado de cuenta debe eliminar o anonimizar datos personales y permitir tratar por separado eventos ya publicados.

## Estados y errores

**Cargando**: bloquear pulsaciones repetidas y mostrar progreso. **Usuario canceló**: volver sin mensaje alarmante. **Sin red/token inválido/proveedor no disponible**: error concreto, reintento y opción Ahora no; conservar borrador. **Cuenta eliminada o sesión caducada**: pedir acceso de nuevo al realizar una acción protegida. **Apple no disponible en un dispositivo concreto**: indicar el motivo y mantener Google accesible; no ofrecer una tercera vía.

## Criterios de aceptación

- Solo existen botones de Google y Apple como métodos de autenticación; no hay registro con contraseña ni acceso anónimo a acciones protegidas.
- Google y Apple crean/recuperan su cuenta; cancelación, denegación y pérdida de red no borran el cartel ni los cambios.
- El inicio de sesión no publica ni envía por sí solo: la persona confirma **Enviar para revisión** después de regresar.
- La cuenta muestra sus propuestas en otro dispositivo y los favoritos se combinan sin duplicados.
- Se comprueban Google y Apple en las versiones Flutter de iOS y Android, incluyendo el retorno correcto a la app, cancelación, renovación de sesión y borrador preservado. El método de Apple en Android utiliza la integración web autorizada por el proveedor cuando corresponda.
