# Quickstart — Validar el acceso con Google y Apple

**Fase 1** · Feature `001-acceso-google-apple`

Cómo comprobar que la feature funciona, de lo más barato a lo más caro. Los tres primeros
bloques no necesitan ninguna consola configurada.

## Requisitos previos

```bash
flutter --version          # 3.47.5 o superior
cwebp -version             # 1.6.0 — brew install webp
firebase login:list        # sesión activa
```

Para la verificación en dispositivo hace falta, además, lo descrito en
[Configuración de plataforma](#configuración-de-plataforma).

## 1. Análisis y pruebas (sin consolas)

```bash
flutter pub get
flutter analyze            # debe salir sin avisos
flutter test               # debe salir en verde
```

Cubre: transiciones de `EstadoAcceso`, bloqueo de pulsaciones repetidas, mapeo de las siete
variantes de `ErrorAcceso`, tokens del tema en claro y oscuro, y la composición de la pantalla.
Es lo que valida SC-002, SC-003, SC-005 y SC-007.

## 2. La pantalla, sin autenticación real

```bash
flutter run
```

Se espera ver la pantalla de acceso como pantalla inicial, con guirnaldas arriba, el logo con
confeti, «Entra en Fiestucas», los dos botones, «Ahora no» y la ilustración inferior.

Comprobaciones rápidas:

- Cambiar el tema del sistema a oscuro con la app abierta: la pantalla acompaña, y el logo
  queda sobre placa clara.
- Subir el tamaño de texto del sistema al máximo: ningún botón ni enlace se corta.
- Rotar o usar un dispositivo estrecho: el contenido se desplaza; la ilustración cede antes que
  las acciones.
- Pulsar **Privacidad** y **Condiciones**: abren sus pantallas y se vuelve con retroceso.

## 3. Estados de error, provocados

Con el repositorio falso (ver [el contrato](contracts/autenticacion-repository.md)) se puede
forzar cada variante desde las pruebas de widget. En dispositivo, el caso más fácil de provocar
es **sin red**: activar modo avión y pulsar un proveedor. Se espera mensaje concreto, botón de
reintento y ninguna sesión a medias.

## 4. Autenticación real, en dispositivo

```bash
flutter run -d <id-android>
flutter run -d <id-ios>
```

Guion de comprobación, **en ambos sistemas**:

| Paso | Resultado esperado |
|---|---|
| Pulsar **Continuar con Google** y completar | Sesión creada; aparece la pantalla provisional de sesión |
| Cerrar sesión y volver a entrar | Vuelve a funcionar; sin estado pegado |
| Pulsar un proveedor y **cancelar** el diálogo | Se vuelve a la pantalla sin mensaje de error |
| Pulsar **Continuar con Apple** y completar | Sesión creada igual que con Google |
| Entrar con Apple ocultando el correo | La cuenta se crea igualmente |
| Entrar con Google y luego con Apple | Dos cuentas distintas; nada se fusiona |
| Matar la app y reabrirla con sesión | Arranca sin pasar por el acceso |
| Doble pulsación rápida sobre un botón | Solo se abre un diálogo |

Esto es lo que valida SC-001, SC-004 y SC-008. SC-006 (contraste) se comprueba con el
inspector de accesibilidad de cada sistema.

## Configuración de plataforma

Necesario **solo** para el bloque 4. Cada punto es acción en una consola, no código:

1. **Firebase Console → Authentication → Sign-in method**: habilitar **Google** y **Apple**.
2. **Android**: añadir la huella **SHA-1** de depuración al app Android y regenerar la
   configuración:
   ```bash
   cd android && ./gradlew signingReport   # copiar el SHA-1 de la variante debug
   flutterfire configure --project=fiestucas-30dd4 --platforms=android,ios \
     --android-package-name=com.jrblanco.fiestucas --ios-bundle-id=com.jrblanco.fiestucas --yes
   ```
3. **Android**: el `serverClientId` que necesita `google_sign_in` es el cliente de tipo web
   (`client_type: 3`) de `android/app/google-services.json`.
4. **iOS**: registrar el esquema de URL inverso (`REVERSED_CLIENT_ID` de
   `GoogleService-Info.plist`) en `ios/Runner/Info.plist`.
5. **Apple Developer**: activar *Sign in with Apple* en el App ID; para el flujo en Android,
   crear un **Service ID** con su clave y cargarlo en Firebase.
6. **Xcode**: añadir la capacidad *Sign in with Apple* al target Runner.

## Compilación

```bash
flutter build apk --debug
flutter build ios --simulator --no-codesign
```

## Comprobar el peso de los recursos

```bash
du -sh assets/images assets/fonts
ls -l assets/images/escenas/inicio-abajo.webp   # se espera del orden de 150-250 KB
```
