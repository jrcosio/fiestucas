# Fiestucas — sistema visual 1.0

**Ámbito:** aplicación Flutter para iOS y Android. **Estado:** guía de implementación. La pantalla de acceso y los recursos gráficos existentes son la referencia visual. Los valores claros se han aproximado a partir de esa pantalla; la variante oscura es una propuesta diseñada para conservar el carácter de marca y el contraste. No se afirma que las tipografías propuestas sean las utilizadas para generar el mockup.

## 1. Dirección visual

Fiestucas combina una interfaz clara y funcional con detalles de fiesta popular cántabra. Fondo crema, verde bosque como color estructural, rojo fiesta para la acción principal, dorado como acento y dibujos artesanales discretos. La información —localidad, fecha, programa y fuente— debe seguir siendo lo primero. El modo oscuro no invierte los dibujos ni coloca texto oscuro del logo sobre un fondo oscuro.

**Regla de uso:** los colores se aplican por función (*token semántico*), no por código hexadecimal escrito en cada widget. Material 3 sirve de base para `ThemeData` y se personalizan los componentes de Fiestucas.

## 2. Paleta y tokens semánticos

| Uso / nombre sugerido | Modo claro | Modo oscuro | Aplicación |
|---|---|---|---|
| `background` | `#FAF7ED` | `#101A16` | Fondo de pantallas |
| `surface` | `#FFFDF7` | `#17271F` | Tarjetas, hojas y paneles |
| `surfaceElevated` | `#FFFFFF` | `#23372D` | Diálogos, menús y estados elevados |
| `primary` | `#16583E` | `#7AC89A` | Navegación activa, enlaces, selección |
| `onPrimary` | `#FFFFFF` | `#101A16` | Texto/iconos sobre `primary` |
| `action` | `#B71C34` | `#F15B65` | «+ Subir fiestuca», llamadas a la acción |
| `onAction` | `#FFFFFF` | `#101A16` | Texto/iconos sobre `action` |
| `textPrimary` | `#11231B` | `#F5F1E6` | Texto principal y títulos |
| `textSecondary` | `#526559` | `#BACABD` | Metadatos y apoyo |
| `outline` | `#AAB8A8` | `#708878` | Bordes de campos y divisores |
| `accentGold` | `#9A5900` | `#F5C15B` | Detalles, indicadores y destacados puntuales |
| `onAccentGold` | `#FFFDF7` | `#11231B` | Texto sobre un fondo dorado sólido |
| `error` | `#A71D34` | `#FF7E8B` | Error y validación; acompañado de texto/icono |
| `scrim` | `#11231B` al 55 % | `#000000` al 65 % | Fondo detrás de diálogos |

**Paleta de ilustraciones:** verde hoja `#28522D`, rojo vivo aproximado `#DD1D20`, crema `#FFE8BC`, madera `#CAAB82`, mar `#7EAFB3`. Estos colores viven en el arte; no reemplazan automáticamente los colores de texto o botones. El rojo decorativo de las imágenes y el rojo `action` son distintos a propósito: el segundo está elegido para funcionar como fondo interactivo.

**Contraste comprobado matemáticamente para los pares propuestos:** `textPrimary/background` 15,3:1 en claro y 15,8:1 en oscuro; `textSecondary/background` 5,8:1 y 10,4:1; `onAction/action` 6,5:1 y 5,4:1. Revalidar sobre gradientes, imágenes y estados reales. Como objetivo, texto normal ≥ 4,5:1, texto grande e iconos funcionales ≥ 3:1.

### Estados semánticos

- **Oficial / verificada:** verde con etiqueta textual e icono de comprobación; nunca depender solo del color.
- **Comunidad / sin verificar:** superficie neutra y etiqueta «Comunidad» o «Pendiente de verificar».
- **Cancelada:** mensaje visible con icono y texto, encima del programa; evitar verde festivo en esa tarjeta.
- **Pendiente de moderación:** etiqueta ámbar con texto explícito; no publicar aún en Inicio, Mapa ni Calendario.

