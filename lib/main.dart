import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/fiestucas_theme.dart';
import 'features/acceso/model/sesion_usuario.dart';
import 'features/acceso/repository/autenticacion_repository.dart';
import 'features/acceso/repository/firebase_autenticacion_repository.dart';
import 'features/acceso/view/acceso_screen.dart';
import 'features/acceso/view_model/acceso_view_model.dart';
import 'features/sesion/view/sesion_screen.dart';
import 'firebase_options.dart';

/// Service ID que hay que crear en Apple Developer para que el acceso con Apple
/// funcione **en Android**, donde el flujo es web.
///
/// En iOS no se usa: allí basta con la capacidad *Sign in with Apple* del
/// target, que ya está declarada en `ios/Runner/Runner.entitlements`.
///
/// Mientras esté vacío, la pantalla de acceso no ofrece Apple en Android: lo
/// explica y deja Google disponible, en vez de fallar al pulsar.
const String appleServiceId = String.fromEnvironment('APPLE_SERVICE_ID');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registrarLicenciasDeFuentes();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebaseOptions opciones = DefaultFirebaseOptions.currentPlatform;
  final AutenticacionRepository repositorio = FirebaseAutenticacionRepository(
    // iOS toma su cliente del GoogleService-Info.plist. En Android no se pasa
    // nada: el plugin de Gradle de google-services expone al SDK nativo el
    // cliente de tipo web del proyecto, que es lo que hace falta.
    clientId: opciones.iosClientId,
    appleServiceId: appleServiceId,
    appleRedirectUri: Uri.parse(
      'https://${opciones.projectId}.firebaseapp.com/__/auth/handler',
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        autenticacionRepositoryProvider.overrideWithValue(repositorio),
      ],
      child: const MainApp(),
    ),
  );
}

/// Declara las licencias OFL de las tipografías empaquetadas para que
/// aparezcan en el diálogo de licencias del sistema.
void _registrarLicenciasDeFuentes() {
  LicenseRegistry.addLicense(() async* {
    for (final String ruta in <String>[
      'assets/fonts/OFL-Fraunces.txt',
      'assets/fonts/OFL-NunitoSans.txt',
    ]) {
      final String texto = await rootBundle.loadString(ruta);
      yield LicenseEntryWithLineBreaks(<String>['fiestucas'], texto);
    }
  });
}

/// Raíz de la aplicación.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiestucas',
      debugShowCheckedModeBanner: false,
      theme: FiestucasTheme.light,
      // Fiestucas se presenta siempre en claro, por decisión de producto: el
      // crema y el verde bosque son la identidad de la marca, y el conjunto
      // —guirnaldas, confeti, carteles e ilustraciones— está pensado sobre ese
      // fondo. No se sigue la preferencia de oscuro del sistema.
      //
      // `FiestucasTheme.dark` se conserva definido y probado por si algún día
      // se retoma; hoy no se enchufa a propósito.
      themeMode: ThemeMode.light,
      home: const Arranque(),
    );
  }
}

/// Decide qué pantalla se ve al abrir la app.
///
/// Con sesión válida no se muestra el acceso. Mientras no exista Inicio, el
/// acceso hace de pantalla inicial y quien elige «Ahora no» va a una pantalla
/// provisional de invitado. Cambiar esto cuando llegue Inicio es cuestión de
/// tocar los dos destinos de aquí abajo.
class Arranque extends ConsumerStatefulWidget {
  const Arranque({super.key});

  @override
  ConsumerState<Arranque> createState() => _ArranqueState();
}

class _ArranqueState extends ConsumerState<Arranque> {
  bool _invitado = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SesionUsuario?> sesion = ref.watch(sesionProvider);

    return sesion.when(
      // Sin parpadeo: mientras llega el primer valor se mantiene el fondo del
      // tema en lugar de enseñar el acceso y quitarlo.
      loading: () => const Scaffold(body: SizedBox.expand()),
      error: (Object _, StackTrace _) => _acceso(),
      data: (SesionUsuario? actual) {
        if (actual != null) {
          return SesionScreen(sesion: actual);
        }
        if (_invitado) {
          return InvitadoScreen(
            onVolverAlAcceso: () => setState(() => _invitado = false),
          );
        }
        return _acceso();
      },
    );
  }

  Widget _acceso() =>
      AccesoScreen(onAhoraNo: () => setState(() => _invitado = true));
}
