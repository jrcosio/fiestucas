import 'package:fiestucas/core/theme/fiestucas_theme.dart';
import 'package:fiestucas/features/acceso/model/error_acceso.dart';
import 'package:fiestucas/features/acceso/model/sesion_usuario.dart';
import 'package:fiestucas/features/acceso/view/acceso_screen.dart';
import 'package:fiestucas/features/legal/view/legal_screen.dart';
import 'package:fiestucas/features/acceso/view_model/acceso_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'autenticacion_repository_falso.dart';

void main() {
  late AutenticacionRepositoryFalso falso;

  setUp(() => falso = AutenticacionRepositoryFalso());
  tearDown(() => falso.cerrar());

  Future<void> pintar(
    WidgetTester tester, {
    VoidCallback? onAhoraNo,
    ThemeData? tema,
    Size tamano = const Size(400, 900),
  }) async {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [autenticacionRepositoryProvider.overrideWithValue(falso)],
        child: MaterialApp(
          theme: tema ?? FiestucasTheme.light,
          home: AccesoScreen(onAhoraNo: onAhoraNo),
        ),
      ),
    );
    await tester.pump();
  }

  group('Composición', () {
    testWidgets('muestra la invitación y las acciones', (
      WidgetTester tester,
    ) async {
      await pintar(tester);

      expect(find.text('Entra en Fiestucas'), findsOneWidget);
      expect(
        find.text('Guarda tus fiestas y comparte las que faltan.'),
        findsOneWidget,
      );
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('Continuar con Apple'), findsOneWidget);
      expect(find.text('Ahora no'), findsOneWidget);
      expect(
        find.text('Puedes explorar las fiestas sin cuenta'),
        findsOneWidget,
      );
    });

    testWidgets('muestra el lema de marca junto al logo', (
      WidgetTester tester,
    ) async {
      await pintar(tester);

      expect(find.text('Fiestas y romerías de Cantabria'), findsOneWidget);
    });

    testWidgets('el mensaje de contexto solo aparece si lo pide quien la abre', (
      WidgetTester tester,
    ) async {
      await pintar(tester);
      expect(find.textContaining('El cartel'), findsNothing);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [autenticacionRepositoryProvider.overrideWithValue(falso)],
          child: MaterialApp(
            theme: FiestucasTheme.light,
            home: const AccesoScreen(
              mensajeContexto:
                  'Identifícate para enviar tu fiestuca. El cartel y tus '
                  'correcciones seguirán aquí',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('El cartel'), findsOneWidget);
    });

    testWidgets('se pinta en tema oscuro sin romperse', (
      WidgetTester tester,
    ) async {
      await pintar(tester, tema: FiestucasTheme.dark);

      expect(find.text('Entra en Fiestucas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('en pantalla estrecha sigue siendo desplazable', (
      WidgetTester tester,
    ) async {
      await pintar(tester, tamano: const Size(320, 560));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Acciones', () {
    testWidgets('pulsar Google pide entrar con Google', (
      WidgetTester tester,
    ) async {
      await pintar(tester);

      await tester.tap(find.text('Continuar con Google'));
      await tester.pumpAndSettle();

      expect(falso.intentos, 1);
      expect(falso.proveedoresUsados, <ProveedorAcceso>[
        ProveedorAcceso.google,
      ]);
    });

    testWidgets('Ahora no avisa a quien abrió la pantalla y no crea cuenta', (
      WidgetTester tester,
    ) async {
      bool salio = false;
      await pintar(tester, onAhoraNo: () => salio = true);

      await tester.tap(find.text('Ahora no'));
      await tester.pump();

      expect(salio, isTrue);
      expect(falso.intentos, 0);
      expect(falso.sesionActual, isNull);
    });
  });

  group('Estado de carga', () {
    testWidgets('durante el intento se bloquean las acciones', (
      WidgetTester tester,
    ) async {
      falso.retardo = const Duration(milliseconds: 200);
      await pintar(tester);

      await tester.tap(find.text('Continuar con Google'));
      await tester.pump();

      // El texto del botón deja paso al progreso.
      expect(find.text('Continuar con Google'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // «Ahora no» queda inactivo mientras hay un intento en vuelo.
      final TextButton ahoraNo = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Ahora no'),
      );
      expect(ahoraNo.onPressed, isNull);

      await tester.pumpAndSettle();
      expect(falso.intentos, 1);
    });

    testWidgets('una segunda pulsación durante la carga no abre otro intento', (
      WidgetTester tester,
    ) async {
      falso.retardo = const Duration(milliseconds: 200);
      await pintar(tester);

      await tester.tap(find.text('Continuar con Google'));
      await tester.pump();
      // El botón ya no responde, así que se pulsa donde estaba.
      await tester.tap(find.byType(OutlinedButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(falso.intentos, 1);
    });
  });

  group('Cancelación', () {
    testWidgets('cancelar no deja la pantalla en estado de error', (
      WidgetTester tester,
    ) async {
      falso.errorAlEntrar = ErrorAcceso.cancelado;
      await pintar(tester);

      await tester.tap(find.text('Continuar con Google'));
      await tester.pumpAndSettle();

      // Vuelve a estar todo como al principio.
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('Apple', () {
    testWidgets('pulsar Apple pide entrar con Apple', (
      WidgetTester tester,
    ) async {
      await pintar(tester);

      await tester.tap(find.text('Continuar con Apple'));
      await tester.pumpAndSettle();

      expect(falso.proveedoresUsados, <ProveedorAcceso>[ProveedorAcceso.apple]);
    });

    testWidgets(
      'si el dispositivo no ofrece Apple se explica y Google sigue ahí',
      (WidgetTester tester) async {
        falso.appleEstaDisponible = false;
        await pintar(tester);
        await tester.pumpAndSettle();

        expect(find.text('Continuar con Apple'), findsNothing);
        expect(
          find.text('Este dispositivo no ofrece Apple. Puedes entrar con Google.'),
          findsOneWidget,
        );
        // Ninguna tercera vía: solo queda Google.
        expect(find.text('Continuar con Google'), findsOneWidget);
      },
    );
  });

  group('Errores', () {
    testWidgets('sin red se explica y se ofrece reintentar', (
      WidgetTester tester,
    ) async {
      falso.errorAlEntrar = ErrorAcceso.sinRed;
      await pintar(tester);

      await tester.tap(find.text('Continuar con Google'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No hay conexión'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('reintentar vuelve a pedir el mismo proveedor', (
      WidgetTester tester,
    ) async {
      falso.errorAlEntrar = ErrorAcceso.sinRed;
      await pintar(tester);

      await tester.tap(find.text('Continuar con Apple'));
      await tester.pumpAndSettle();

      falso.errorAlEntrar = null;
      await tester.ensureVisible(find.text('Reintentar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(falso.proveedoresUsados, <ProveedorAcceso>[
        ProveedorAcceso.apple,
        ProveedorAcceso.apple,
      ]);
    });

    testWidgets('el aviso no depende solo del color: lleva icono y texto', (
      WidgetTester tester,
    ) async {
      falso.errorAlEntrar = ErrorAcceso.desconocido;
      await pintar(tester);

      await tester.tap(find.text('Continuar con Google'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('Algo ha fallado'), findsOneWidget);
    });

    testWidgets('cuando no tiene sentido reintentar, no se ofrece', (
      WidgetTester tester,
    ) async {
      falso.errorAlEntrar = ErrorAcceso.appleNoDisponible;
      await pintar(tester);

      await tester.tap(find.text('Continuar con Apple'));
      await tester.pumpAndSettle();

      expect(find.textContaining('no ofrece Apple'), findsWidgets);
      expect(find.text('Reintentar'), findsNothing);
    });
  });

  group('Enlaces legales', () {
    testWidgets('Privacidad abre su pantalla', (WidgetTester tester) async {
      await pintar(tester, tamano: const Size(400, 1400));

      await tester.ensureVisible(find.text('Privacidad'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Privacidad'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);
      expect(find.textContaining('Explorar no necesita cuenta'), findsOneWidget);
    });

    testWidgets('Condiciones abre su pantalla', (WidgetTester tester) async {
      await pintar(tester, tamano: const Size(400, 1400));

      await tester.ensureVisible(find.text('Condiciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Condiciones'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);
      expect(find.textContaining('Qué es Fiestucas'), findsOneWidget);
    });
  });
}
