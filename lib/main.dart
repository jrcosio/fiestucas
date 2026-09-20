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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registrarLicenciasDeFuentes();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebaseOptions opciones = DefaultFirebaseOptions.currentPlatform;
  final AutenticacionRepository repositorio = FirebaseAutenticacionRepository(
    // En iOS sale del GoogleService-Info.plist; en Android no aplica.
    clientId: opciones.iosClientId,
    // Cliente de tipo web del proyecto. Aparece en la configuración en cuanto
    // se habilita Google en la consola de Firebase y se registra el SHA-1.
    serverClientId: opciones.androidClientId,
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
      darkTheme: FiestucasTheme.dark,
      themeMode: ThemeMode.system,
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