## 3. Tipografía

| Función | Familia propuesta | Peso | Tamaño base | Interlineado |
|---|---|---:|---:|---:|
| Título de pantalla (`display`) | **Fraunces** | 600 | 30 sp | 1,12 |
| Título de sección (`headline`) | Fraunces | 600 | 24 sp | 1,18 |
| Título de tarjeta | **Nunito Sans** | 700 | 18 sp | 1,25 |
| Texto normal | Nunito Sans | 400 | 16 sp | 1,45 |
| Botón y etiqueta | Nunito Sans | 700 | 16 sp | 1,20 |
| Metadatos (fecha, municipio) | Nunito Sans | 500 | 14 sp | 1,35 |
| Pie y anotación breve | Nunito Sans | 400 | 12–13 sp | 1,35 |

**Elección propuesta:** Fraunces aporta un titular con personalidad cercana al mockup; Nunito Sans mantiene legibilidad en tarjetas y formularios. Registrar los archivos de ambas fuentes como assets del proyecto, con licencia incluida, para reproducir la misma experiencia en iOS y Android. Respetar el escalado de texto del sistema; probar títulos y botones con texto ampliado, sin limitar a una sola línea cuando el contenido lo exija. Las horas, fechas y cifras usan numerales tabulares si el archivo tipográfico lo permite.

**Marca:** el logo oficial (`logo.webp`, empaquetado como `assets/images/brand/logo.webp`) se usa como imagen, sin reconstruirlo escribiendo «Fiestucas» con otra fuente. Las frases artesanales descargadas también son ilustraciones; cada una necesita una descripción accesible o debe marcarse decorativa según su función.

## 4. Espaciado, formas y elevación

| Token | Valor | Uso |
|---|---:|---|
| Escala espacial | 4, 8, 12, 16, 24, 32, 40 dp | Ritmo general; evitar valores arbitrarios |
| Margen horizontal | 20 dp (16 dp en móviles estrechos) | Contenido de pantalla |
| Separación entre secciones | 24–32 dp | Inicio y Detalle |
| Separación dentro de tarjeta | 12–16 dp | Imagen, texto y acciones |
| `radiusSmall` | 12 dp | Chips y campos |
| `radiusCard` | 20 dp | Tarjetas de evento |
| `radiusButton` | 16 dp | Botones principales |
| `radiusSheet` | 24 dp arriba | Hojas inferiores |
| Altura mínima de botón | 52 dp | Acciones principales |
| Área táctil mínima | 48 × 48 dp | Iconos y controles |

Sombras suaves solo donde mejoran la jerarquía: por ejemplo una tarjeta blanca sobre crema. En oscuro, distinguir niveles mediante superficies y bordes; evitar sombras negras grandes. Respetar `SafeArea` y las barras de sistema de iOS y Android.

## 5. Componentes

| Componente | Claro | Oscuro | Comportamiento |
|---|---|---|---|
| Barra inferior | `surface`, icono activo `primary` | `surface`, icono activo `primary` | Inicio, Mapa, `+`, Calendario, Guardadas; icono + sobresaliente |
| `+ Subir fiestuca` | Fondo `action`, contenido `onAction` | Fondo `action`, contenido `onAction` | Expandido con texto en Inicio, compacto donde proceda; siempre misma acción |
| Tarjeta de evento | `surface`, título `textPrimary` | `surface`, título `textPrimary` | Imagen opcional, nombre, municipio, fecha, categorías; toda la tarjeta activa |
| Filtro/chip | Borde `outline`; seleccionado `primary` | Borde `outline`; seleccionado `primary` | Selección identificable también por icono/estado |
| Campo de formulario | `surface`, etiqueta visible, borde `outline` | `surfaceElevated`, etiqueta visible | Error debajo del campo y recuperación del valor introducido |
| Botón Google/Apple | Seguir directrices visuales oficiales de cada proveedor | Seguir sus variantes aprobadas para fondo oscuro | No recolorear ni dibujar los logos como iconos genéricos |
| Cartel original | Fondo neutro, ajuste proporcional | Fondo neutro, ajuste proporcional | No recortar información del programa; ofrecer ampliación |

