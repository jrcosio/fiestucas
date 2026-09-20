import 'package:fiestucas/features/acceso/view/acceso_screen.dart';
import 'package:fiestucas/features/acceso/view_model/acceso_view_model.dart';
import 'package:fiestucas/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/acceso/autenticacion_repository_falso.dart';

void main() {
  testWidgets('la app arranca en la pantalla de acceso', (
    WidgetTester tester,
  ) async {
    final AutenticacionRepositoryFalso falso = AutenticacionRepositoryFalso();
    addTearDown(falso.cerrar);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [autenticacionRepositoryProvider.overrideWithValue(falso)],
        child: const MainApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(AccesoScreen), findsOneWidget);
    expect(find.text('Entra en Fiestucas'), findsOneWidget);
  });

  testWidgets('con sesión válida no se pasa por la pantalla de acceso', (
    WidgetTester tester,
  ) async {
    final AutenticacionRepositoryFalso falso = AutenticacionRepositoryFalso();
    addTearDown(falso.cerrar);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [autenticacionRepositoryProvider.overrideWithValue(falso)],
        child: const MainApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Alguien entra: la app deja de mostrar el acceso.
    await tester.tap(find.text('Continuar con Google'));
    await tester.pumpAndSettle();

    expect(find.byType(AccesoScreen), findsNothing);
    expect(find.text('¡Ya estás dentro!'), findsOneWidget);
  });

  testWidgets('«Ahora no» lleva a explorar sin cuenta y permite volver', (
    WidgetTester tester,
  ) async {
    final AutenticacionRepositoryFalso falso = AutenticacionRepositoryFalso();
    addTearDown(falso.cerrar);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [autenticacionRepositoryProvider.overrideWithValue(falso)],
        child: const MainApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ahora no'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();

    expect(find.text('Estás explorando sin cuenta'), findsOneWidget);
    expect(falso.sesionActual, isNull);

    await tester.tap(find.text('Identificarme'));
    await tester.pumpAndSettle();

    expect(find.byType(AccesoScreen), findsOneWidget);
  });
}