### Estados de pantalla

- **Carga:** esqueleto de la distribución real; evitar que salte el contenido al resolver.
- **Vacío:** una frase clara y una acción útil («Cambiar filtros», «Descubrir fiestas»).
- **Error:** explicar qué falló, botón «Reintentar» y datos en caché señalados cuando existan.
- **Sin permisos:** permitir municipio manual y avisos internos; no bloquear la navegación general.

## 6. Uso de recursos gráficos

Recursos disponibles: logo oficial, guirnaldas, corazones, adornos radiales, frases, rótulos e ilustración inferior completa. Usarlos como ornamento puntual, no como sustituto de la información de una fiesta. Una pantalla debería tener **un motivo dominante y, como máximo, un acento pequeño**; Inicio puede usar una guirnalda y un corazón, acceso puede usar la ilustración inferior, Detalle debe priorizar el cartel auténtico.

**Modo oscuro:** el logo original contiene texto oscuro, y los rótulos/frases de la lámina también. Colocarlos sobre una placa `#FFFDF7` con márgenes, o preparar una variante oficial específica para oscuro a partir de las fuentes originales. No invertir colores automáticamente ni aplicar un filtro a los PNG. Guirnaldas y motivos rojo/verde/crema pueden conservar color sobre fondo oscuro si no compiten con los textos.

**Rendimiento:** reutilizar assets con tamaño de render previsto, precargar solo los de la pantalla inicial y evitar cargar la ilustración panorámica en cada tarjeta. Conservar las fuentes e imágenes originales como referencia y crear formatos/escala optimizados para distribución cuando se integre en la app.

## 7. Implementación en Flutter

Definir `FiestucasTheme.light` y `FiestucasTheme.dark` con `ThemeData`/`ColorScheme` y `TextTheme`. Los colores fuera de `ColorScheme` (`action`, superficies adicionales, estados de verificación) se exponen mediante un `ThemeExtension`, no con literales repartidos por widgets. `MaterialApp.themeMode` permite `system`, `light` y `dark`, con preferencia persistida por usuario. Probar cambio de tema con la app abierta, las barras del sistema, diálogos, mapa, cartel y pantalla de acceso.

Ejemplo de acceso en widgets (orientativo, sin fijar paquete de estado):

```dart
final scheme = Theme.of(context).colorScheme;
final brand = Theme.of(context).extension<FiestucasColors>()!;

// Colores de la pantalla, nunca hexadecimales incrustados en widgets.
final titleColor = scheme.onSurface;
final uploadButtonColor = brand.action;
```

## 8. Revisión visual antes de cerrar una pantalla

- La misma tarea se puede completar en iOS y Android con tema claro y oscuro.
- Texto escalado, teclado, bordes seguros, pantalla pequeña y giro si aplica no cortan acciones importantes.
- Texto e iconos conservan contraste; el color nunca es la única indicación de estado.
- Ningún logo o rótulo de tinta oscura queda sobre fondo oscuro; las imágenes no tapan botones.
- Se reconocen estados de carga, vacío, error, sin conexión y permisos denegados.

## Referencias de implementación

- [Flutter: themes, `ThemeData` y `ColorScheme`](https://docs.flutter.dev/cookbook/design/themes).
- [Flutter: fuentes personalizadas](https://docs.flutter.dev/cookbook/design/fonts).
- [Google Fonts: Nunito Sans](https://fonts.google.com/specimen/Nunito+Sans); [Fraunces, proyecto de la tipografía](https://fraunces.undercase.xyz/).
- [WCAG 2.2: contraste mínimo](https://www.w3.org/TR/WCAG22/#contrast-minimum).
